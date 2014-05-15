#!/usr/bin/env ruby

require "bundler"
Bundler.require

require "tempfile"

basename = "chuork01-rubima-report"

Tempfile.open([basename, ".md"]) do |tempfile|
  unless File.exist?("report.md")
    tempfile.puts(<<-END_OF_HEADER)
# RegionalRubyKaigiレポート 札幌市中央区Ruby会議01
    END_OF_HEADER
  end

  @preformatting = false
  Dir.glob("*.md").reject {|f| /README/ =~ f }.sort.each do |path|
    markdown_text = File.read(path)
    markdown_text.each_line do |line|
      if /^```/ =~ line
        @preformatting = !@preformatting
        tempfile.puts
        next
      end
      line.sub!(/^/, " ") if @preformatting
      line.sub!(/^( *)-{1}/, "#{$1}*") if /^ *-{1}/ =~ line
      line.sub!(/^#/, "##") unless File.exist?("report.md")
      tempfile.puts(line)
    end
    tempfile.puts
  end

  tempfile.flush
  system("md2hiki", tempfile.path)

  system("md2hiki #{tempfile.path} > #{basename}.hiki")
  system("hikidoc #{basename}.hiki > #{basename}.html")
  system("firefox", "#{basename}.html")
end
