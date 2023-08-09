Class {
	#name : #InstrumentationDeactivator,
	#superclass : #InstrumentationEnsurer,
	#category : #Instrumentation
}

{ #category : #accessing }
InstrumentationDeactivator >> value [

	<noInstrumentation>
	Processor activeProcess shiftLevelDown
]
