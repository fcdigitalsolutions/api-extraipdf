#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "Fileio.ch"
#INCLUDE "RPTDEF.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "Font.ch"



/*/{Protheus.doc} AGPE150
	Rotina de Retorno arquivo CNAB padrao 240 e 500 posicoes - Retorno CNAB
@Description Retorno arquivo CNAB padrao 240 e 500 posicoes - Retorno CNAB
@type  Function
@author WILLIAN GOMES SILVA
@since  14/02/2017
@version 1.0
/*/
User Function AGPE150()

	Local	_aSays     			:= {}
	Local	_aButtons  			:= {}
	Local	_cCadastro			:= OemToAnsi("Retorno Cnab GPS")

	Private _cLocRaiz			:= alltrim(U_GETGPSPAR("GPE_CNAB_COMPROV_RETORNO")) //Local onde o arquivo Texto Retorno está Salvo
	//Private _cLocRaiz			:= "C:\TEMP\teste\" // alltrim(U_GETGPSPAR("GPE_CNAB_COMPROV_RETORNO")) //Local onde o arquivo Texto Retorno está Salvo

	Private _cLocROld			:= alltrim(U_GETGPSPAR("GPE_CNAB_COMPROV_OK")) //Local onde o arquivo Texto Retorno já processado será Salvo
	Private _cLocRErro			:= alltrim(U_GETGPSPAR("GPE_CNAB_COMPROV_ERRO")) //Local onde o arquivo Texto Retorno processado com ERROS será Salvo

	private _cEmpTemp2 			:= alltrim(U_GETGPSPAR("GPE_EMPRESAS_TEMPORARIOS_ALLIS")) //CODIGO DE EMPRESAS TEMPORARIO
	private _cResTemp2 			:= ALLTRIM(U_GETGPSPAR("GPE_USER_EMP_TEMPORARIOS_ALLIS"))
	private _cResTemp  			:= ALLTRIM(U_GETGPSPAR("GPE_USER_EMP_TEMPORARIOS"))
	private _cEmpTemp 			:= alltrim(U_GETGPSPAR("GPE_EMPRESAS_TEMPORARIOS")) //CODIGO DE EMPRESAS TEMPORARIO
	private _cCodProc 			:= Iif(!Empty(U_GetParGps('GPE_COD_PROC_PERIOD_FOLHA')),Substr(alltrim(U_GetParGps('GPE_COD_PROC_PERIOD_FOLHA')),1,6),'00001' )
	private _cMvFolmes  		:= u_AGEN045(_cCodProc)

	Private _cProcess			:= "Importando arquivo..."
	Private _cArq				:= ""
	Private _aDados				:= {}
	Private cNewEmp 			:= cEmpAnt
	Private cNewFil 			:= cFilAnt
	Private _cEmpOri 			:= cEmpAnt
	Private _cFilOri 			:= cFilAnt
	Private _aQryEmpr			:= {}
	Private _aDdadosZ			:= {}

	AADD(_aSays,OemToAnsi("Este programa efetuara o retorno do arquivo CNAB."								))
	AADD(_aSays,OemToAnsi("conforme arquivo selecionado."						  							))
	AADD(_aSays,OemToAnsi("Clique no botao parametros para selecionar o arquivo."  							))
	AADD(_aButtons, { 1			,.T.	,{|o| (Processa({|| FILES034() },_cProcess),o:oWnd:End())   		}})//Chama rotina para importar o arquivo
	AADD(_aButtons, { 2			,.T.	,{|o| o:oWnd:End() 													}})

	FormBatch( _cCadastro, _aSays, _aButtons )

Return (Nil)



/*/{Protheus.doc} FILES034
	Rotina de Retorno arquivo CNAB padrao 240 e 500 posicoes - Retorno CNAB
@Description Retorno arquivo CNAB padrao 240 e 500 posicoes - Retorno CNAB
@type  Function
@author WILLIAN GOMES SILVA
@since  14/02/2017
@version 1.0
/*/
Static Function FILES034()

	Local aPastas				:= {}
	Local aFiles				:= {}
	Local aFilesTemp			:= {}
	local F_NAME				:= 1
	Local _lRet					:= .F.
	Local _nW					:= 0
	Local nY					:= 0
	Local _nX					:= 0

	Private resourceName 		:= ""
	Private path 				:= ""
	Private fileName			:= ""
	Private pathOld 			:= ""
	Private fileNOld 			:= ""
	Private pathErro 			:= ""
	Private fileNErro 			:= ""
	Private _codBanco 			:= ""

	if !MsgYesNo("Deseja efetuar o processamento dos arquivos retorno?","Retorno CNAB")
		Return (_lRet)
	endif

	aPastas	:= Directory(_cLocRaiz + "*.*", "D")

	For nY := 1 To Len (aPastas)

		aFilesTemp		:= Directory(_cLocRaiz + aPastas[nY][F_NAME] + "\*.RET", "D")
		iif(Len(aFilesTemp) > 0,aadd(aFiles, aFilesTemp),{})

		aFilesTemp		:= Directory(_cLocRaiz + aPastas[nY][F_NAME] + "\*.TXT", "D")
		iif(Len(aFilesTemp) > 0,aadd(aFiles, aFilesTemp),{})

		For _nX := 1 to Len( aFiles ) //Controla o array de tipos de arquivo.

			For _nW := 1 to Len( aFiles[_nX] ) //Controla o array de tipos de arquivo.

				_codBanco		:= aPastas[nY][F_NAME]												//Código do banco
				resourceName	:= aFiles[_nX, _nW, 1]												 	//Nome do Arquivo

				path 			:= _cLocRaiz 	+ aPastas[nY][F_NAME] + "\" 					 	//Pasta de trabalho
				pathOld			:= _cLocROld 	+ aPastas[nY][F_NAME] + "\"							//Pasta de trabalho (Old)
				pathErro		:= _cLocRErro + aPastas[nY][F_NAME] + "\"							//Pasta de trabalho (Erro)

				fileName 		:= path 	+ resourceName											//Pasta de trabalho 		+ 	Nome do Arquivo
				fileNOld 		:= pathOld 	+ resourceName											//Pasta de trabalho (Old) 	+ 	Nome do Arquivo
				fileNErro		:= pathErro	+ resourceName											//Pasta de trabalho (Erro) 	+ 	Nome do Arquivo

				_cArq 			:= fileName //Inclui o endereço e o nome do arquivo.

				_lRet 			:= Importa(_codBanco,resourceName) //lê arquivos e baixa SE2.
				_lRet 			:= GetFile2(_lRet)	// Copia arquivos para a pasta OLD (Se baixou no SE2) ou ERRO (Caso nao baixou na SE2).

			Next _nW
			_nW := 1

		Next _nX
		_nX := 1
		aFilesTemp	:= {}
		aFiles	:= {}

	Next nY

Return (_lRet)



/*/{Protheus.doc} GetFile2
	Rotina de Retorno arquivo CNAB padrao 240 e 500 posicoes - Retorno CNAB
@Description Retorno arquivo CNAB padrao 240 e 500 posicoes - Retorno CNAB
@type  Function
@author WILLIAN GOMES SILVA
@since  14/02/2017
@version 1.0
/*/
Static Function GetFile2(ErroOld)

	Local sucess		:= .F.

	/*If (!Resource2File(resourceName, fileName))
        Alert("Erro ao copiar o arquivo do repositorio!")
	EndIf*/

	if ErroOld //Processado corretamente (com baixa no financeiro inclusive)		ErroOld
		If (GetRemoteType() == REMOTE_HTML)
			sucess:= (CpyS2TW(fileName, .T.) == 0)
		Else
			sucess := AvCpyFile(fileName,fileNOld,.F.)
		Endif

	else //Não processado corretamente 		ErroOld

		If (GetRemoteType() == REMOTE_HTML)
			sucess:= (CpyS2TW(fileName, .T.) == 0)
		Else
			sucess := AvCpyFile(fileName,fileNErro,.F.)
		Endif
	endif

	if sucess //Se conseguiu copiar o arquivo retorno, deleta o arquivo original
		FErase(fileName)
	Endif

Return (sucess)



/*/{Protheus.doc} GetFile2
	Rotina que Processa arquivo de retorno - Retorno CNAB
@Description Processa arquivo de retorno - Retorno CNAB
@type  Function
@author WILLIAN GOMES SILVA
@since  14/02/2017
@version 1.0
/*/
Static Function Importa(_cBanco, _cArquivo)

	Local _cOcorPrd 			:= 	"00" //SuperGetMv("MV__OCBCO",.T.,"341,00", xFilial())
	Local _nAtual 				:= 	1
	Local _nTotal 				:= 	0
	Local _nImpAnt  			:= 	0  //Importados Anteriormente
	Local _nTotReg 				:= 	0
	Local _nTamLin 				:= 	0
	Local _cLinha 				:= 	""
	Local _cBco 				:= 	_cBanco
	Local _cAgDeb 				:= 	""
	Local _cCtaDeb 				:= 	""
	Local _cDtRet 				:= 	""
	Local _cAuxDate 			:= 	""
	Local _cHorGer 				:= 	""
	Local _cAuxHor				:= 	""
	Local _cHorCna 				:= 	""
	Local _cBcoFun 				:= 	""
	Local _cAgFun 				:= 	""
	Local _cCtaFun 				:= 	""
	Local _cDacFun 				:= 	""
	local _dDtEfet				:=  nil
	Local _nValEfet				:= 	0
	Local _cValRet 				:= 	""
	Local _cDecRet 				:= 	""
	Local _cPrevisto			:= 	""
	Local _cDecPrev 			:= 	""
	Local _nValPrev 			:= 	""
	Local _cChave 				:= 	""
	Local _cOcorre 				:= 	""
	Local _cRetBaixa 			:= 	"0"
	Local _nTotalBx				:= 	0
	Local _cTpreg				:= 	"|"
	Local _cSegmen				:= 	""
	Local _lRet					:= 	.F.
	Local _nPosic				:=  0
	Local _cCpfArq				:= " "
	Local _cBancoArq			:= ""
	Local _cNomBcoPg			:= ""
	Local _cAgenPag    			:= ""
	Local _cCtaPag     			:= ""
	Local _CNPJArq				:= ""
	Local _cEmpArq				:= ""
	Local _cChvToken			:= ""
	Local _cConvPag				:= ""
	Local _cRetorno				:= ""
	Local _cInsert				:= ""
	Local _cOrigem				:= ""

	Local _cTipoPag				:= ""
	Local _cFormPag				:= ""
	Local _cControle			:= ""
	Local _cHdLote				:= ""
	Local _dDataPag				:= ""
	Local _cDataArq				:= ""
	Local _cHoraArq				:= ""


	//Variáveis do HEader de Arquivo
	Local RET_CNPJ 				:=	{0,0} //CODIGO DO CNPJ EMPRESA
	Local RET_BANCO 			:=	{0,0} //CODIGO DO BANCO
	Local RET_TPREG 			:=	{0,0} //TIPO DE REGISTRO
	Local RET_AGENC 			:=	{0,0} //AGENCIA DO BANCO
	Local RET_CONTA 			:=	{0,0} //CONTA DO BANCO
	Local RET_DIGITO			:=	{0,0} //DIGITO DA CONTA DO BANCO
	Local RET_TPARQ				:=	{0,0} //TIPO DE ARQUIVO
	Local RET_DTGER 			:=	{0,0} //DATA DA GERACAO DO ARQUIVO
	Local RET_HRGER 			:=	{0,0} //HORA DA GERACAO DO ARQUIVO
	Local RET_NOMEEMP 	        :=	{0,0} //NOME DA EMPRESA
	Local RET_TIPPAG 	        :=	{0,0} //NOME DA EMPRESA
	Local RET_FORMPAG 	        :=	{0,0} //NOME DA EMPRESA
	//	Local RET_CONTROL 	        :=	{0,0} //NOME DA EMPRESA


	//Variáveis do Segmento A do arquivo
	Local RET_SEGMEN			:=	{0,0} //SEGMENTO DO ARQUIVO
	Local RET_CPFFUNC			:=	{0,0,0,0}//CPF DO FAVORECIDO
	Local RET_BCOFAV			:=	{0,0} //BANCO DO FAVORECIDO
	Local RET_AGFAV				:=	{0,0} //AGENCIA DO FAVORECIDO
	Local RET_CTAFAV			:=	{0,0} //CONTA DO FAVORECIDO
	Local RET_DACFAV			:=	{0,0} //DIGITO DA CONTA DO FAVORECIDO
	Local RET_OCORRE			:=	{0,0} //OCORRENCIA
	Local RET_VALPREV			:=	{0,0} //VALOR PREVISTO
	Local RET_DECPREV			:=	{0,0} //DECIMAL VALOR PREVISTO
	Local RET_DTEFET			:=	{0,0} //DATA EFETIVA DO PAGAMENTO
	Local RET_VALOR				:=	{0,0} //VALOR EFETIVO
	Local RET_DECIMAL			:=	{0,0} //DECIMAL VALOR EFETIVO
	Local RET_CHAVE				:=	{0,0} //NOSSO NUMERO
	Local RET_CTOKEN			:=	{0,0} //CODIGO TOKEN COMPROVANTE 	(Z)  //#fbc20220531
	Local RET_SEGMTZ			:=	{0,0} //CODIGO DO SEGMENTO 			(Z)  //#fbc20220531
	Local RET_CTOKNB			:=	{0,0} //CODIGO TOKEN COMPROVANTE 	(Z)  //#fbc20220531
	Local RET_NOMEFUN 	        :=	{0,0} //NOME DO FAVORECIDO


	nHandle := FT_FUse(_cArq)
	If nHandle = -1 // Se houver erro de abertura abandona processamento
		Aviso("Atencao !","Problema ao tentar abrir o arquivo !",{"Ok"})
		Return (.f.)
	EndIf

	_nTotal := FT_FLastRec() //Quantidade de Registros
	ProcRegua(_nTotal)
	FT_FGoTop() //Vai para o TOPO do Arquivo

	_nPosic  := len( FT_FReadLn() )  // Numero de posicoes do arquivo

	//Identifica qual de banco é o arquivo.
	Do Case
		Case _cBco == "001"  .and.  _nPosic == 240  	//# LAYOUT RETORNO BANCO DO BRASIL - 240 POSIÇÕES
			//Substr(FT_FReadLn(),1,3)

			// #Atualiza Variaveis do Banco
			_cOcorPrd		:= "00" 	// Pagamento Efetuado
			_cTpreg			:= "0|3"	// Tipo de registro
			_cSegmen		:= "A"		// Segmento A
			_nTamLin		:= 240  	// Retorno 240 posições
			_cSegmz			:= "Z"		// Segmento 1 equivalente ao Seg. A
			_cHdLote		:= "1"

			// #Atualiza variáveis do Header do Arquivo
			RET_CNPJ 		:=	{19,14} //CODIGO DO CNPJ EMPRESA
			RET_BANCO 		:=	{1,3} //CODIGO DO BANCO
			RET_TPREG 		:=	{8,1} //TIPO DE REGISTRO
			RET_AGENC 		:=	{53,5} //AGENCIA DO BANCO
			RET_CONTA 		:=	{59,12} //CONTA DO BANCO
			RET_DIGITO		:=	{71,1} //DIGITO DA CONTA DO BANCO
			RET_TPARQ 		:=	{143,1} //TIPO DE ARQUIVO
			RET_DTGER 		:=	{144,8,"DDMMAAAA"} //DATA DA GERACAO DO ARQUIVO
			RET_HRGER 		:=	{152,6} //HORA DA GERACAO DO ARQUIVO
			RET_NOMEEMP 	:=	{73,30} //POSIÇÕES NOME DA EMPRESA
			RET_TIPPAG 	    :=	{010,002} //NOME DA EMPRESA
			RET_FORMPAG	    :=	{012,002} //NOME DA EMPRESA


			// #Atualiza variaveis do detalhe do arquivo - Segmento A
			RET_SEGMEN 		:=	{14,1} //SEGMENTO DO ARQUIVO
			RET_BCOFAV 		:=	{21,3} //BANCO DO FAVORECIDO
			RET_AGFAV 		:=	{24,5} //AGENCIA DO FAVORECIDO
			RET_CTAFAV 		:=	{30,12} //CONTA DO FAVORECIDO
			RET_DACFAV 		:=	{42,1} //DIGITO DA CONTA DO FAVORECIDO
			RET_CHAVE 		:=	{74,20} //NOSSO NUMERO
			RET_CPFFUNC 	:=	{1,1,1,1} //CPF DO FAVORECIDO (Infor. do Seg B posição 19, porém não consta no segmento A)
			RET_VALPREV 	:=	{120,13} //VALOR PREVISTO
			RET_DECPREV 	:=	{133,2} //DECIMAL VALOR PREVISTO
			RET_DTEFET  	:=	{155,8,"DDMMAAAA"} //DATA EFETIVA DO PAGAMENTO
			RET_VALOR 		:=	{163,13} //VALOR EFETIVO
			RET_DECIMAL 	:=	{176,2} //DECIMAL VALOR EFETIVO
			RET_OCORRE 		:=	{231,10} //OCORRENCIA
			RET_NOMEFUN 	:=	{044,030} //NOME DO FAVORECIDO

			// #Atualiza variaveis do detalhe do arquivo - Segmento Z
			RET_SEGMTZ 		:=	{14,1}  //SEGMENTO DO ARQUIVO
			RET_CTOKEN 		:=	{15,64} //COMPROVANTE LEGISLAÇÃO
			RET_CTOKNB 		:=	{79,25} //COMPROVANTE BANCÁRIO

		Case _cBco == "033"  .and.  _nPosic == 240		//# LAYOUT RETORNO BANCO SANTANDER - 240 POSIÇÕES

			// #Atualiza Variaveis do Banco
			_cOcorPrd		:= "00" 	// Pagamento Efetuado
			_cTpreg			:= "0|3"	// Tipo de registro
			_cSegmen		:= "A"		// Segmento A
			_nTamLin		:= 240  	// Retorno 240 posições
			_cSegmz			:= "Z"		// Segmento 1 equivalente ao Seg. A
			_cHdLote		:= "1"

			//HEADER DE ARQUIVO
			RET_CNPJ 		:=	{19,14} //CODIGO DO CNPJ EMPRESA
			RET_BANCO 		:=	{1,3} //CODIGO DO BANCO
			RET_TPREG 		:=	{8,1} //TIPO DE REGISTRO
			RET_AGENC 		:=	{53,5} //AGENCIA DO BANCO
			RET_CONTA 		:=	{59,12} //CONTA DO BANCO
			RET_DIGITO		:=	{71,1} //DIGITO DA CONTA DO BANCO
			RET_TPARQ 		:=	{143,1} //TIPO DE ARQUIVO
			RET_DTGER 		:=	{144,8,"DDMMAAAA"} //DATA DA GERACAO DO ARQUIVO
			RET_HRGER 		:=	{152,6} //HORA DA GERACAO DO ARQUIVO
			RET_NOMEEMP 	:=	{73,30} //POSIÇÕES NOME DA EMPRESA
			RET_TIPPAG 	    :=	{010,002} //NOME DA EMPRESA
			RET_FORMPAG	    :=	{012,002} //NOME DA EMPRESA


			//DETALHE SEGMENTO A
			RET_SEGMEN 		:=	{14,1} //SEGMENTO DO ARQUIVO
			RET_BCOFAV 		:=	{21,3} //BANCO DO FAVORECIDO
			RET_AGFAV 		:=	{24,5} //AGENCIA DO FAVORECIDO
			RET_CTAFAV 		:=	{30,12} //CONTA DO FAVORECIDO
			RET_DACFAV 		:=	{42,1} //DIGITO DA CONTA DO FAVORECIDO
			RET_CHAVE 		:=	{74,20} //NOSSO NUMERO
			RET_CPFFUNC 	:=	{178,9,187,2} //CPF DO FAVORECIDO (Infor. do Seg B posição 19, porém consta no item Outras Informações Pos. 178)
			RET_VALPREV 	:=	{120,13} //VALOR PREVISTO
			RET_DECPREV 	:=	{133,2} //DECIMAL VALOR PREVISTO
			RET_DTEFET  	:=	{94,8,"DDMMAAAA"} //DATA EFETIVA DO PAGAMENTO
			RET_VALOR 		:=	{120,13} //VALOR EFETIVO
			RET_DECIMAL 	:=	{133,2} //DECIMAL VALOR EFETIVO
			RET_OCORRE 		:=	{231,10} //OCORRENCIA
			RET_NOMEFUN 	:=	{044,030} //NOME DO FAVORECIDO

			// #Atualiza variaveis do detalhe do arquivo - Segmento Z
			RET_SEGMTZ 		:=	{14,1}  //SEGMENTO DO ARQUIVO
			RET_CTOKEN 		:=	{15,64} //COMPROVANTE LEGISLAÇÃO
			RET_CTOKNB 		:=	{79,25} //COMPROVANTE BANCÁRIO

		Case _cBco == "341"  .and.  _nPosic == 240		//# LAYOUT RETORNO ITAU - 240 POSIÇÕES

			// #Atualiza Variaveis do Banco
			_cOcorPrd 		:= "00|EM"	// Pagamento Efetuado
			_cTpreg			:= "0|3"	// Tipo de registro
			_cSegmen		:= "A"		// Segmento A
			_nTamLin		:= 240  	// Retorno 240 posições
			_cSegmz			:= "Z"		// Segmento 1 equivalente ao Seg. A
			_cHdLote		:= "1"

			//HEADER DE ARQUIVO
			RET_CNPJ 		:=	{19,14} //CODIGO DO CNPJ EMPRESA
			RET_BANCO 		:=	{1,3} //CODIGO DO BANCO
			RET_TPREG 		:=	{8,1} //TIPO DE REGISTRO
			RET_AGENC 		:=	{53,5} //AGENCIA DO BANCO
			RET_CONTA 		:=	{59,12} //CONTA DO BANCO
			RET_DIGITO		:=	{72,1} //DIGITO DA CONTA DO BANCO
			RET_TPARQ 		:=	{143,1} //TIPO DE ARQUIVO
			RET_DTGER 		:=	{144,8,"DDMMAAAA"} //DATA DA GERACAO DO ARQUIVO
			RET_HRGER 		:=	{152,6} //HORA DA GERACAO DO ARQUIVO
			RET_NOMEEMP 	:=	{73,30} //POSIÇÕES NOME DA EMPRESA
			RET_TIPPAG 	    :=	{010,002} //NOME DA EMPRESA
			RET_FORMPAG	    :=	{012,002} //NOME DA EMPRESA


			//DETALHE SEGMENTO A
			RET_SEGMEN 		:=	{14,1} //SEGMENTO DO ARQUIVO
			RET_BCOFAV 		:=	{21,3} //BANCO DO FAVORECIDO
			RET_AGFAV 		:=	{24,5} //AGENCIA DO FAVORECIDO
			RET_CTAFAV 		:=	{36,6} //CONTA DO FAVORECIDO
			RET_DACFAV 		:=	{43,1} //DIGITO DA CONTA DO FAVORECIDO
			RET_CHAVE 		:=	{74,20} //NOSSO NUMERO
			RET_VALPREV 	:=	{120,13} //VALOR PREVISTO
			RET_DECPREV 	:=	{133,2} //DECIMAL VALOR PREVISTO
			RET_DTEFET  	:=	{155,8,"DDMMAAAA"} //DATA EFETIVA DO PAGAMENTO
			RET_VALOR 		:=	{163,13} //VALOR EFETIVO
			RET_DECIMAL 	:=	{176,2} //DECIMAL VALOR EFETIVO
			RET_CPFFUNC 	:=	{207,9,216,2}//CPF DO FAVORECIDO
			RET_OCORRE 		:=	{231,10} //OCORRENCIA
			RET_NOMEFUN 	:=	{044,030} //NOME DO FAVORECIDO

			// #Atualiza variaveis do detalhe do arquivo - Segmento Z
			RET_SEGMTZ 		:=	{14,1}  //SEGMENTO DO ARQUIVO
			//RET_CTOKEN 	:=	{15,64} //COMPROVANTE LEGISLAÇÃO
			//RET_CTOKNB 	:=	{79,25} //COMPROVANTE BANCÁRIO
			RET_CTOKNB 		:=	{15,64} //COMPROVANTE BANCÁRIO

		Case _cBco == "237" .and.  _nPosic == 500		//# LAYOUT RETORNO BANCO BRADESCO - 500 POSIÇÕES

			//Atualiza Variaveis do Banco
			_cOcorPrd 		:= "BW"	// Pagamento Efetuado
			_cTpreg			:= "0|1"	// Tipo de Registro
			_cSegmen		:= "1"		// Segmento 1 equivalente ao Seg. A
			_nTamLin		:= 500  	// Retorno 500 posições
			_cSegmz			:= "Z"		// Segmento 1 equivalente ao Seg. A
			_cHdLote		:= "1"

			//HEADER DE ARQUIVO
			RET_CNPJ 		:=	{12,14} //CODIGO DO CNPJ EMPRESA
			RET_TPREG 		:=	{1,1} //TIPO DE REGISTRO
			RET_DTGER 		:=	{79,8,"AAAAMMDD"} //DATA DA GERACAO DO ARQUIVO
			RET_HRGER 		:=	{87,6} //HORA DA GERACAO DO ARQUIVO
			RET_TPARQ 		:=	{106,1} //TIPO DE ARQUIVO
			RET_BANCO 		:=	{96,3} //CODIGO DO BANCO
			RET_AGENC 		:=	{110,5} //AGENCIA DO BANCO
			RET_CONTA 		:=	{115,12} //CONTA DO BANCO
			RET_DIGITO		:=	{127,1} //DIGITO DA CONTA DO BANCO
			RET_NOMEEMP 	:=	{73,30} //POSIÇÕES NOME DA EMPRESA
			RET_TIPPAG 	    :=	{010,002} //NOME DA EMPRESA
			RET_FORMPAG	    :=	{012,002} //NOME DA EMPRESA



			//DETALHE SEGMENTO A
			RET_SEGMEN 		:=	{1,1} //SEGMENTO DO ARQUIVO --Não tem a Letra A, mas o tipo de registro 1 é equivalente ao Seg. A
			RET_BCOFAV 		:=	{96,3} //BANCO DO FAVORECIDO
			RET_AGFAV 		:=	{99,5} //AGENCIA DO FAVORECIDO
			RET_CTAFAV 		:=	{105,13} //CONTA DO FAVORECIDO
			RET_DACFAV 		:=	{118,1} //DIGITO DA CONTA DO FAVORECIDO
			RET_CHAVE 		:=	{416,20} //NOSSO NUMERO
			RET_CPFFUNC 	:=	{3,9,16,2} //CPF DO FAVORECIDO (Infor. do Seg B posição 19, porém consta no item Outras Informações Pos. 178)
			RET_VALPREV 	:=	{205,13} //VALOR PREVISTO
			RET_DECPREV 	:=	{218,2} //DECIMAL VALOR PREVISTO
			RET_DTEFET  	:=	{166,8,"AAAAMMDD"} //DATA EFETIVA DO PAGAMENTO
			RET_VALOR 		:=	{205,13} //VALOR EFETIVO
			RET_DECIMAL 	:=	{218,2} //DECIMAL VALOR EFETIVO
			RET_OCORRE 		:=	{279,10} //OCORRENCIA
			RET_NOMEFUN 	:=	{044,030} //NOME DO FAVORECIDO

			// #Atualiza variaveis do detalhe do arquivo - Segmento Z
			RET_SEGMTZ 		:=	{14,1}  //SEGMENTO DO ARQUIVO
			RET_CTOKEN 		:=	{15,64} //COMPROVANTE LEGISLAÇÃO
			RET_CTOKNB 		:=	{79,25} //COMPROVANTE BANCÁRIO

			/*/ #fbc20220414 - Retorno de novos layouts     /*/
		Case _cBco == "237" .and.  _nPosic == 240		//# LAYOUT RETORNO BANCO BRADESCO - 240 POSIÇÕES
			//Atualiza Variaveis do Banco
			_cOcorPrd 		:= "00|BW"	// Pagamento Efetuado
			_cTpreg			:= "0|3"	// Tipo de Registro
			_cSegmen		:= "A"		// Segmento 1 equivalente ao Seg. A
			_nTamLin		:= 240  	// Retorno 500 posições
			_cSegmz			:= "Z"		// Segmento 1 equivalente ao Seg. A
			_cHdLote		:= "1"


			//#### HEADER DE ARQUIVO
			RET_BANCO 		:=	{001,003} //CODIGO DO BANCO
			RET_TPREG 		:=	{008,001} //TIPO DE REGISTRO
			RET_CNPJ 		:=	{019,014} //CODIGO DO CNPJ EMPRESA
			RET_AGENC 		:=	{053,005} //AGENCIA DO BANCO
			RET_CONTA 		:=	{059,012} //CONTA DO BANCO
			RET_DIGITO		:=	{071,001} //DIGITO DA CONTA DO BANCO
			RET_TPARQ 		:=	{143,001} //CODIGO DE REMESSA DO ARQUIVO
			RET_DTGER 		:=	{144,008,"DDMMAAAA"} //DATA DA GERACAO DO ARQUIVO
			RET_HRGER 		:=	{152,006} //HORA DA GERACAO DO ARQUIVO
			RET_NOMEEMP 	:=	{73,30} //POSIÇÕES NOME DA EMPRESA
			RET_TIPPAG 	    :=	{010,002} //NOME DA EMPRESA
			RET_FORMPAG	    :=	{012,002} //NOME DA EMPRESA


			//### DETALHE SEGMENTO A
			RET_SEGMEN 		:=	{014,001} //SEGMENTO DO ARQUIVO --Não tem a Letra A, mas o tipo de registro 1 é equivalente ao Seg. A
			RET_BCOFAV 		:=	{021,003} //BANCO DO FAVORECIDO
			RET_AGFAV 		:=	{024,005} //AGENCIA DO FAVORECIDO
			RET_CTAFAV 		:=	{030,012} //CONTA DO FAVORECIDO
			RET_DACFAV 		:=	{042,001} //DIGITO DA CONTA DO FAVORECIDO
			RET_CHAVE 		:=	{074,020} //NOSSO NUMERO
			RET_DTEFET  	:=	{094,008,"DDMMAAAA"} //DATA EFETIVA DO PAGAMENTO
			RET_VALPREV 	:=	{120,013} //VALOR PREVISTO
			RET_DECPREV 	:=	{133,002} //DECIMAL VALOR PREVISTO
			RET_VALOR 		:=	{120,013} //VALOR EFETIVO
			RET_DECIMAL 	:=	{133,002} //DECIMAL VALOR EFETIVO
			RET_CPFFUNC 	:=	{207,9,216,2} //CPF DO FAVORECIDO (Infor. do Seg B, porém consta no item Outras Informações)
			RET_OCORRE 		:=	{231,010} //OCORRENCIA
			RET_NOMEFUN 	:=	{044,030} //NOME DO FAVORECIDO

			// #Atualiza variaveis do detalhe do arquivo - Segmento Z
			RET_SEGMTZ 		:=	{14,1}  //SEGMENTO DO ARQUIVO
			RET_CTOKEN 		:=	{15,64} //COMPROVANTE LEGISLAÇÃO
			RET_CTOKNB 		:=	{79,25} //COMPROVANTE BANCÁRIO

			/*/ #fbc20220414 - Retorno de novos layouts     /*/
		Case _cBco == "041" .and.  _nPosic == 240		//# LAYOUT RETORNO BANCO BANRISUL - 240 POSIÇÕES
			//Atualiza Variaveis do Banco
			_cOcorPrd 		:= "00|BW"	// Pagamento Efetuado
			_cTpreg			:= "0|3"	// Tipo de Registro
			_cSegmen		:= "A"		// Segmento 1 equivalente ao Seg. A
			_nTamLin		:= 240  	// Retorno 500 posições
			_cSegmz			:= "Z"		// Segmento 1 equivalente ao Seg. A
			_cHdLote		:= "1"

			//#### HEADER DE ARQUIVO
			RET_BANCO 		:=	{001,003} //CODIGO DO BANCO
			RET_TPREG 		:=	{008,001} //TIPO DE REGISTRO
			RET_CNPJ 		:=	{019,014} //CODIGO DO CNPJ EMPRESA
			RET_AGENC 		:=	{053,005} //AGENCIA DO BANCO
			RET_CONTA 		:=	{059,012} //CONTA DO BANCO
			RET_DIGITO		:=	{071,001} //DIGITO DA CONTA DO BANCO
			RET_TPARQ 		:=	{143,001} //CODIGO DE REMESSA DO ARQUIVO
			RET_DTGER 		:=	{144,008,"DDMMAAAA"} //DATA DA GERACAO DO ARQUIVO
			RET_HRGER 		:=	{152,006} //HORA DA GERACAO DO ARQUIVO
			RET_NOMEEMP 	:=	{73,30} //POSIÇÕES NOME DA EMPRESA
			RET_TIPPAG 	    :=	{010,002} //NOME DA EMPRESA
			RET_FORMPAG	    :=	{012,002} //NOME DA EMPRESA


			//### DETALHE SEGMENTO A
			RET_SEGMEN 		:=	{014,001} //SEGMENTO DO ARQUIVO --Não tem a Letra A, mas o tipo de registro 1 é equivalente ao Seg. A
			RET_BCOFAV 		:=	{021,003} //BANCO DO FAVORECIDO
			RET_AGFAV 		:=	{024,005} //AGENCIA DO FAVORECIDO
			RET_CTAFAV 		:=	{030,012} //CONTA DO FAVORECIDO
			RET_DACFAV 		:=	{042,001} //DIGITO DA CONTA DO FAVORECIDO
			RET_CHAVE 		:=	{074,020} //NOSSO NUMERO
			RET_DTEFET  	:=	{094,008,"DDMMAAAA"} //DATA EFETIVA DO PAGAMENTO
			RET_VALPREV 	:=	{120,013} //VALOR PREVISTO
			RET_DECPREV 	:=	{133,002} //DECIMAL VALOR PREVISTO
			RET_VALOR 		:=	{120,013} //VALOR EFETIVO
			RET_DECIMAL 	:=	{133,002} //DECIMAL VALOR EFETIVO
			RET_CPFFUNC 	:=	{207,9,216,2} //CPF DO FAVORECIDO (Infor. do Seg B, porém consta no item Outras Informações)
			RET_OCORRE 		:=	{231,010} //OCORRENCIA
			RET_NOMEFUN 	:=	{044,030} //NOME DO FAVORECIDO


			// #Atualiza variaveis do detalhe do arquivo - Segmento Z
			RET_SEGMTZ 		:=	{14,1}  //SEGMENTO DO ARQUIVO
			RET_CTOKEN 		:=	{15,64} //COMPROVANTE LEGISLAÇÃO
			RET_CTOKNB 		:=	{79,25} //COMPROVANTE BANCÁRIO


			/*/ #fbc20220414 - Retorno de novos layouts     /*/
		Case _cBco == "133" .and.  _nPosic == 240		//# LAYOUT RETORNO BANCO CRESOL - 240 POSIÇÕES
			//Atualiza Variaveis do Banco
			_cOcorPrd 		:= "00|BW"	// Pagamento Efetuado
			_cTpreg			:= "0|3"	// Tipo de Registro
			_cSegmen		:= "A"		// Segmento 1 equivalente ao Seg. A
			_nTamLin		:= 240  	// Retorno 500 posições
			_cSegmz			:= "Z"		// Segmento 1 equivalente ao Seg. A
			_cHdLote		:= "1"


			//#### HEADER DE ARQUIVO
			RET_BANCO 		:=	{001,003} //CODIGO DO BANCO
			RET_TPREG 		:=	{008,001} //TIPO DE REGISTRO
			RET_CNPJ 		:=	{019,014} //CODIGO DO CNPJ EMPRESA
			RET_AGENC 		:=	{053,005} //AGENCIA DO BANCO
			RET_CONTA 		:=	{059,012} //CONTA DO BANCO
			RET_DIGITO		:=	{071,001} //DIGITO DA CONTA DO BANCO
			RET_TPARQ 		:=	{143,001} //CODIGO DE REMESSA DO ARQUIVO
			RET_DTGER 		:=	{144,008,"DDMMAAAA"} //DATA DA GERACAO DO ARQUIVO
			RET_HRGER 		:=	{152,006} //HORA DA GERACAO DO ARQUIVO
			RET_NOMEEMP 	:=	{73,30} //POSIÇÕES NOME DA EMPRESA
			RET_TIPPAG 	    :=	{010,002} //NOME DA EMPRESA
			RET_FORMPAG	    :=	{012,002} //NOME DA EMPRESA


			//### DETALHE SEGMENTO A
			RET_SEGMEN 		:=	{014,001} //SEGMENTO DO ARQUIVO --Não tem a Letra A, mas o tipo de registro 1 é equivalente ao Seg. A
			RET_BCOFAV 		:=	{021,003} //BANCO DO FAVORECIDO
			RET_AGFAV 		:=	{024,005} //AGENCIA DO FAVORECIDO
			RET_CTAFAV 		:=	{030,012} //CONTA DO FAVORECIDO
			RET_DACFAV 		:=	{042,001} //DIGITO DA CONTA DO FAVORECIDO
			RET_CHAVE 		:=	{074,020} //NOSSO NUMERO
			RET_DTEFET  	:=	{094,008,"DDMMAAAA"} //DATA EFETIVA DO PAGAMENTO
			RET_VALPREV 	:=	{120,013} //VALOR PREVISTO
			RET_DECPREV 	:=	{133,002} //DECIMAL VALOR PREVISTO
			RET_VALOR 		:=	{120,013} //VALOR EFETIVO
			RET_DECIMAL 	:=	{133,002} //DECIMAL VALOR EFETIVO
			RET_CPFFUNC 	:=	{207,9,216,2} //CPF DO FAVORECIDO (Infor. do Seg B, porém consta no item Outras Informações)
			RET_OCORRE 		:=	{231,010} //OCORRENCIA
			RET_NOMEFUN 	:=	{044,030} //NOME DO FAVORECIDO

			// #Atualiza variaveis do detalhe do arquivo - Segmento Z
			RET_SEGMTZ 		:=	{14,1}  //SEGMENTO DO ARQUIVO
			RET_CTOKEN 		:=	{15,64} //COMPROVANTE LEGISLAÇÃO
			RET_CTOKNB 		:=	{79,25} //COMPROVANTE BANCÁRIO


			/*/ #fbc20220414 - Retorno de novos layouts     /*/
		Case _cBco == "756" .and.  _nPosic == 240		//# LAYOUT RETORNO BANCO SICOOB - 240 POSIÇÕES
			//Atualiza Variaveis do Banco
			_cOcorPrd 		:= "00|BW"	// Pagamento Efetuado
			_cTpreg			:= "0|3"	// Tipo de Registro
			_cSegmen		:= "A"		// Segmento 1 equivalente ao Seg. A
			_nTamLin		:= 240  	// Retorno 500 posições
			_cSegmz			:= "Z"		// Segmento 1 equivalente ao Seg. A
			_cHdLote		:= "1"


			//#### HEADER DE ARQUIVO
			RET_BANCO 		:=	{001,003} //CODIGO DO BANCO
			RET_TPREG 		:=	{008,001} //TIPO DE REGISTRO
			RET_CNPJ 		:=	{019,014} //CODIGO DO CNPJ EMPRESA
			RET_AGENC 		:=	{053,005} //AGENCIA DO BANCO
			RET_CONTA 		:=	{059,012} //CONTA DO BANCO
			RET_DIGITO		:=	{071,001} //DIGITO DA CONTA DO BANCO
			RET_TPARQ 		:=	{143,001} //CODIGO DE REMESSA DO ARQUIVO
			RET_DTGER 		:=	{144,008,"DDMMAAAA"} //DATA DA GERACAO DO ARQUIVO
			RET_HRGER 		:=	{152,006} //HORA DA GERACAO DO ARQUIVO
			RET_NOMEEMP 	:=	{73,30} //POSIÇÕES NOME DA EMPRESA
			RET_TIPPAG 	    :=	{010,002} //NOME DA EMPRESA
			RET_FORMPAG	    :=	{012,002} //NOME DA EMPRESA


			//### DETALHE SEGMENTO A
			RET_SEGMEN 		:=	{014,001} //SEGMENTO DO ARQUIVO --Não tem a Letra A, mas o tipo de registro 1 é equivalente ao Seg. A
			RET_BCOFAV 		:=	{021,003} //BANCO DO FAVORECIDO
			RET_AGFAV 		:=	{025,004} //AGENCIA DO FAVORECIDO
			RET_CTAFAV 		:=	{036,006} //CONTA DO FAVORECIDO
			RET_DACFAV 		:=	{042,001} //DIGITO DA CONTA DO FAVORECIDO
			RET_CHAVE 		:=	{074,020} //NOSSO NUMERO
			RET_DTEFET  	:=	{094,008,"DDMMAAAA"} //DATA EFETIVA DO PAGAMENTO
			RET_VALPREV 	:=	{120,013} //VALOR PREVISTO
			RET_DECPREV 	:=	{133,002} //DECIMAL VALOR PREVISTO
			RET_VALOR 		:=	{120,013} //VALOR EFETIVO
			RET_DECIMAL 	:=	{133,002} //DECIMAL VALOR EFETIVO
			RET_CPFFUNC 	:=	{207,9,216,2} //CPF DO FAVORECIDO (Infor. do Seg B, porém consta no item Outras Informações)
			RET_OCORRE 		:=	{231,010} //OCORRENCIA
			RET_NOMEFUN 	:=	{044,030} //NOME DO FAVORECIDO

			// #Atualiza variaveis do detalhe do arquivo - Segmento Z
			RET_SEGMTZ 		:=	{14,1}  //SEGMENTO DO ARQUIVO
			RET_CTOKEN 		:=	{15,64} //COMPROVANTE LEGISLAÇÃO
			RET_CTOKNB 		:=	{79,25} //COMPROVANTE BANCÁRIO


			/*/ #fbc20220414 - Retorno de novos layouts     /*/
		Case _cBco == "748" .and.  _nPosic == 240		//# LAYOUT RETORNO BANCO SICREDI - 240 POSIÇÕES
			//Atualiza Variaveis do Banco
			_cOcorPrd 		:= "00|BW"	// Pagamento Efetuado
			_cTpreg			:= "0|3"	// Tipo de Registro
			_cSegmen		:= "A"		// Segmento 1 equivalente ao Seg. A
			_nTamLin		:= 240  	// Retorno 500 posições
			_cSegmz			:= "Z"		// Segmento 1 equivalente ao Seg. A
			_cHdLote		:= "1"

			//#### HEADER DE ARQUIVO
			RET_BANCO 		:=	{001,003} //CODIGO DO BANCO
			RET_TPREG 		:=	{008,001} //TIPO DE REGISTRO
			RET_CNPJ 		:=	{019,014} //CODIGO DO CNPJ EMPRESA
			RET_AGENC 		:=	{053,005} //AGENCIA DO BANCO
			RET_CONTA 		:=	{059,012} //CONTA DO BANCO
			RET_DIGITO		:=	{071,001} //DIGITO DA CONTA DO BANCO
			RET_TPARQ 		:=	{143,001} //CODIGO DE REMESSA DO ARQUIVO
			RET_DTGER 		:=	{144,008,"DDMMAAAA"} //DATA DA GERACAO DO ARQUIVO
			RET_HRGER 		:=	{152,006} //HORA DA GERACAO DO ARQUIVO
			RET_NOMEEMP 	:=	{73,30} //POSIÇÕES NOME DA EMPRESA
			RET_TIPPAG 	    :=	{010,002} //NOME DA EMPRESA
			RET_FORMPAG	    :=	{012,002} //NOME DA EMPRESA


			//### DETALHE SEGMENTO A
			RET_SEGMEN 		:=	{014,001} //SEGMENTO DO ARQUIVO --Não tem a Letra A, mas o tipo de registro 1 é equivalente ao Seg. A
			RET_BCOFAV 		:=	{021,003} //BANCO DO FAVORECIDO
			RET_AGFAV 		:=	{024,005} //AGENCIA DO FAVORECIDO
			RET_CTAFAV 		:=	{030,012} //CONTA DO FAVORECIDO
			RET_DACFAV 		:=	{042,001} //DIGITO DA CONTA DO FAVORECIDO
			RET_CHAVE 		:=	{074,020} //NOSSO NUMERO
			RET_DTEFET  	:=	{094,008,"DDMMAAAA"} //DATA EFETIVA DO PAGAMENTO
			RET_VALPREV 	:=	{120,013} //VALOR PREVISTO
			RET_DECPREV 	:=	{133,002} //DECIMAL VALOR PREVISTO
			RET_VALOR 		:=	{120,013} //VALOR EFETIVO
			RET_DECIMAL 	:=	{133,002} //DECIMAL VALOR EFETIVO
			RET_CPFFUNC 	:=	{207,9,216,2} //CPF DO FAVORECIDO (Infor. do Seg B, porém consta no item Outras Informações)
			RET_OCORRE 		:=	{231,010} //OCORRENCIA
			RET_NOMEFUN 	:=	{044,030} //NOME DO FAVORECIDO


			// #Atualiza variaveis do detalhe do arquivo - Segmento Z
			RET_SEGMTZ 		:=	{14,1}  //SEGMENTO DO ARQUIVO
			RET_CTOKEN 		:=	{15,64} //COMPROVANTE LEGISLAÇÃO
			RET_CTOKNB 		:=	{79,25} //COMPROVANTE BANCÁRIO


			/*/ #fbc20220414 - Retorno de novos layouts     /*/
		Case _cBco == "077" .and.  _nPosic == 240		//# LAYOUT RETORNO BANCO INTER - 240 POSIÇÕES
			//Atualiza Variaveis do Banco
			_cOcorPrd 		:= "00|BW"	// Pagamento Efetuado
			_cTpreg			:= "0|3"	// Tipo de Registro
			_cSegmen		:= "A"		// Segmento 1 equivalente ao Seg. A
			_nTamLin		:= 240  	// Retorno 500 posições
			_cSegmz			:= "Z"		// Segmento 1 equivalente ao Seg. A
			_cHdLote		:= "1"


			//#### HEADER DE ARQUIVO
			RET_BANCO 		:=	{001,003} //CODIGO DO BANCO
			RET_TPREG 		:=	{008,001} //TIPO DE REGISTRO
			RET_CNPJ 		:=	{019,014} //CODIGO DO CNPJ EMPRESA
			RET_AGENC 		:=	{053,005} //AGENCIA DO BANCO
			RET_CONTA 		:=	{059,012} //CONTA DO BANCO
			RET_DIGITO		:=	{071,001} //DIGITO DA CONTA DO BANCO
			RET_TPARQ 		:=	{143,001} //CODIGO DE REMESSA DO ARQUIVO
			RET_DTGER 		:=	{144,008,"DDMMAAAA"} //DATA DA GERACAO DO ARQUIVO
			RET_HRGER 		:=	{152,006} //HORA DA GERACAO DO ARQUIVO
			RET_NOMEEMP 	:=	{73,30} //POSIÇÕES NOME DA EMPRESA
			RET_TIPPAG 	    :=	{010,002} //NOME DA EMPRESA
			RET_FORMPAG	    :=	{012,002} //NOME DA EMPRESA


			//### DETALHE SEGMENTO A
			RET_SEGMEN 		:=	{014,001} //SEGMENTO DO ARQUIVO --Não tem a Letra A, mas o tipo de registro 1 é equivalente ao Seg. A
			RET_BCOFAV 		:=	{021,003} //BANCO DO FAVORECIDO
			RET_AGFAV 		:=	{024,005} //AGENCIA DO FAVORECIDO
			RET_CTAFAV 		:=	{030,012} //CONTA DO FAVORECIDO
			RET_DACFAV 		:=	{042,001} //DIGITO DA CONTA DO FAVORECIDO
			RET_CHAVE 		:=	{074,020} //NOSSO NUMERO
			RET_DTEFET  	:=	{094,008,"DDMMAAAA"} //DATA EFETIVA DO PAGAMENTO
			RET_VALPREV 	:=	{120,013} //VALOR PREVISTO
			RET_DECPREV 	:=	{133,002} //DECIMAL VALOR PREVISTO
			RET_VALOR 		:=	{120,013} //VALOR EFETIVO
			RET_DECIMAL 	:=	{133,002} //DECIMAL VALOR EFETIVO
			RET_CPFFUNC 	:=	{207,9,216,2} //CPF DO FAVORECIDO (Infor. do Seg B, porém consta no item Outras Informações)
			RET_OCORRE 		:=	{231,010} //OCORRENCIA
			RET_NOMEFUN 	:=	{044,030} //NOME DO FAVORECIDO

			// #Atualiza variaveis do detalhe do arquivo - Segmento Z
			RET_SEGMTZ 		:=	{14,1}  //SEGMENTO DO ARQUIVO
			RET_CTOKEN 		:=	{15,64} //COMPROVANTE LEGISLAÇÃO
			RET_CTOKNB 		:=	{79,25} //COMPROVANTE BANCÁRIO


			/*/ #fbc20220414 - Retorno de novos layouts     /*/
		Case _cBco == "104" .and.  _nPosic == 240		//# LAYOUT RETORNO BANCO CAIXA - 240 POSIÇÕES
			//Atualiza Variaveis do Banco
			_cOcorPrd 		:= "00|BW"	// Pagamento Efetuado
			_cTpreg			:= "0|1"	// Tipo de Registro
			_cSegmen		:= "A"		// Segmento 1 equivalente ao Seg. A
			_nTamLin		:= 240  	// Retorno 500 posições
			_cSegmz			:= "Z"		// Segmento 1 equivalente ao Seg. A
			_cHdLote		:= "1"


			//#### HEADER DE ARQUIVO
			RET_BANCO 		:=	{001,003} //CODIGO DO BANCO
			RET_TPREG 		:=	{008,001} //TIPO DE REGISTRO
			RET_CNPJ 		:=	{019,014} //CODIGO DO CNPJ EMPRESA
			RET_AGENC 		:=	{053,005} //AGENCIA DO BANCO
			RET_CONTA 		:=	{059,012} //CONTA DO BANCO
			RET_DIGITO		:=	{071,001} //DIGITO DA CONTA DO BANCO
			RET_TPARQ 		:=	{143,001} //CODIGO DE REMESSA DO ARQUIVO
			RET_DTGER 		:=	{144,008,"DDMMAAAA"} //DATA DA GERACAO DO ARQUIVO
			RET_HRGER 		:=	{152,006} //HORA DA GERACAO DO ARQUIVO
			RET_NOMEEMP 	:=	{73,30} //POSIÇÕES NOME DA EMPRESA
			RET_TIPPAG 	    :=	{010,002} //NOME DA EMPRESA
			RET_FORMPAG	    :=	{012,002} //NOME DA EMPRESA


			//### DETALHE SEGMENTO A
			RET_SEGMEN 		:=	{014,001} //SEGMENTO DO ARQUIVO --Não tem a Letra A, mas o tipo de registro 1 é equivalente ao Seg. A
			RET_BCOFAV 		:=	{021,003} //BANCO DO FAVORECIDO
			RET_AGFAV 		:=	{024,005} //AGENCIA DO FAVORECIDO
			RET_CTAFAV 		:=	{030,012} //CONTA DO FAVORECIDO
			RET_DACFAV 		:=	{042,001} //DIGITO DA CONTA DO FAVORECIDO
			//	RET_CHAVE 		:=	{074,006} //NOSSO NUMERO - id cnab
			RET_CHAVE 		:=	{074,013} //NOSSO NUMERO - id cnab
			RET_DTEFET  	:=	{094,008,"DDMMAAAA"} //DATA EFETIVA DO PAGAMENTO
			RET_VALPREV 	:=	{120,013} //VALOR PREVISTO
			RET_DECPREV 	:=	{133,002} //DECIMAL VALOR PREVISTO
			RET_VALOR 		:=	{120,013} //VALOR EFETIVO
			RET_DECIMAL 	:=	{133,002} //DECIMAL VALOR EFETIVO
			RET_CPFFUNC 	:=	{207,9,216,2} //CPF DO FAVORECIDO (Infor. do Seg B, porém consta no item Outras Informações)
			RET_OCORRE 		:=	{231,010} //OCORRENCIA
			RET_NOMEFUN 	:=	{044,030} //NOME DO FAVORECIDO

			// #Atualiza variaveis do detalhe do arquivo - Segmento Z
			RET_SEGMTZ 		:=	{14,1}  //SEGMENTO DO ARQUIVO
			RET_CTOKEN 		:=	{15,64} //COMPROVANTE LEGISLAÇÃO
			RET_CTOKNB 		:=	{79,25} //COMPROVANTE BANCÁRIO

			/*/ #fbc20220414 - Retorno de novos layouts     /*/
		Case _cBco == "104" .and.  _nPosic == 150		//# LAYOUT RETORNO BANCO CAIXA - 240 POSIÇÕES
			//Atualiza Variaveis do Banco
			_cOcorPrd 		:= "00|BW"	// Pagamento Efetuado
			_cTpreg			:= "0|1"	// Tipo de Registro
			_cSegmen		:= "A"		// Segmento 1 equivalente ao Seg. A
			_nTamLin		:= 240  	// Retorno 500 posições
			_cSegmz			:= "Z"		// Segmento 1 equivalente ao Seg. A
			_cHdLote		:= "1"


			//#### HEADER DE ARQUIVO
			RET_BANCO 		:=	{001,003} //CODIGO DO BANCO
			RET_TPREG 		:=	{008,001} //TIPO DE REGISTRO
			RET_CNPJ 		:=	{019,014} //CODIGO DO CNPJ EMPRESA
			RET_AGENC 		:=	{053,005} //AGENCIA DO BANCO
			RET_CONTA 		:=	{059,012} //CONTA DO BANCO
			RET_DIGITO		:=	{071,001} //DIGITO DA CONTA DO BANCO
			RET_TPARQ 		:=	{143,001} //CODIGO DE REMESSA DO ARQUIVO
			RET_DTGER 		:=	{144,008,"AAAAMMDD"} //DATA DA GERACAO DO ARQUIVO
			RET_HRGER 		:=	{152,006} //HORA DA GERACAO DO ARQUIVO
			RET_NOMEEMP 	:=	{73,30} //POSIÇÕES NOME DA EMPRESA
			RET_TIPPAG 	    :=	{010,002} //NOME DA EMPRESA
			RET_FORMPAG	    :=	{012,002} //NOME DA EMPRESA


			//### DETALHE SEGMENTO A
			RET_SEGMEN 		:=	{014,001} //SEGMENTO DO ARQUIVO --Não tem a Letra A, mas o tipo de registro 1 é equivalente ao Seg. A
			RET_BCOFAV 		:=	{021,003} //BANCO DO FAVORECIDO
			RET_AGFAV 		:=	{024,005} //AGENCIA DO FAVORECIDO
			RET_CTAFAV 		:=	{030,012} //CONTA DO FAVORECIDO
			RET_DACFAV 		:=	{042,001} //DIGITO DA CONTA DO FAVORECIDO
			RET_CHAVE 		:=	{074,006} //NOSSO NUMERO - id cnab
			RET_DTEFET  	:=	{094,008,"AAAAMMDD"} //DATA EFETIVA DO PAGAMENTO
			RET_VALPREV 	:=	{120,013} //VALOR PREVISTO
			RET_DECPREV 	:=	{133,002} //DECIMAL VALOR PREVISTO
			RET_VALOR 		:=	{120,013} //VALOR EFETIVO
			RET_DECIMAL 	:=	{133,002} //DECIMAL VALOR EFETIVO
			RET_CPFFUNC 	:=	{207,9,216,2} //CPF DO FAVORECIDO (Infor. do Seg B, porém consta no item Outras Informações)
			RET_OCORRE 		:=	{231,010} //OCORRENCIA
			RET_NOMEFUN 	:=	{002,025} //NOME DO FAVORECIDO

			// #Atualiza variaveis do detalhe do arquivo - Segmento Z
			RET_SEGMTZ 		:=	{14,1}  //SEGMENTO DO ARQUIVO
			RET_CTOKEN 		:=	{15,64} //COMPROVANTE LEGISLAÇÃO
			RET_CTOKNB 		:=	{79,25} //COMPROVANTE BANCÁRIO


			/*/ #fbc20220414 - Retorno de novos layouts     /*/
		Case _cBco == "340" .and.  _nPosic == 240		//# LAYOUT RETORNO BANCO BRADESCO - 240 POSIÇÕES
			//Atualiza Variaveis do Banco
			_cOcorPrd 		:= "00|BW"	// Pagamento Efetuado
			_cTpreg			:= "0|3"	// Tipo de Registro
			_cSegmen		:= "A"		// Segmento 1 equivalente ao Seg. A
			_nTamLin		:= 240  	// Retorno 500 posições
			_cSegmz			:= "Z"		// Segmento 1 equivalente ao Seg. A
			_cHdLote		:= "1"


			//#### HEADER DE ARQUIVO
			RET_BANCO 		:=	{001,003} //CODIGO DO BANCO
			RET_TPREG 		:=	{008,001} //TIPO DE REGISTRO
			RET_CNPJ 		:=	{019,014} //CODIGO DO CNPJ EMPRESA
			RET_AGENC 		:=	{053,005} //AGENCIA DO BANCO
			RET_CONTA 		:=	{059,012} //CONTA DO BANCO
			RET_DIGITO		:=	{071,001} //DIGITO DA CONTA DO BANCO
			RET_TPARQ 		:=	{143,001} //CODIGO DE REMESSA DO ARQUIVO
			RET_DTGER 		:=	{144,008,"DDMMAAAA"} //DATA DA GERACAO DO ARQUIVO
			RET_HRGER 		:=	{152,006} //HORA DA GERACAO DO ARQUIVO
			RET_NOMEEMP 	:=	{73,30} //POSIÇÕES NOME DA EMPRESA
			RET_TIPPAG 	    :=	{010,002} //NOME DA EMPRESA
			RET_FORMPAG	    :=	{012,002} //NOME DA EMPRESA


			//### DETALHE SEGMENTO A
			RET_SEGMEN 		:=	{014,001} //SEGMENTO DO ARQUIVO --Não tem a Letra A, mas o tipo de registro 1 é equivalente ao Seg. A
			RET_BCOFAV 		:=	{021,003} //BANCO DO FAVORECIDO
			RET_AGFAV 		:=	{024,005} //AGENCIA DO FAVORECIDO
			RET_CTAFAV 		:=	{030,012} //CONTA DO FAVORECIDO
			RET_DACFAV 		:=	{042,001} //DIGITO DA CONTA DO FAVORECIDO
			RET_CHAVE 		:=	{074,020} //NOSSO NUMERO
			RET_DTEFET  	:=	{094,008,"DDMMAAAA"} //DATA EFETIVA DO PAGAMENTO
			RET_VALPREV 	:=	{120,013} //VALOR PREVISTO
			RET_DECPREV 	:=	{133,002} //DECIMAL VALOR PREVISTO
			RET_VALOR 		:=	{120,013} //VALOR EFETIVO
			RET_DECIMAL 	:=	{133,002} //DECIMAL VALOR EFETIVO
			RET_CPFFUNC 	:=	{207,9,216,2} //CPF DO FAVORECIDO (Infor. do Seg B, porém consta no item Outras Informações)
			RET_OCORRE 		:=	{231,010} //OCORRENCIA
			RET_NOMEFUN 	:=	{044,030} //NOME DO FAVORECIDO

			// #Atualiza variaveis do detalhe do arquivo - Segmento Z
			RET_SEGMTZ 		:=	{14,1}  //SEGMENTO DO ARQUIVO
			RET_CTOKEN 		:=	{15,64} //COMPROVANTE LEGISLAÇÃO
			RET_CTOKNB 		:=	{79,25} //COMPROVANTE BANCÁRIO

			//MsgAlert("Dentro do Laço -> Codigo do Banco: "+_cBco + "  Layout em posicoes: " + str(_nPosic) + "	Ocorrencia arquivo: " + _cOcorPrd)

		OTHERWISE

			Aviso("Atencao !","Arquivo selecionado não é um arquivo de retorno! (BANCO N LOCALIZADO)",{"Ok"})
			FT_FUSE()
			Return (.F.)

	EndCase

	_cLinha  := FT_FReadLn() // Retorna a linha corrente

	While !FT_FEOF()

		IncProc("Importando registros...				" + Alltrim(Str(_nAtual++)) + "/				" + Alltrim(Str(_nTotal )))//Incrementa a regua
		_cLinha  := FT_FReadLn() // Retorna a linha corrente

		If Len(_cLinha)<> _nTamLin //Verifica tamanho do arquivo 240 ou 500 posicoes
			FT_FUSE()
			Aviso("Atencao !","Arquivo selecionado não contem 240 ou 500 posições!",{"Ok"})
			Return (.F.)
		EndIf

		//Verifica se e um arquivo de retorno
		If Substr(_cLinha,RET_TPARQ[1],RET_TPARQ[2]) == "1" .AND. Substr(_cLinha,RET_TPREG[1],RET_TPREG[2]) == "0"
			FT_FUSE()
			Aviso("Atencao !","Arquivo selecionado não é um arquivo de retorno! (ERRO NA LINHA) ",{"Ok"})
			Return (.F.)
		EndIf

		//Informacoes GERAIS HEADER DE ARQUIVO
		If Substr(_cLinha,RET_TPREG[1],RET_TPREG[2]) == "0"

			_cAgDeb		:= Substr(_cLinha,RET_AGENC[1],RET_AGENC[2])							//NUMERO AGENCIA MANTENEDORA
			_cCtaDeb	:= Substr(_cLinha,RET_CONTA[1],RET_CONTA[2])							//NUMERO DE C/C DEBITADA

			_cAuxDate		:= Substr(_cLinha,RET_DTGER[1],RET_DTGER[2])								//DATA DA GERACAO DO ARQUIVO

			//Tratando o campo data
			If     (RET_DTGER[3] == "DDMMAAAA")	//Para AAAAMMDD
				_cDtRet	:= SubStr(_cAuxDate,5,4)+SubStr(_cAuxDate,3,2)+SubStr(_cAuxDate,1,2)
			ElseIf(RET_DTGER[3] == "AAAAMMDD") 	//Para AAAAMMDD
				_cDtRet	:= _cAuxDate
			Endif

			_cAuxHor		:= Substr(_cLinha,RET_HRGER[1],RET_HRGER[2])								//HORA DA GERACAO DO ARQUIVO
			_cHorGer		:= Substr(_cAuxHor,1,2)+":"+Substr(_cAuxHor,3,2)+":"+Substr(_cAuxHor,5,2)
			_cHorCna		:= TIME()

			_cBancoArq		:= Substr(_cLinha,RET_BANCO[1],RET_BANCO[2])							//NUMERO DE C/C DEBITADA
			_cNomBcoPg		:= POSICIONE("SA6",1,xFilial("SA6")+_cBancoArq, "A6_NOME")
			_cAgenPag    	:= Substr(_cLinha,RET_AGENC[1],RET_AGENC[2])
			_cCtaPag        := Substr(_cLinha,RET_CONTA[1],RET_CONTA[2])
			_CNPJArq		:= Substr(_cLinha,RET_CNPJ[1],RET_CNPJ[2])
			_cEmpArq		:= Substr(_cLinha,RET_NOMEEMP[1],RET_NOMEEMP[2])

		EndIf

		//Informacoes GERAIS HEADER DO LOTE
		If Substr(_cLinha,RET_TPREG[1],RET_TPREG[2]) $ 	_cHdLote
			_cTipoPag		:= Substr(_cLinha,RET_TIPPAG[1],RET_TIPPAG[2])
			_cFormPag		:= Substr(_cLinha,RET_FORMPAG[1],RET_FORMPAG[2])
		EndIf

		//Processa apenas registros de detalhes (Segmento A ou 1)
		If Substr(_cLinha,RET_SEGMEN[1],RET_SEGMEN[2]) == _cSegmen

			_nTotReg++

			_cBcoFun 	:= ALLTRIM(SubStr(_cLinha,RET_BCOFAV[1],RET_BCOFAV[2]))  		// Banco Favorecido
			_cAgFun  	:= ALLTRIM(SubStr(_cLinha,RET_AGFAV[1] ,RET_AGFAV[2] ))  		// Agencia Favorecido
			_cCtaFun 	:= ALLTRIM(SubStr(_cLinha,RET_CTAFAV[1],RET_CTAFAV[2]))  		// Conta Favorecido
			_cDacFun 	:= ALLTRIM(SubStr(_cLinha,RET_DACFAV[1],RET_DACFAV[2]))  		// Dac Favorecido
			_cOcorre 	:= ALLTRIM(SubStr(_cLinha,RET_OCORRE[1],RET_OCORRE[2]))  		// Ocorrencia Retorno
			_cPrevisto 	:= ALLTRIM(SubStr(_cLinha,RET_VALPREV[1],RET_VALPREV[2]))	// Valor Previsto
			_cDecPrev 	:= ALLTRIM(SubStr(_cLinha,RET_DECPREV[1],RET_DECPREV[2]))	// Decimal Valor Previsto
			_nValPrev 	:= STR(Val(_cPrevisto+"."+_cDecPrev))
			_cAuxDate  	:= ALLTRIM(SubStr(_cLinha,RET_DTEFET[1],RET_DTEFET[2]))		// Data efetiva do pagamento

			_cCpfArq	:= ALLTRIM(SubStr(_cLinha,RET_CPFFUNC[1],RET_CPFFUNC[2])) + ALLTRIM(SubStr(_cLinha,RET_CPFFUNC[3],RET_CPFFUNC[4]))   // cpf do arquivo segmento A
			_cNomeFun	:= ALLTRIM(SubStr(_cLinha,RET_NOMEFUN[1],RET_NOMEFUN[2]))

			//Tratando o campo data
			If     (RET_DTEFET[3] == "DDMMAAAA")	//Para AAAAMMDD
				_dDtEfet	:= SubStr(_cAuxDate,5,4)+SubStr(_cAuxDate,3,2)+SubStr(_cAuxDate,1,2)
			ElseIf (RET_DTEFET[3] == "AAAAMMDD") 	//Para AAAAMMDD
				_dDtEfet	:= _cAuxDate
			Endif

			_cValRet 	:= ALLTRIM(SubStr(_cLinha,RET_VALOR[1],RET_VALOR[2]))			// Valor Efetivo
			_cDecRet 	:= ALLTRIM(SubStr(_cLinha,RET_DECIMAL[1],RET_DECIMAL[2]))		// Decimal Valor Efetivo
			_nValEfet 	:= Val(_cValRet+"."+_cDecRet)
			_nTotalBx	+= _nValEfet 														// Total acumulado
			_cChave		:= ALLTRIM(SubStr(_cLinha,RET_CHAVE[1],RET_CHAVE[2]))		// Chave (Nosso Numero)
			_cFilArq	:= SUBSTR(_cChave,3,2)

			//#fbc20220531 - Bloco de tratamento do comprovante de retorno bancario - SEGMENTO Z
		ElseIf  Substr(_cLinha,RET_SEGMEN[1],RET_SEGMEN[2]) == _cSegmz
			_cChvToken		:= ALLTRIM(SubStr(_cLinha,RET_CTOKNB[1],RET_CTOKNB[2]))
			_cOrigem		:=	"ARQ"
			_cRetorno		:= " "
			_cInsert 		:= ""
			_cHoraProc		:=	TIME()
			_cDataProc		:=	Dtos( Date() )
			_cUser			:=	cUserName
			_dDataPag		:=  _dDtEfet
			_cDataArq		:=  _cDtRet
			_cHoraArq		:=  _cHorGer

			if !fExistToken(_cChvToken,_cOrigem,_cBancoArq, _cCpfArq)
				//
				_cInsert := " INSERT ZBX010(ZBX_FILIAL, ZBX_EMPPAG, ZBX_CNPARQ, ZBX_IDBCO ,ZBX_ORIGEM,			" + CRLF
				_cInsert += " ZBX_BCOARQ, ZBX_CHVINT,ZBX_AGEPAG,ZBX_CTAPAG,ZBX_TIPPAG,ZBX_FORPAG,ZBX_CONV,		" + CRLF
				_cInsert += " ZBX_CPFBEN, ZBX_NOMBEN,ZBX_BCOBEN,ZBX_AGEBEN,ZBX_CTABEN,ZBX_VALOR ,ZBX_DATPAG,	" + CRLF
				_cInsert += " ZBX_DATARQ, ZBX_HORARQ, ZBX_CHVBCO,ZBX_CONTRL,ZBX_HPROCE,ZBX_DPROCE,ZBX_ARQUIV,	" + CRLF
				_cInsert += " ZBX_USER,R_E_C_N_O_) 															 	" + CRLF
				//
				_cInsert += " VALUES( " + CRLF
				_cInsert += "'"+ _cFilArq			+ "'," + CRLF    //ZT_FILIAL
				_cInsert += "'"+ _cEmpArq       	+ "'," + CRLF    //ZT_TABELA
				_cInsert += "'"+ _CNPJArq       	+ "'," + CRLF    //ZT_TABELA
				_cInsert += "'"+ _cNomBcoPg       	+ "'," + CRLF    //_cChave
				_cInsert += "'"+ _cOrigem			+ "'," + CRLF    //ZT_TITULO
				_cInsert += "'"+ _cBancoArq			+ "'," + CRLF    //ZT_PREFIXO
				_cInsert += "'"+ _cChave	  	    + "'," + CRLF    //ZT_PARCELA
				_cInsert += "'"+ _cAgenPag       	+ "'," + CRLF    //_cChave
				_cInsert += "'"+ _cCtaPag       	+ "'," + CRLF    //_cChave
				_cInsert += "'"+ _cTipoPag       	+ "'," + CRLF    //_cChave
				_cInsert += "'"+ _cFormPag       	+ "'," + CRLF    //_cChave
				_cInsert += "'"+ _cConvPag       	+ "'," + CRLF    //_cChave
				_cInsert += "'"+ _cCpfArq       	+ "'," + CRLF    //_cChave
				_cInsert += "'"+ _cNomeFun       	+ "'," + CRLF    //_cChave
				_cInsert += "'"+ _cBcoFun       	+ "'," + CRLF    //_cChave
				_cInsert += "'"+ _cAgFun       		+ "'," + CRLF    //_cChave
				_cInsert += "'"+ _cCtaFun       	+ "'," + CRLF    //_cChave
				_cInsert += "'"+ cValtochar(_nValEfet)       	+ "'," + CRLF    //_cChave
				_cInsert += "'"+ _dDataPag     		+ "'," + CRLF    //_cChave
				_cInsert += "'"+ _cDataArq     		+ "'," + CRLF    //_cChave
				_cInsert += "'"+ _cHoraArq       	+ "'," + CRLF    //_cChave
				_cInsert += "'"+ _cChvToken       	+ "'," + CRLF    //_cChave
				_cInsert += "'"+ _cControle       	+ "'," + CRLF    //_cChave
				_cInsert += "'"+ _cHoraProc       	+ "'," + CRLF    //_cChave
				_cInsert += "'"+ _cDataProc       	+ "'," + CRLF    //_cChave
				_cInsert += "'"+ _cArquivo       	+ "'," + CRLF    //_cChave
				_cInsert += "'"+ _cUser		       	+ "'," + CRLF    //_cChave
				_cInsert += "(SELECT CASE WHEN MAX(R_E_C_N_O_) IS NULL THEN 1 ELSE MAX(R_E_C_N_O_) + 1 END FROM ZBX010(NOLOCK))" + ")" + CRLF    //RECNO
				//
				TcSqlExec(_cInsert)

			EndIF

		Else

			_nImpAnt++
			IIf(Select("qTempZ")>0,qTempZ->(dbCloseArea()),Nil)
			FT_FSKIP()
			Loop
			//Incluir LOG aqui.

		EndIf

		FT_FSKIP()

	EndDo


	FT_FUSE()

	//Se a geração do relatório estiver OK e a baixa na SE2 ocorrer com exito, a operação foi bem sucedida. .T.
	_lRet := iif(_cRetBaixa == "0", .T., .F. )

Return (_lRet)



/*/{Protheus.doc} fExistToken
	Rotina que valida a existencia do token de autenticação do banco ao reprocessar arquivos - Retorno CNAB
@Description Valida a existencia do token de autenticação do banco ao reprocessar arquivos
@type  Function
@author Fabio Cardoso
@since  23/03/2022
@version 1.0
/*/
Static Function fExistToken(_cChvToken,_cOrigem,_cBancoArq, _cCpfArq)

	Local _lRet		:= .F.
	Local _cQry		:= ""
	Local _cChav2	:= alltrim(_cChvToken)+alltrim(_cOrigem)+alltrim(_cBancoArq)+alltrim(_cCpfArq)

	_cQry := " select ZBX_CHVBCO,ZBX_ORIGEM, ZBX_BCOARQ, ZBX_CPFBEN  from ZBX010		"   + CRLF
	_cQry += " zbx (nolock)																"   + CRLF
	_cQry += " where zbx.D_E_L_E_T_ = '' 			 									"   + CRLF
	_cQry += " and zbx.ZBX_CHVBCO 	    =  '" + Alltrim(_cChvToken)		+ "'			"   + CRLF
	_cQry += " and zbx.ZBX_ORIGEM	 	=  '" + Alltrim(_cOrigem)		+ "'			"   + CRLF
	_cQry += " and zbx.ZBX_BCOARQ	 	=  '" + Alltrim(_cBancoArq)		+ "'			"   + CRLF
	_cQry += " and zbx.ZBX_CPFBEN	 	=  '" + Alltrim( _cCpfArq)		+ "'			"   + CRLF
	_cQry += " order by zbx.ZBX_CHVBCO,zbx.ZBX_ORIGEM,zbx.ZBX_BCOARQ,zbx.ZBX_CPFBEN		"   + CRLF
	_cQry += " 													 						"   + CRLF

	IIf(Select("qTemp")>0,qTemp->(dbCloseArea()),Nil)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQry),"qTemp",.F.,.T.)

	qTemp->( dbGotop() )
	While qTemp->( !Eof() )

		If _cChav2 == qTemp->( alltrim(ZBX_CHVBCO)+alltrim(ZBX_ORIGEM)+alltrim(ZBX_BCOARQ)+alltrim(ZBX_CPFBEN))
			_lRet  := .T.
		Endif
		qTemp->( DbSkip() )

	EndDo
	IIf(Select("qTemp")>0,qTemp->(dbCloseArea()),Nil)

Return(_lRet)

