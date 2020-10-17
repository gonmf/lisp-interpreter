# frozen_string_literal: true

begin
  use_readline = (require 'readline')
rescue
  use_readline = false
end

begin
  # Just for development
  require 'pry'
rescue
end

class Interpreter
  attr_accessor :env_defs, :use_readline

  def initialize(use_readline)
    @use_readline = use_readline

    @env_defs = {}

    env_defs['+'] = Proc.new do |args|
      raise 'unexpected number of arguments for +' if args.count == 1

      args = args.map { |arg| eval_tokens(arg) }

      args.map { |arg| arg.to_i }.sum
    end

    env_defs['-'] = Proc.new do |args|
      raise 'unexpected number of arguments for -' if args.count > 2

      args = args.map { |arg| eval_tokens(arg) }

      args.count == 1 ? -(args[0].to_i) : args.map { |arg| arg.to_i }.sum
    end

    env_defs['/'] = Proc.new do |args|
      raise 'unexpected number of arguments for /' unless args.count == 2

      args = args.map { |arg| eval_tokens(arg) }

      begin
        args[0].to_i / args[1].to_i
      rescue
        raise 'invalid division'
      end
    end

    env_defs['*'] = Proc.new do |args|
      raise 'unexpected number of arguments for *' if args.count == 1

      args = args.map { |arg| eval_tokens(arg) }

      ret = 1

      args.each do |arg|
        ret *= arg.to_i
      end

      ret
    end

    env_defs['def'] = Proc.new do |args|
      raise 'unexpected number of arguments for def' if args.count != 2

      head = args[0]
      if head.is_a?(String)
        name = head
        vars = []
      else
        name = head[0]
        vars = head[1..-1]
      end
      body = args[1]

      env_defs[name] = Proc.new do |args|
        raise "unexpected number of arguments for #{name}" if args.count != vars.count

        args = args.map { |arg| eval_tokens(arg) }

        mbody = deep_clone(body)
        bind_vars(vars, args, mbody)

        eval_tokens(mbody)
      end

      name
    end

    env_defs['quote'] = Proc.new do |args|
      raise "unexpected number of arguments for quote" if args.count != 1

      args[0]
    end
  end

  def start_main_loop
    loop do
      begin
        tokens = read_input&.first
        break if tokens.nil?

        puts format_eval(eval_tokens(tokens))
      rescue => e
        puts "Error: #{e.message}"
      end
    end
  end

  private

  def bind_var(var, arg, body)
    body.each.with_index do |part, idx|
      if part.is_a?(Array)
        bind_var(var, arg, part)
      elsif part == var
        body[idx] = arg
      end
    end
  end

  def bind_vars(vars, args, body)
    vars.each.with_index do |var, idx|
      bind_var(var, args[idx], body)
    end
  end

  def deep_clone(obj)
    if obj.is_a?(Array)
      obj.map { |part| deep_clone(part) }
    else
      obj
    end
  end

  def read_input
    line = if use_readline
      Readline.readline('> ')&.strip
    else
      STDOUT.print('> ')
      STDIN.gets&.strip
    end

    return nil if line.nil? || ['quit', 'exit'].include?(line.downcase)
    return read_input if line.size == 0

    Readline::HISTORY.push(line)

    tokens = expand(line, 0)

    tokens
  end

  def parse_value(str)
    str = str.downcase

    if (str[0] == '-' || (str[0] >= '0' && str[0] <= '9')) && str.chars[1..-1].all? { |c| c >= '0' && c <= '9' }
      str.to_i
    else
      str
    end
  end

  def expand(chars, start)
    ret = []
    str = ''

    idx = start
    while idx < chars.size
      c = chars[idx]

      if c == ' ' && str.size > 0
        ret.push(parse_value(str))
        str = ''
      elsif c == '('
        if str.size > 0
          ret.push(parse_value(str))
          str = ''
        end

        val, end_pos = expand(chars, idx + 1)

        ret.push(val)
        idx = end_pos + 1
      elsif c == ')'
        if str.size > 0
          ret.push(parse_value(str))
          str = ''
        end

        raise "syntax error at position #{idx}" if ret.empty?

        return [ret, idx]
      elsif c != ' '
        str += c
      end

      idx += 1
    end

    if str.size > 0
      ret.push(parse_value(str))
    end

    [ret, idx]
  end

  def eval_tokens(args)
    name = args[0] if args.is_a?(Array) && args[0].is_a?(String)

    if name && env_defs[name]
      env_defs[name].call(args[1..-1])
    elsif args.is_a?(Array)
      if args.count > 1
        raise 'illegal syntax'
      else
        eval_tokens(args[0])
      end
    else # String
      args
    end
  end

  def format_eval(obj)
    obj.is_a?(Array) ? "(#{obj.map { |part| format_eval(part) }.join(', ')})" : obj
  end
end

Interpreter.new(use_readline).start_main_loop
