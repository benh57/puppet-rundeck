#
define rundeck::config::resource_source(
  $project_name,
  $number              = '',
  $source_type         = '',
  $include_server_node = '',
  $resource_format     = '',
  $url                 = '',
  $url_timeout         = '',
  $url_cache           = '',
  $directory           = '',
  $projects_dir        = '',
  $script_args_quoted  = '',
  $script_interpreter  = '',
  $script_file         = '',
  $script_args         = ''

) {

  include rundeck::params

  if "x${number}x" == 'xx' {
    $num = '1'
  } else {
    $num = $number
  }

  if "x${source_type}x" == 'xx' {
    $type = $rundeck::params::default_source_type
  } else {
    $type = $source_type
  }

  if "x${include_server_node}x" == 'xx' {
    $inc_server = $rundeck::params::include_server_node
  } else {
    $inc_server = $include_server_node
  }

  if "x${resource_format}x" == 'xx' {
    $format = $rundeck::params::resource_format
  } else {
    $format = $resource_format
  }

  if "x${url_timeout}x" == 'xx' {
    $timeout = $rundeck::params::url_timeout
  } else {
    $timeout = $url_timeout
  }

  if "x${url_cache}x" == 'xx' {
    $cache = $rundeck::params::url_cache
  } else {
    $cache = $url_cache
  }

  if "x${directory}x" == 'xx' {
    $dir = $rundeck::params::default_resource_dir
  } else {
    $dir = $directory
  }

  if "x${projects_dir}x" == 'xx' {
    $pd = $rundeck::params::projects_dir
  } else {
    $pd = $projects_dir
  }

  if "x${script_args_quoted}x" == 'xx' {
    $saq = $rundeck::params::script_args_quoted
  } else {
    $saq = $script_args_quoted
  }

  if "x${script_interpreter}x" == 'xx' {
    $sci = $rundeck::params::script_interpreter
  } else {
    $sci = $script_interpreter
  }

  validate_string($project_name)
  validate_re($num, '[1-9]*')
  validate_re($type, ['^file$', '^directory$', '^url$', '^script$'])
  validate_bool($inc_server)
  validate_absolute_path($pd)

  $properties_file = "${pd}/${project_name}/etc/project.properties"

  ini_setting { "resources.source.${num}.type":
    ensure  => present,
    path    => $properties_file,
    section => '',
    setting => "resources.source.${num}.type",
    value   => $type
  }

  case downcase($type) {
    'file': {
      validate_re($format, ['^resourcexml$','^resourceyaml$'])

      ini_setting { "resources.source.${num}.config.requireFileExists":
        ensure  => present,
        path    => $properties_file,
        section => '',
        setting => "resources.source.${num}.config.requireFileExists",
        value   => true
      }

      ini_setting { "resources.source.${num}.config.includeServerNode":
        ensure  => present,
        path    => $properties_file,
        section => '',
        setting => "resources.source.${num}.config.includeServerNode",
        value   => $inc_server
      }

      ini_setting { "resources.source.${num}.config.generateFileAutomatically":
        ensure  => present,
        path    => $properties_file,
        section => '',
        setting => "resources.source.${num}.config.generateFileAutomatically",
        value   => true
      }

      ini_setting { "resources.source.${num}.config.format":
        ensure  => present,
        path    => $properties_file,
        section => '',
        setting => "resources.source.${num}.config.format",
        value   => $format
      }

      ini_setting { "resources.source.${num}.config.file":
        ensure  => present,
        path    => $properties_file,
        section => '',
        setting => "resources.source.${num}.config.file",
        value   => '/var/rundeck/projects/test/etc/resources.xml'
      }
    }
    'url': {

      validate_string($url)
      validate_re($timeout, '[0-9]*')
      validate_bool($cache)

      ini_setting { "resources.source.${num}.config.url":
        ensure  => present,
        path    => $properties_file,
        section => '',
        setting => "resources.source.${num}.config.url",
        value   => $url
      }

      ini_setting { "resources.source.${num}.config.timeout":
        ensure  => present,
        path    => $properties_file,
        section => '',
        setting => "resources.source.${num}.config.timeout",
        value   => $timeout
      }

      ini_setting { "resources.source.${num}.config.cache":
        ensure  => present,
        path    => $properties_file,
        section => '',
        setting => "resources.source.${num}.config.cache",
        value   => $cache
      }
    }
    'directory': {
      validate_absolute_path($dir)

      ini_setting { "resources.source.${num}.config.directory":
        ensure  => present,
        path    => $properties_file,
        section => '',
        setting => "resources.source.${num}.config.directory",
        value   => $directory
      }
    }
    'script': {
      validate_re($format, ['^resourcexml$','^resourceyaml$'])
      validate_bool($saq)
      validate_string($sci)
      validate_absolute_path($script_file)
      validate_string($script_args)

      ini_setting { "resources.source.${num}.config.file":
        ensure  => present,
        path    => $properties_file,
        section => '',
        setting => "resources.source.${num}.config.file",
        value   => $script_file
      }

      ini_setting { "resources.source.${num}.config.args":
        ensure  => present,
        path    => $properties_file,
        section => '',
        setting => "resources.source.${num}.config.args",
        value   => $script_args
      }

      ini_setting { "resources.source.${num}.config.format":
        ensure  => present,
        path    => $properties_file,
        section => '',
        setting => "resources.source.${num}.config.format",
        value   => $format
      }

      ini_setting { "resources.source.${num}.config.interpreter":
        ensure  => present,
        path    => $properties_file,
        section => '',
        setting => "resources.source.${num}.config.interpreter",
        value   => $sci
      }

      ini_setting { "resources.source.${num}.config.argsQuoted":
        ensure  => present,
        path    => $properties_file,
        section => '',
        setting => "resources.source.${num}.config.argsQuoted",
        value   => $saq
      }
    }
    default: {
      err("The rundeck resource model type: ${type} is not supported")
    }
  }
}