#pragma ModuleName=MinTest

/////////////////////////////////////////////////////////////////////////////////
// Public Functions /////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

Function eq_var(got, want)
	Variable got, want
	add_count()
	if(got == want)
		return 1
	endif
	
	String info = func_info()
	print "---", info
	print "\tgot :", got
	print "\twant:", want
	add_log(info)
	return 0
End

Function eq_str(got, want)
	String got, want
	add_count()
	if(cmpstr(got, want) == 0)
		return 1
	endif

	String info = func_info()
	print "---", info
	print "\tgot :", got
	print "\twant:", want
	add_log(info)
	return 0
End

Function eq_wave(got, want)
	WAVE got, want
	add_count()
	Variable g0 = DimSize(got, 0), w0 = DimSize(want, 0)
	Variable g1 = DimSize(got, 1), w1 = DimSize(want, 1)
	Variable g2 = DimSize(got, 2), w2 = DimSize(want, 2)
	Variable g3 = DimSize(got, 3), w3 = DimSize(want, 3)
	Make/FREE/N=(g0, g1, g2, g3) bool = (got == want)
	if(g0 == w0 && g1 == w1 && g2 == w2 && g3 == w3 && WaveMin(bool) == 1)
		return 1
	endif

	String info = func_info()
	print "---", info
	print "\tgot :", got
	print "\twant:", want
	add_log(info)
	return 0	
End

Function eq_text(got, want)
	WAVE/T got, want
	add_count()
	Variable g0 = DimSize(got, 0), w0 = DimSize(want, 0)
	Variable g1 = DimSize(got, 1), w1 = DimSize(want, 1)
	Variable g2 = DimSize(got, 2), w2 = DimSize(want, 2)
	Variable g3 = DimSize(got, 3), w3 = DimSize(want, 3)
	Make/FREE/N=(g0, g1, g2, g3) bool = abs(cmpstr(got, want) == 0)
	if(g0 == w0 && g1 == w1 && g2 == w2 && g3 == w3 && WaveMin(bool) == 1)
		return 1
	endif

	String info = func_info()
	print "---", info
	print "\tgot :", got
	print "\twant:", want
	add_log(info)
	return 0	
End

Function run_test(function_list)
	String function_list
	init_log()
	Variable i, Ni = ItemsInList(function_list), do_test=0
	for(i=0;i<Ni;i+=1)
		String function_name = StringFromList(i,function_list)
		String test_list = FunctionList(function_name,";","NPARAMS:0")
		Variable j,Nj = ItemsInList(test_list)
		for(j = 0; j < Nj; j += 1)
			print "===", StringFromList(j,test_list)
			String test = StringFromList(j,test_list)
			Execute/Z test + "()"
			do_test = 1
		endfor
	endfor
	Variable fails = DimSize(get_log(), 0), tests = get_count()
	String cmd = "run_test(\"" + function_list + "\")"
	if(do_test)
		add_task(cmd)
		if(fails)
			print "NG! (pass " + Num2Str(tests - fails) + "/" + Num2Str(tests) + ")"
		else
			print "OK! (pass " + Num2Str(tests - fails) + "/" + Num2Str(tests) + ")"
			remove_task(cmd)
		endif
	else
		print "NO TEST"
		remove_task(cmd)
	endif
End

/////////////////////////////////////////////////////////////////////////////////
// Log Functions ////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

static Function/S func_info()
	String stacks = GetRTStackInfo(3)
	String info = StringFromList(ItemsInList(stacks)-3, stacks) 
	String win = StringFromList(1, info, ",")
	Variable line = Str2Num(StringFromList(2, info, ","))
	String text = StringFromList(line, ProcedureText("", -1, win), "\r")
	SplitString/E = "^[\\s\\t]*(.*)$" text, text
	return info + ": " + text
End


static Function/WAVE init_log()
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:MinTest
	Make/O/T/N = 0 $"root:Packages:MinTest:testlog"/WAVE = w
	return w
End

static Function add_log(s)
	String s
	WAVE/T w = root:Packages:MinTest:testlog
	if(!WaveExists(w))
		WAVE/T w = init_log()
	endif
	InsertPoints DimSize(w, 0), 1, w
	w[inf] = s
End

static Function/WAVE get_log()
	WAVE/T w = root:Packages:MinTest:testlog
	if(!WaveExists(w))
		WAVE/T w = init_log()
	endif
	return w
End

static Function init_count()
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:MinTest
	Variable/G root:Packages:MinTest:testcount = 0
End

static Function add_count()
	String s
	NVAR v = root:Packages:MinTest:testcount
	if(!NVAR_Exists(v))
		init_count()
		NVAR v = root:Packages:MinTest:testcount
	endif
	v += 1	
End

static Function get_count()
	NVAR v = root:Packages:MinTest:testcount
	return v
End

static Function/WAVE init_task()
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:MinTest
	Make/O/T/N = 0 $"root:Packages:MinTest:testlist"/WAVE = w
	return w
End

static Function add_task(cmd)
	String cmd
	remove_task(cmd)
	WAVE/T w = root:Packages:MinTest:testlist
	InsertPoints DimSize(w,0), 1, w
	w[inf] = cmd
End

static Function remove_task(cmd)
	String cmd
	WAVE/T w = root:Packages:MinTest:testlist
	if(!WaveExists(w))
		WAVE/T w = init_task()
	endif
	Extract/T/O w,w,cmpstr(w,cmd)
	w[0] = cmd
End

static Function/WAVE get_task()
	WAVE/T w = root:Packages:MinTest:testlist
	if(!WaveExists(w))
		WAVE/T w = init_task()
	endif
	return w
End

/////////////////////////////////////////////////////////////////////////////////
// Menu Functions ///////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

strconstant MinTest_Menu="Test"
Menu StringFromList(0,MinTest_Menu), dynamic
	RemoveListItem(0,MinTest_Menu)
	"(Retry"
	MinTest#MenuItemRetry(0),/Q,MinTest#MenuCommandRetry(0)
	MinTest#MenuItemRetry(1),/Q,MinTest#MenuCommandRetry(1)
	MinTest#MenuItemRetry(2),/Q,MinTest#MenuCommandRetry(2)
	MinTest#MenuItemRetry(3),/Q,MinTest#MenuCommandRetry(3)
	MinTest#MenuItemRetry(4),/Q,MinTest#MenuCommandRetry(4)
	"-"
	"(Jump"
	MinTest#MenuItemJump(0),/Q,MinTest#MenuCommandJump(0)
	MinTest#MenuItemJump(1),/Q,MinTest#MenuCommandJump(1)
	MinTest#MenuItemJump(2),/Q,MinTest#MenuCommandJump(2)
	MinTest#MenuItemJump(3),/Q,MinTest#MenuCommandJump(3)
	MinTest#MenuItemJump(4),/Q,MinTest#MenuCommandJump(4)
End

static Function/S MenuItemRetry(i)
	Variable i
	WAVE/T w = get_task()
	return SelectString(i<DimSize(w,0), "", "\M0"+w[i])
End

static Function MenuCommandRetry(i)
	Variable i
	WAVE/T w = get_task()
	print num2char(cmpstr(IgorInfo(2), "Macintosh") ? 42 : -91) + w[i]
	Execute w[i]
End

static Function/S MenuItemJump(i)
	Variable i
	WAVE/T w = get_log()
	return SelectString(i<DimSize(w,0), "", "\M0"+w[i])
End

static Function MenuCommandJump(i)
	Variable i
	WAVE/T w = get_log()
	String win,line
	SplitString/E = "^[^,]+,([^,]+),([0-9]+):" w,win,line
	DisplayProcedure/W=$win/L=(Str2Num(line))
End
