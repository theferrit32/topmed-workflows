class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://sevenbridges.com'
id: alignment_validation
baseCommand:
  - '{'
  - samtools
  - view
inputs:
  - 'sbg:category': Input files
    id: cram
    type: File
    inputBinding:
      position: 2
      shellQuote: false
    label: Alignment file
    doc: Input CRAM file
    'sbg:fileTypes': CRAM
  - 'sbg:category': Parameters
    id: expected_md5
    type: string
    inputBinding:
      position: 9
      shellQuote: false
    label: MD5
    doc: Expected MD5 hash.
  - 'sbg:category': Input files
    id: reference
    type: File
    inputBinding:
      position: 0
      prefix: '--reference'
    label: Reference
    doc: Reference genome sequence.
    'sbg:fileTypes': 'FASTA, FA'
  - 'sbg:toolDefaultValue': '7500'
    id: ram_min
    type: int?
    label: Minimum amount of RAM
    default: 2000
  - 'sbg:toolDefaultValue': '8'
    id: cores_min
    type: int?
    label: Minimum number of cores
    default: 1
outputs:
  - id: stdout
    label: stdout
    type: File?
    outputBinding:
      glob: log.stdout
  - id: stderr
    label: stderr
    type: File?
    outputBinding:
      glob: log.stderr
label: Validation
arguments:
  - position: 0
    prefix: ''
    shellQuote: false
    valueFrom: |
      ${
          var input_filename = inputs.cram.path.split('/').pop()
          var input_name_base = input_filename.split('.').slice(0,-1).join('.')
          var aux = "--output-fmt SAM -o " + input_name_base + ".sam"
          return aux
      }
  - position: 4
    prefix: ''
    shellQuote: false
    valueFrom: |-
      ${
          var ret = "&& md5=$(md5sum "
          var input_filename = inputs.cram.path.split('/').pop()
          var input_name_base = input_filename.split('.').slice(0,-1).join('.')
          return ret + input_name_base + ".sam | awk '{ print $1 }') && if [ $md5 = " 
      }
  - position: 11
    prefix: ''
    separate: false
    shellQuote: false
    valueFrom: |-
      ${
          return "]; then exit 0; else exit 1; fi; } >> log.stdout 2> log.stderr"
      }
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram_min)
    coresMin: $(inputs.cores_min)
  - class: DockerRequirement
    dockerPull: 'statgen/alignment:1.0.0'
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - $(inputs.cram)
      - $(inputs.reference)

