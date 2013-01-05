#!ruby

class DupFind
  STR = {
    :usage => "usage: #{$0} [path]\n[path] is the root directory of searches, and defaults to the current directory.",
    :dir_not_found => "Error! Directory not found: ",
    :dir_not_dir => "Error! Not a directory: ",
    :empty_head => "Empty files:",
    :dup_head => "Duplicate files:",
    :dup_tail => "",
    :arr_delimit => "\n",
    :progrstr => [' - ',' / ',' | ',' \ ']
  }
  BIGFILE_SIZE = 2*1024*1024 # 2 MiB
  def help; puts STR[:usage]; exit; end
  def exists?( path ); File.exist?( path ); end
  def dir?( path ); File.directory?( path ); end
  def file?( path ); File.file?( path ); end
  def read?( path ); File.readable?( path ); end
  def symlink?( path ); File.symlink?( path ); end
  def err( what, where='' ); warn STR[what]+where; exit; end
  def check_src_dir( path )
    err :dir_not_found, path unless exists? path
    err   :dir_not_dir, path unless    dir? path
  end
  def full_path( path, parent=nil ); File.expand_path( path, parent ); end
  def ignore?( fn ); @ignores.include?( fn ); end
  def check_argv
    help if @argv.length > 1
    if @argv.length == 0
      src_dir = Dir.pwd
    else
      src_dir = @argv.first
    end
    src_path = full_path( src_dir )
    check_src_dir( src_path )
    @src_path = src_path
  end
  def newsha; @sha = Digest::SHA256.new; end
  def progress( progchr=nil )
    if progchr.nil?
      time_now = Time.now.to_f
      if time_now - @progrlast > 0.1
        progrstr = STR[:progrstr]
        @progrstate = 0 if @progrstate == progrstr.length
        progchr = progrstr[@progrstate]
        @progrstate += 1
        @progrlast = time_now
      end
    end
    return if @lastchr == progchr
    @lastchr = progchr
    print "\r#{progchr}"
    $stdout.flush
  end
  def digest_small( path )
    fdata = File.read( path )
    @sha << fdata
  end
  def digest_large( path, blksize=65536 )
    f = File.open( path, 'rb' )
    progress
    f.each( blksize ) do |fdata,i|
      @sha << fdata
      progress
    end
    f.close
  end
  def read_digest( path, fstat )
    if fstat.size < fstat.blksize
      newsha
      digest_small( path )
    else
      newsha
      digest_large( path, fstat.blksize )
    end
    @sha.digest
  end
  def is_dup?( digest, path )
    if @files_by_sum.has_key? digest
      progress ' * '
      darr = @files_by_sum[ digest ]
      @dup << digest if darr.length == 1
      darr << path
      return true
    end
    @files_by_sum[ digest ] = [ path ]
    false
  end
  def handle_file( path, fstat=nil )
    if fstat.nil?
      fstat = File.stat( path )
      if fstat.size == 0
        @empty << path
        return
      end
      if fstat.size > BIGFILE_SIZE
        @bigfiles << [ path, fstat ]
        progress ' ! '
        return
      end
    end
    digest = read_digest( path, fstat )
    is_dup?( digest, path )
  end
  def scan( parent )
    progress ' . '
    Dir.entries( parent ).each do |fn|
      next if ignore? fn
      path = full_path( fn, parent )
      next if symlink? path
      if dir? path
        scan path
      elsif file? path and read? path
        handle_file path
      end
    end
  end
  def find_big_by_size
    big_compared = []
    until @bigfiles.empty?
      (path, fstat) = @bigfiles.shift
      next if big_compared.include? path
      @bigfiles.each do |path2,fstat2|
         next if big_compared.include? path2
         if fstat.size == fstat2.size
           unless big_compared.include? path
             handle_file( path, fstat )
             big_compared << path
           end
           handle_file( path2, fstat2 )
         end
      end
    end
  end
  def putsarr( head, arr )
    puts STR[head]
    puts arr.sort.join(STR[:arr_delimit])
  end
  def initialize( argv )
    @argv = argv; check_argv
    @files_by_sum = {}
    @ignores = [ '.', '..' ]
    @empty = []
    @dup = []
    @bigfiles = []
    require 'digest/sha2'
    @progrstate = 0
    @lastchr = '...'
    @progrlast = 0
    progress ' _ '
    scan @src_path
    print "\r"
    #putsarr( :empty_head, @empty ) unless @empty.empty?
    find_big_by_size
    @dup.each do |digest|
      putsarr( :dup_head, @files_by_sum[digest] )
      puts STR[:dup_tail]
    end
  end
end
DupFind.new(ARGV)
