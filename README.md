# MethodProxies
A library to decorate and control method execution.


### Example

```
"Exact Coverage"
proxies := nil.
p := nil.
Smalltalk garbageCollect.
	
testCase := StringTest selector: #testAsCamelCase.
(MpMethodProxy 
   onMethod: testCase testMethod 
   handler: MpProfilingMethodHandler new) install.
testCase run.

proxies := MpProfilingMethodHandler allInstances.
proxies do: #uninstall.

"Managing exceptions in the spyied method"

p := MpMethodProxy 
        onMethod: MwClassB >> #methodTwo 
	handler: MpFailingMethodHandler new.
p install.
p uninstall.
MpClassB new methodTwo.

"Managing exceptions outside the wrapper"
p := MpMethodProxy 
         onMethod: Object >> #error: 
	 handler: CountingMethodWrapper new.
p install.
p uninstall.
1 error: 'foo'.

### Sharing Handlers

h := MpAllocationProfilerHandler new.
p1 := MpMethodWrapper 
	onMethod: Behavior >> #basicNew 
	handler: h.
p1 install.
p2 := MpMethodWrapper 
	onMethod: Behavior >> #basicNew: 
	handler: h.
p2 install.
p3 := MpMethodWrapper 
	onMethod: Array class >> #new: 
	handler: h.
p3 install.

p1 uninstall.
p2 uninstall.
p3 uninstall.
```


