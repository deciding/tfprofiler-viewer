# tfprofiler-viewer

only tested on the following settings for scope view

```python
from tensorflow.python.profiler import model_analyzer, option_builder
my_profiler = model_analyzer.Profiler(graph=self.session.graph)
run_options = tf.RunOptions(trace_level=tf.RunOptions.FULL_TRACE)
run_metadata = tf.RunMetadata()

sess.run(outputs, options=run_options, run_metadata=run_metadata)
my_profiler.add_step(step=i, run_meta=run_metadata)

profile_op_builder = option_builder.ProfileOptionBuilder( )
# sort by time taken
profile_op_builder.select(['micros', 'occurrence'])
profile_op_builder.order_by('micros')
profile_op_builder.with_max_depth(20) # can be any large number
profile_op_builder.with_file_output('profile.log')
my_profiler.profile_name_scope(profile_op_builder.build())
```

## How to use
`./tf_profiler_scope_viewer.sh {the output file from above scope view}`
