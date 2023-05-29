import PyPDF2
import re
import datetime as dt

# insere variaveis do arquivo 
_cPathArq   =  "C:/GPS/Meus_Projetos/Projetos_FullStack_Atuais/Extrai_PDF_Python/api-extraipdf/dados/"
_cArquivo   =  "ITAÚ - FORTALEZA LIMPEZA 02.03.pdf"	
_cOrigem	=  "PDF" 
_cBancoArq	=  "341"
_cNomBcoPg  =  "BANCO ITAU UNIBANCO"
_cAgenPag   =  ""	
_cCtaPag    =  ""	
_dDataPag   =  ""
_cDataArq   =  ""
_cHoraArq   =  ""
_cControle  =  ""
_cChvToken  =  ""

_dAgora     =  dt.datetime.now()
_cDataProc  =  _dAgora.date()
_cHoraProc  =  _dAgora.strftime("%H:%M:%S")
_cUser		=  "fabio.cardoso"	

_cEmpArq    =  ""
_CNPJArq    =  ""
_nValEfet   =  0.0 
_cNomeFun   =  ""
_cBcoFun    =  ""
_cAgFun     =  ""
_cCtaFun    =  ""

# foi necessário fazer downgrade da versão 2.0.1
text            = open(_cPathArq+_cArquivo, 'rb')

buffer          = PyPDF2.PdfFileReader(text)
number_of_pages = buffer.getNumPages()
page            = buffer.getPage(0)

c_data_pag      = ""
c_hora_pag      = ""

page_content    = page.extractText()
c_texto_limpo = ''.join(page_content)

# remove as quebras de linha
c_texto_limpo = re.sub('n', '', c_texto_limpo)

print("")
print("")

print("Origem :", _cOrigem)
print("Nome do Arquivo: ",_cArquivo)

# Extrai dado do controle/lote pagamento  
nVL     = 15 #tamanho campo valor 
nVLx    = 5 #tamanho posição após achar string  
nVL1    = c_texto_limpo.find("CTRL ") + nVLx
nVL2    = nVL1 + nVL
_cControle = c_texto_limpo[nVL1:nVL2:1]
print("Controle: ",_cControle)

print("")

_cDataArq = c_texto_limpo[0:15:1]
print("Data Documento: ",_cDataArq)

_cHoraArq = c_texto_limpo[68:76:1]
print("Hora Documento: ",_cHoraArq)

print("")


# Extrai dado do CNPJ da empresa Pagadora  
nVL     = 30 #tamanho campo valor 
nVLx    = 45 #tamanho posição após achar string  
nVL1    = c_texto_limpo.find("debitada:") + nVLx
nVL2    = nVL1 + nVL
_cEmpArq = c_texto_limpo[nVL1:nVL2:1]
print("EMPRESA: ",_cEmpArq)


# Extrai dado da agencia pagadora 
nag     = 5 #tamanho campo agencia 
nagx    = 18 #tamanho posição após achar string  
nag1    = c_texto_limpo.find("debitada:") + nagx
nag2    = nag1 + nag
_cAgenPag = c_texto_limpo[nag1:nag2:1]
print("Agencia Pag: ",_cAgenPag)


# Extrai dado da conta corrente pagadora 
nct     = 11 #tamanho campo conta 
nctx    = 28 #tamanho posição após achar string  
nct1    = c_texto_limpo.find("debitada:") + nctx
nct2    = nct1 + nct
_cCtaPag = c_texto_limpo[nct1:nct2:1]
print("Conta Pag: ",_cCtaPag)

print("")


# Extrai dado da data de pagamento
ndtp     = 8 #tamanho campo conta 
ndtpx    = 12 #tamanho posição após achar string  
ndtp1    = c_texto_limpo.find("DATA PAGTO:") + ndtpx
ndtp2    = ndtp1 + ndtp
_dDataPag = c_texto_limpo[ndtp1:ndtp2:1]
print("Data Pag: ",_dDataPag)


# Extrai dado do valor pago ao colaborador 
nVL     = 10 #tamanho campo valor 
nVLx    = 7 #tamanho posição após achar string  
nVL1    = c_texto_limpo.find("Valor:") + nVLx
nVL2    = nVL1 + nVL
_nValEfet = c_texto_limpo[nVL1:nVL2:1]
print("Valor: ",_nValEfet)


# Extrai dado do colaborador que recebe o pagamento  
nVL     = 30 #tamanho campo valor 
nVLx    = 45 #tamanho posição após achar string  
nVL1    = c_texto_limpo.find("creditada:") + nVLx
nVL2    = nVL1 + nVL
_cNomeFun = c_texto_limpo[nVL1:nVL2:1]
print("Nome Colaborador: ",_cNomeFun)

# Extrai dado da agencia creditada 
nag     = 5 #tamanho campo agencia 
nagx    = 18 #tamanho posição após achar string  
nag1    = c_texto_limpo.find("creditada:") + nagx
nag2    = nag1 + nag
_cAgFun = c_texto_limpo[nag1:nag2:1]
print("Agencia Cred: ",_cAgFun)


# Extrai dado da conta corrente creditada 
nct     = 10 #tamanho campo conta 
nctx    = 30 #tamanho posição após achar string  
nct1    = c_texto_limpo.find("creditada:") + nctx
nct2    = nct1 + nct
_cCtaFun = c_texto_limpo[nct1:nct2:1]
print("Conta Cred: ",_cCtaFun)

print("")
# Extrai dado da conta corrente creditada 
nct     = 64 #tamanho campo conta 
nctx    = 9 #tamanho posição após achar string  
nct1    = c_texto_limpo.find("ticação:") + nctx
nct2    = nct1 + nct
_cChvToken = c_texto_limpo[nct1:nct2:1]
print("Autenticação: ",_cChvToken)


print("")
print("Data Extração: ",_cDataProc)
print("Hora Extração: ",_cHoraProc)
print("Usuário Resp.: ",_cUser)


print("")
print("")
print("")
#print(c_texto_limpo)
