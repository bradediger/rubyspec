def with_timezone(name, offset = nil, daylight_saving_zone = "")
  zone = name.dup

  if (offset)
    # TZ convention is backwards
    offset = -offset

    zone << offset.to_s
    zone << ":00:00"
  end
  zone << daylight_saving_zone

  old = ENV["TZ"]
  ENV["TZ"] = zone

  begin
    yield
  ensure
    ENV["TZ"] = old
  end
end

def localtime(seconds, format)
  guard = SpecGuard.new

  if guard.os?(:linux) || `date --version`.grep(/GNU coreutils/)
    `LC_ALL=C date -d @#{seconds} +'#{format}'`.chomp
  elsif guard.os?(:darwin, :bsd)
    `LC_ALL=C date -r #{seconds} +'#{format}'`.chomp
  else
    `LC_ALL=C date -j -f "%s" #{seconds} "+#{format}"`.chomp
  end
end

# Returns the given time in the same format as returned by
# Time.at(seconds).inspect on MRI 1.8
def localtime_18(seconds)
  localtime(seconds, "%a %b %d %H:%M:%S %z %Y")
end

# Returns the given time in the same format as returned by
# Time.at(seconds).inspect on MRI 1.9
def localtime_19(seconds)
  localtime(seconds, "%F %H:%M:%S %z")
end
