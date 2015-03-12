(* ::Package:: *)

(* ::Title:: *)
(*QuantumUtils for Mathematica*)
(*QUDevTools*)


(* ::Subsection::Closed:: *)
(*Copyright and License Information*)


(* ::Text:: *)
(*This package is part of QuantumUtils for Mathematica.*)
(**)
(*Copyright (c) 2015 and later, Christopher J. Wood, Christopher E. Granade, Ian N. Hincks*)
(**)
(*Redistribution and use in source and binary forms, with or withoutmodification, are permitted provided that the following conditions are met:*)
(*1. Redistributions of source code must retain the above copyright notice, this  list of conditions and the following disclaimer.*)
(*2. Redistributions in binary form must reproduce the above copyright notice,  this list of conditions and the following disclaimer in the documentation  and/or other materials provided with the distribution.*)
(*3. Neither the name of quantum-utils-mathematica nor the names of its  contributors may be used to endorse or promote products derived from  this software without specific prior written permission.*)
(**)
(*THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THEIMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE AREDISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLEFOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIALDAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS ORSERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVERCAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USEOF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.*)


(* ::Subsection:: *)
(*Preamble*)


BeginPackage["QUDevTools`"];


(* ::Subsection:: *)
(*Note*)


(* ::Text:: *)
(*Because this package defines LoadUsages and AssignUsage, functions from this package cannot (easily) be documented in the way that other packages are with auxilliary notebooks.*)


(* ::Section:: *)
(*Usage Declaration*)


(* ::Subsection::Closed:: *)
(*QuantumUtils Options*)


QuantumUtilsOptions::usage = "QuantumUtilsOptions[] returns a list of options, formatted as Rules, that configure the QuantumUtils` package.";
$QUDocumentationPath::usage = "$QUDocumentationPath returns the path to documentation for QuantumUtils`.";
$QUSourcePath::usage = "$QUDocumentationPath returns the path to the source folder for QuantumUtils`.";


(* ::Subsection::Closed:: *)
(*Function Options*)


InheritOptions::usage = "InheritOptions[fn_, {baseFns__}, newOptions_] defines options for fn by adding the options for each of the symbols listed in baseFns, along with new and possibly overriden options defined in newOptions.";


FilterOptions::usage = "FilterOptions[function, opt1, opt2, opt3,...] returns a Sequence of those options in opt1,opt2,... which are Options of the given function.
FilterOptions[{function1,function2,...}, opt1, opt2, opt3,...] returns a Sequence of those options in opt1,opt2,... which are Options of any of the given functions.";


(* ::Subsection::Closed:: *)
(*Creating Tables*)


DescriptiveTable::usage = "DescriptiveTable[headers,content,OptionsPattern[GridBox]] generates a new cell containing a table. The first row of the table contains the header strings provided in headers in bold font. The rest of the table is filled in with content.";
DescriptiveFillInTable::usage = "DescriptiveFillInTable[headers,rows,OptionsPattern[GridBox]] invokes DescriptiveTable to generate a new cell containing a table. The first row of the table contains the header strings provided in headers in bold font. The rest of the table has the given number of rows, with each table element a placeholder.";


DisplayOptions::usage = "DisplayOptions[TargetFunction] prints a human readable cell describing the options of a given function. Assumes all options have usage text.";


(* ::Subsection::Closed:: *)
(*Usage Strings*)


(*
	The AssignUsage function is heavily based on StackExchange:
    http://mathematica.stackexchange.com/questions/3941/managing-formatted-usage-messages-in-wolfram-workbench
*)


Attributes[AssignUsage] = {HoldFirst};


LoadUsages::usage = "LoadUsages[nbName] loads usage strings from a tagged cells in notebook, such that the strings can later be applied using AssignUsage[]. For more details, see the examples in doc/.";
UsageData::usage = "UsageData[] represents usage strings loaded using LoadUsages[].";
AssignUsage::usage = "AssignUsage[symbol, usageData] sets symbol::usage to be drawn from the usage data usageData made by running LoadUsages[] with a name corresponding to symbol.
AssignUsage[codeSymbol->docSymbol, usageData] sets codeSymbol::usage to be drawn from the usage data usageData made by running LoadUsages[] with a name corresponding to docSymbol.
AssignUsage[{a1,a2,a3,...}, usageData] calls AssignUsage[a, usageData] on each  of the a's.";


(* ::Subsection::Closed:: *)
(*Links*)


NotebookLink::usage = "NotebookLink[notebookFile_,name_,description_] generates a cell containing a link to another notebook, with a description.";


(* ::Subsection::Closed:: *)
(*Messages*)


AssignUsage::nousg = "No usage message in `1` for symbol `2` found; using a blank message instead.";


(* ::Section:: *)
(*Implementation*)


Begin["`Private`"];


(* ::Subsection::Closed:: *)
(*QuantumUtils Options*)


QuantumUtilsOptions[] := QuantumUtilsOptions[] = Module[{opts},
	opts = QuantumUtilsOptions /. Options[$FrontEnd];
	If[
		opts === QuantumUtilsOptions,
		{},
		opts
	]
]


$QUDocumentationPath = DocumentationPath /. QuantumUtilsOptions[];
$QUSourcePath = SourcePath /. QuantumUtilsOptions[];


(* ::Subsection::Closed:: *)
(*Function Options*)


InheritOptions[fn_,{baseFns__},newOptions_]:=(
	Options[fn]=DeleteDuplicates[Join[
	newOptions,
	Sequence@@Map[Options,{baseFns}]
	],First@#1==First@#2&];
)


FilterOptions[function_,options___]:=Apply[Sequence, FilterRules[{options},Options[function]]]
FilterOptions[{function__},options___]:=Apply[Sequence, FilterRules[{options},Options/@{function}]]


(* ::Subsection::Closed:: *)
(*Tables*)


(* ::Subsubsection:: *)
(*Descriptive Tables*)


DescriptiveTable[headers_,content_,opt:OptionsPattern[GridBox]]:=Module[{headStyle},
	headStyle[str_]:=StyleBox[str,Bold,"Text"];
	CellPrint@Cell[
		BoxData[
			GridBox[
				Prepend[
					content,
					headStyle/@headers
				],
				opt,
				GridBoxAlignment -> {"Columns" -> {{Left}}},
				GridBoxDividers->{"Rows"->{{True}},"Columns"->{{False}}}
			]
		], 
		"Text"
	]
]


DescriptiveFillInTable[headers_,rows_,opt:OptionsPattern[GridBox]]:=DescriptiveTable[headers,ConstantArray["\[Placeholder]",{rows,Length@headers}],opt]


(* ::Subsubsection:: *)
(*Displaying Options*)


DisplayOptions[TargetFunction_]:=Module[{options,headers,content,textFormat,opt},
	options=Options@TargetFunction;
	headers={"Option","Default Value","Description"};
	textFormat[option_]:=Module[{box},
		Which[
			Head[option]===String,
				StyleBox["No description available.","Text"],
			Head[option::usage]===MessageName,
				StyleBox["No description available.","Text"],
			Head[option::usage]===String,
				StyleBox[option::usage,"Text"],
			True,
				ToBoxes[option::usage]
		]
	];
	content={MakeBoxes[#1],MakeBoxes[#2],textFormat[#1]}&@@@options;
	opt=ColumnWidths->{Automatic,Automatic,Scaled[.5]};
	DescriptiveTable[headers,content,opt]
]


(* ::Subsection::Closed:: *)
(*Usage Strings*)


LoadUsages[nbName_] := Module[{notebook, usageData, processCell, possibleBoxToString},
	notebook = Quiet[Get[nbName]];

	possibleBoxToString[elem_]:=If[StringQ[elem],
		elem,
		ToString[
		DisplayForm[elem]/.StyleBox[boxes_,"Input",args___]:>StyleBox[boxes,"Input",FontFamily->"Courier",args],
		StandardForm]
	];

	processCell[contents_]:=If[
		StringQ[contents],
		contents,
		StringJoin@Map[possibleBoxToString,First@contents,1]
	];

	If[\[Not](notebook === $Failed),
		usageData = Cases[notebook,
			Cell[contents_, ___, CellTags -> tag_, ___] /;
				StringMatchQ[tag, __ ~~ "::usage"] :>
			(
				StringReplace[tag, "::usage" -> ""] -> 
				processCell[contents]
			),
		Infinity];

		UsageData @@ usageData,

		UsageData[]
	]
]


Format[usageData_UsageData] := Interpretation[UsageData, "UsageData"][Interpretation[
	Grid[List@@List@@@usageData, Alignment -> Left],
	Null]
]


AssignUsage[codeSymb_Symbol->docSymb_Symbol, usageData_UsageData] := Module[{docName},
	docName = SymbolName @ Unevaluated[docSymb];
	If[FreeQ[usageData, (docName -> _)],
		Message[AssignUsage::nousg, usageData, HoldForm[docSymb]];
		MessageName[docSymb, "usage"] = "";
		$Failed,

		MessageName[codeSymb, "usage"] = docName /. List @@ usageData
	]
]

AssignUsage[symb_Symbol, usageData_UsageData] := AssignUsage[symb->symb,usageData];

AssignUsage[{s:(__Rule|__Symbol)}, usageData_UsageData] := Map[AssignUsage[#, usageData]&, {s}];


(* ::Subsection::Closed:: *)
(*Links*)


NotebookLink[notebookFile_,name_,description_]:=Module[{headStyle},
	headStyle[str_]:=StyleBox[str,Bold,"Text"];
	CellPrint@Cell[
		BoxData[
			GridBox[
				{{
					StyleBox[ToBoxes@Hyperlink[name,notebookFile],Bold,"Text"],
					StyleBox[description,"Text"]
				}},
				GridBoxAlignment -> {"Columns" -> {{Left}}},
				GridBoxDividers->{"Rows"->{{False}},"Columns"->{{False}}},
				ColumnWidths->{Scaled[0.15],Scaled[.7]}
			]
		], 
		"Text"
	]
]


(* ::Subsection::Closed:: *)
(*End Private*)


End[];


(* ::Section:: *)
(*Links*)


(* ::Section::Closed:: *)
(*End Package*)


EndPackage[];