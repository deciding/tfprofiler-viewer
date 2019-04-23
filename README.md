# tfprofiler-viewer

only tested on the following settings for scope view

```python
my_profiler = model_analyzer.Profiler(graph=self.session.graph)
options = tf.RunOptions(trace_level=tf.RunOptions.FULL_TRACE)
run_metadata = tf.RunMetadata()

profile_op_builder = option_builder.ProfileOptionBuilder( )
# sort by time taken
profile_op_builder.select(['micros', 'occurrence'])
profile_op_builder.order_by('micros')
profile_op_builder.with_max_depth(20) # can be any large number
my_profiler.profile_name_scope(profile_op_builder.build())
```

## How to use
`./tf_profiler_scope_viewer.sh {the output file from above scope view}`
