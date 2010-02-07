module Chewbacca
  def Chewbacca.included(klass)
    load 'manifest.rb'
    klass.class_eval do
      namespace :chewbacca do
        desc "push changed files according to manifest.rb"
        task :push do
          push
        end
        desc "pull all files according to manifest.rb"
        task :pull do
          pull
        end
      end
    end
  end

  def push
    if File.exist?('.cash')
      times = Marshal.load(File.open('.cash').read)
    else
      times = {}
    end
    MANIFEST.each do |local,remote|
      if File.exist?(local)
        print "#{local} : "
        if times[local]
          if times[local] < File.open(local).mtime.to_i
            print "gwroar! uploading to #{remote}\n"
            system "scp #{local} #{USER}@#{HOST}:#{remote}"
            times[local] = File.open(local).mtime.to_i
          else
            print "arghffff! no changes\n"
          end
        else
          times[local] = File.open(local).mtime.to_i
          print "gwroar! uploading to #{remote}\n"
          system "scp #{local} #{USER}@#{HOST}:#{remote}"
        end
      end
    end
    File.open('.cash','w') do |f|
      f.puts Marshal.dump(times)
    end
  end
  
  def pull
    MANIFEST.each do |local,remote|
      puts "harmmff! downloading #{remote} to #{local}"
      system "scp #{USER}@#{HOST}:#{remote} #{local}"
    end
  end

end


