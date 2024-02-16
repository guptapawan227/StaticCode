<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.newgen.wfdesktop.xmlapi.*,com.newgen.wfdesktop.session.WFSession" %>
<%@ page import="com.newgen.wfdesktop.util.*" %>
<%@ page import ="com.newgen.omni.wf.util.excp.*"%>
<%@ page import ="com.newgen.omni.jts.cmgr.*"%>
<%@ page import ="com.newgen.aproj2.template.*"%>
<%@ page import ="java.util.*"%>
<%@ page import ="java.io.*"%>
<%@ page import ="ISPack.CPISDocumentTxn"%>
<%@ page import ="ISPack.ISUtil.*"%>
<%@ page import ="java.text.DateFormat,java.util.GregorianCalendar,java.util.Calendar" %>
<%@ page import ="ISPack.ISUtil.*"%>
<%@ page import ="java.util.regex.Matcher"%>
<%@ page import ="java.text.SimpleDateFormat"%>
<%@ page import ="org.jsoup.Jsoup"%>
<%@ page import ="com.openhtmltopdf.DOMBuilder"%>
<%@ page import="com.openhtmltopdf.pdfboxout.PdfRendererBuilder" %>
<%@ include file="/generic/wdcustominit.jsp"%>
<%@ page import="com.newgen.omni.wf.util.app.NGEjbClient" %>
<%!
	String pbfHtml = null;
	String pbfHtml1 = null;
	String add_type=null;
	String workStepName = null;
	String workitemName = null;
	String debugSwitch = "";
%>
<%
	String resultHtml="";
	String processName = null;
	//String workitemName = null;
	String templateCode = null;
	String unitNo = null;
	String disbursementNo = null;
	String outputXml = "";
	int folderIndex = -1;
	long lFileLength;
	int iNoOfPages = 1;
	int volumeId = 1;
	int jtsPort = 0;
	String sIpAddress = null;
	String cabinetName = null;
	String docIndex = "";
	int sessionId = -1;
	String groupIndex = "0";
	String processDefId = "0";
	File fileObj = null;
	XMLParser parserObj = null;
	XMLParser parserObj1 = null;
	XMLParser xmlParser = null;
	XMLParser xmlParserName = null;
	String templatePath = null;
	String destinationPath = null;
	String viewer = null;
	String templateName = null;
	String documentName = null;
	String extTemplate = null;
	String blankVal = "&nbsp;";
	ReadXmlData readxmldata = null;
	ReadXmlData rdXmldataObj = null;
	ReadXmlData rdXmlDataObj = null;
	BusinessValidation businessvalidation = null;
	ArrayList arrlist = null;
	ArrayList arrGridlist = null;
	ArrayList arrExtlist = null;
	String extTblName = null;
	boolean adddocument = false;
	boolean readstatus = false;
	Properties propObj = null;
	Long startTime;
	Long timeDiff;
	String workStepName = null;
	String imageIndex = null;
	// Added by Mohit on 24Jul15 for Cibil where clause handling
	String requestorType = ""; 
	String CUSTOMER_ID = "";
	String requestorId = "";
	String addnlWhereClause ="";
	String addnlWhereClause_new ="";
	String comments = "";
	String generatedHTML = "";
	boolean GridFlag;
	String addnlWhereClauseGrid="";
	String sSessionId="";
	String OwnerName = "";
	WDCabinetInfo wDCabinetInfo;
	String propertiesFilepath = "";
	String listViewFilePath = "";
	String htmlFilePath = "";
	String xmlFilePath = "";
	String tableMappingXmlPath = "";
	try
	{  
		workitemName = request.getParameter("WI_NAME");
		System.out.println("Mohit-Board Note Start");
		processName = request.getParameter("PROCESS_NAME");
		templateCode = request.getParameter("TEMPLATE_CODE");
		workStepName = request.getParameter("WORK_STEP");
		requestorType = request.getParameter("REQUESTOR_TYPE");
		CUSTOMER_ID = request.getParameter("CUSTOMER_ID");
		requestorId = request.getParameter("REQUESTOR_ID");
		comments = request.getParameter("COMMENTS");
		documentName = request.getParameter("DOCUMENT_NAME");
		if(processName.equalsIgnoreCase("noc") || processName.equalsIgnoreCase("noc_qa")){
			unitNo = request.getParameter("UNIT_NO");
		}
		else{
			unitNo= null;
		}
		if(processName.equalsIgnoreCase("disbursement") || processName.equalsIgnoreCase("Disbursement_qa")){
			disbursementNo = request.getParameter("DISBURSEMENT_NO");
		}
		else{
			disbursementNo= null;
		}
		//Long startTime1 = System.currentTimeMillis();
		//pbfHtml = request.getParameter("abs");
		//pbfHtml1 = request.getParameter("abs1");
		Long startTime1 = System.currentTimeMillis();
		pbfHtml = request.getParameter("abs");
		try{
			if(null != wDSession && null != wDSession.getM_objUserInfo()) {
				sSessionId = wDSession.getM_objUserInfo().getM_strSessionId();
				wDCabinetInfo = wDSession.getM_objCabinetInfo();
				cabinetName = wDCabinetInfo.getM_strCabinetName();
				jtsPort = Integer.parseInt(wDCabinetInfo.getM_strServerPort());
				volumeId = wDCabinetInfo.getM_iVolId();
				sIpAddress = wDCabinetInfo.getM_strServerIP();
			}
			else{
				sSessionId = request.getParameter("sessionID");
				cabinetName = request.getParameter("CABINET");
				jtsPort = Integer.parseInt(request.getParameter("JTSPORT"));
				volumeId = Integer.parseInt(request.getParameter("VOLID"));
				sIpAddress = request.getParameter("SERVERIP");
			}
			sessionId = Integer.parseInt(sSessionId);
		}
		catch(Exception exp)
		{
			System.out.println("Error Exception " + exp); 
		}


		if(requestorType!=null && !requestorType.equalsIgnoreCase("") && !requestorType.equalsIgnoreCase("null") )
		{
			addnlWhereClause = " and REQUEST_TYPE = '"+requestorType+"' and REQUESTOR_ID = '"+requestorId+"' ";
		}
		if(processName.equalsIgnoreCase("noc") || processName.equalsIgnoreCase("noc_qa")){
			addnlWhereClause = " and Unit_No = '"+unitNo+"'";
		}
		if(processName.equalsIgnoreCase("disbursement") || processName.equalsIgnoreCase("Disbursement_qa")){
			addnlWhereClause = " and disbursmentNo = '"+disbursementNo+"'";
		}
		
		if(comments==null || comments.trim().equalsIgnoreCase(""))
		{
			comments = "Others";
		}
		
		
		
		WriteToLog("processName: "+processName+" : "+workitemName+" templateCode: "+templateCode+" workStepName: "+workStepName);
		parserObj = new XMLParser();
		parserObj1 = new XMLParser();
		try
		{
			propObj = new Properties();
			WriteToLog("Before Reading propertiesFilepath");
			propertiesFilepath = System.getProperty("user.dir") + File.separator + "TemplateGeneration"+ File.separator + "preGeneratedtemplates"+ File.separator + processName+"_"+ templateCode + ".properties";
			
			WriteToLog("Reading propertiesFilepath : " + propertiesFilepath);

			File propertiesFile = new File(propertiesFilepath);
			
			if(!propertiesFile.exists()){
				WriteToLog("Inside If");
				propertiesFilepath = System.getProperty("user.dir") + File.separator + "TemplateGeneration"+ File.separator + "preGeneratedtemplates"+ File.separator + processName +  File.separator + processName + "_"+ templateCode + ".properties";
				WriteToLog("Reading propertiesFilepath If : " + propertiesFilepath);
			}
			propObj.load(new FileInputStream(propertiesFilepath));
			
			//documentName = propObj.getProperty("DOCUMENTNAME");
			//documentName = makeDocumentName(documentName, workStepName);
			
			//if(processName.equalsIgnoreCase("clos"))
			//{
				//if(templateCode.equalsIgnoreCase("1"))
				//{
					templateName = propObj.getProperty("XMLFILENAME");
					viewer = propObj.getProperty("VIEWER");
					extTblName = propObj.getProperty("EXTTABLENAME");
					readstatus = true;
				//}
			//}
			try{
				debugSwitch = propObj.getProperty("DEBUG_FLAG");
			}
			catch(Exception e){

			}
			try{
				extTemplate = propObj.getProperty("EXT_TEMPLATE");
			}		
			catch(Exception e){
				WriteToLog("Error Exception while reading  EXT_TEMPLATE" + e);
			}
			WriteToLog("Reading propertiesFilepath : 123");
			htmlFilePath = System.getProperty("user.dir") + File.separator +"TemplateGeneration"+ File.separator +"preGeneratedtemplates"+ File.separator + processName + File.separator +templateName+".html";
			WriteToLog("Reading propertiesFilepath : 123" + htmlFilePath);
			File htmlFile = new File(htmlFilePath);

			if(!htmlFile.exists()){
				htmlFilePath = System.getProperty("user.dir") + File.separator +"TemplateGeneration"+ File.separator +"preGeneratedtemplates"+ File.separator + processName + File.separator + templateName+ File.separator +templateName+".html";
				WriteToLog("Reading propertiesFilepath : 1232");
			}
			
			//templatePath = System.getProperty("user.dir") + File.separator + "TemplateGeneration"+ File.separator +"preGeneratedtemplates"+ File.separator + processName + File.separator + templateCode +"."+"html";

			destinationPath = System.getProperty("user.dir") + File.separator + "TemplateGeneration"+ File.separator +"generatedTemplates"+ File.separator + workitemName;
			WriteToLog("Reading propertiesFilepath : 12325");
			
			File dirpath = new File(destinationPath);
			if(dirpath == null || !dirpath.isDirectory())
			{
				dirpath.mkdir();
			}
			//Mohit : Changed to generate the generate the doc file with Template Code value instead of Template Name
			destinationPath = System.getProperty("user.dir") + File.separator + "TemplateGeneration"+ File.separator +"generatedTemplates"+ File.separator + workitemName + File.separator + templateCode + "."+viewer;
			WriteToLog("Reading propertiesFilepath : 123265");
		}
		catch(Exception exp)
		{
			readstatus = false;
			WriteToLog("Error in reading the Property File :="+exp);
		}
		if(readstatus)
		{
			try
			{
				WriteToLog("try");
				readxmldata = new ReadXmlData();
				WriteToLog("try 1");
				rdXmldataObj = new ReadXmlData();
				rdXmlDataObj = new ReadXmlData();
				WriteToLog("try 2");
				businessvalidation = new BusinessValidation();
				WriteToLog("try 3");
				arrlist = new ArrayList();
				WriteToLog("try 4");
				arrGridlist = new ArrayList();
				arrExtlist = new ArrayList();
				WriteToLog("try 5");
				WriteToLog("Reading propertiesFilepath : 12326553");
				xmlFilePath = System.getProperty("user.dir") + File.separator +"TemplateGeneration"+ File.separator +"preGeneratedtemplates"+ File.separator + processName + File.separator +processName+"_"+templateName+".xml";
				WriteToLog("Reading propertiesFilepath : 123265534" + xmlFilePath);
				File XmlFile = new File(xmlFilePath);

				if(!XmlFile.exists()){
					xmlFilePath = System.getProperty("user.dir") + File.separator +"TemplateGeneration"+ File.separator +"preGeneratedtemplates"+ File.separator + processName + File.separator  +templateName+ File.separator + processName+"_"+templateName+".xml";
				}
				
				WriteToLog("Readed Xml contents into ArrayList filepath"+xmlFilePath);
				 
				if(readxmldata.readData(xmlFilePath))
				{
					WriteToLog("Readed External table Xml contents into ArrayList");
				}
				WriteToLog("Mohit-WriteXMLtoArrayList-Start");
				arrExtlist = readxmldata.getXmlDataRecords();
				WriteToLog("Mohit-WriteXMLtoArrayList-End");
				
				startTime = System.currentTimeMillis();
				WriteToLog("Mohit-ValidateData-Start ");
				
				//	boolean extFlag = validateData(arrExtlist,workitemName,extTblName,wfsession,addnlWhereClause);
				
				
				addnlWhereClause_new=" and CUSTOMER_ID= '"+CUSTOMER_ID+"' ";
				
				WriteToLog("Mohit-ValidateData-Start ");
				
				boolean extFlag = validateData(arrExtlist,workitemName,extTblName,addnlWhereClause,sSessionId,cabinetName,sIpAddress,jtsPort,ht, processName, templateCode);
				

				timeDiff = System.currentTimeMillis()-startTime;
				System.out.println(timeDiff);
				WriteToLog("Mohit-ValidateData-End " + timeDiff);
				
				if(extFlag)
				{
					WriteToLog("inside ifff >>templateName "+templateName);

					listViewFilePath = System.getProperty("user.dir") + File.separator +"TemplateGeneration"+ File.separator +"preGeneratedtemplates"+ File.separator + processName + File.separator +processName+"_"+templateName+"_ListView.xml";

					File listViewFile = new File(listViewFilePath);

					if(!listViewFile.exists()){
						listViewFilePath = System.getProperty("user.dir") + File.separator +"TemplateGeneration"+ File.separator +"preGeneratedtemplates"+ File.separator + processName + File.separator + templateName +File.separator + processName+"_"+templateName+"_ListView.xml";
					}
				
					WriteToLog("Grid names fetch path "+listViewFilePath);
				
					if(rdXmldataObj.readData(listViewFilePath))
					{
						WriteToLog("Readed Xml contents into ArrayList");
					}
					
					arrlist = rdXmldataObj.getXmlDataRecords();
					WriteToLog("arrlist 222 "+arrlist);
					
					String sMapLblName = null;
					String sMapXmlName = null;
					String sDBTblName = null;
					String orderClause=null;
					BusinessDataVO dc = null;
					BusinessDataVO df = null;
					BusinessValidation bv = null;
					WriteToLog("BusinessValidation >> ");
					try
					{
						bv = new BusinessValidation();
						//df = (BusinessDataVO)arrlist.get(0);
						//				WriteToLog("df   >>>  "+df);		
						for(int i = 0; i < arrlist.size(); i++)
						{	WriteToLog("here >>>  "+df);
							dc = (BusinessDataVO)arrlist.get(i);
							orderClause = dc.getMapLblName();
							sMapXmlName = dc.getMapXmlName();
							sDBTblName = dc.getDbTblName();
							
							sMapLblName=sDBTblName;
							
							addnlWhereClauseGrid=orderClause;
							WriteToLog("Readed sDBTblName "+sDBTblName);
							WriteToLog("Readed sMapXmlName "+sMapXmlName);
							WriteToLog("Readed orderClause "+orderClause);
							
							if(addnlWhereClauseGrid.equalsIgnoreCase("NA"))
							{
							addnlWhereClauseGrid="";
							}
								
							
							if(sMapLblName == null && sMapXmlName == null && sDBTblName == null )
							{
								//Nothing
							}
							else
							{
							
								WriteToLog("Readed sMapXmlName "+sMapXmlName);
								
								tableMappingXmlPath = System.getProperty("user.dir") +  File.separator + "TemplateGeneration"+  File.separator + "preGeneratedtemplates"+  File.separator + processName +  File.separator + sMapXmlName+".xml";

								File tableMappingXmlFile = new File (tableMappingXmlPath);

								if(!tableMappingXmlFile.exists()){
									tableMappingXmlPath = System.getProperty("user.dir") +  File.separator + "TemplateGeneration"+  File.separator + "preGeneratedtemplates"+  File.separator + processName +  File.separator + templateName + File.separator + sMapXmlName+".xml";
								}

								if(rdXmlDataObj.readData(tableMappingXmlPath))
								{
									WriteToLog("Readed Grid Xml contents into ArrayList inside else line 235");
								}
								arrGridlist = rdXmlDataObj.getXmlDataRecords();
								WriteToLog("Mayank - Array Grid List : "+arrGridlist);
								WriteToLog("Readed Grid Xml contents into ArrayList sDBTblName"+sDBTblName);
								startTime = System.currentTimeMillis();
								WriteToLog("ValidateTable-startTime "+startTime);
								
								if((extTemplate).indexOf("~"+sMapLblName+"~")>-1)
								{
		
									WriteToLog("inside generateDynamicHtml: "+sMapLblName);
									GridFlag = genrateDynamicHtml(arrGridlist,workitemName,sMapLblName,sDBTblName,addnlWhereClauseGrid,sSessionId,cabinetName,sIpAddress,jtsPort,templateCode,ht,processName);
								}
								//added on aug 31
								else
								{
									//	WriteToLog("addnlWhereClauseGrid FOR 111 found "+addnlWhereClauseGrid);
									GridFlag = validateTable(arrGridlist,workitemName,sMapLblName,sDBTblName,addnlWhereClauseGrid,sSessionId,cabinetName,sIpAddress,jtsPort,ht, processName, templateCode);
								}

								timeDiff = System.currentTimeMillis()-startTime;
								System.out.println(timeDiff);
								WriteToLog("timeDiff-End for "+sDBTblName+" "+timeDiff);
							}
						}
					}
					catch(Exception ex)
					{
						WriteToLog("Error during external table Validations" + ex);
					}
					finally
					{
					}
				}
				
				else
				{
					WriteToLog("Error during external table Validations.");
				}
			
			}
			catch(Exception ex)
			{
				WriteToLog("Error in reading Xml file");
			}
		}
		startTime = System.currentTimeMillis();
		
		boolean bReturn=false;
		if(viewer.equalsIgnoreCase("PDF"))
		{
			WriteToLog("generatePDF-Start ");
			WriteToLog("pbfHtml-result "+pbfHtml);
		
			WriteToLog("Mohit-generateHTMLDoc-Start ");
			resultHtml = generateHTMLPDF(ht, htmlFilePath, destinationPath,pbfHtml);//To Generate the final Doc File
			//timeDiff = System.currentTimeMillis()-startTime;
			//System.out.println(timeDiff);
			//WriteToLog("Mohit-generateHTMLDoc-End " + timeDiff +" bReturn "+bReturn);
			WriteToLog("Mohit-generateHTMLDoc-End ");

			if(resultHtml!= null && !resultHtml.equalsIgnoreCase("FAIL")){
				bReturn = true;
				outputXml=resultHtml;
			}
			
			WriteToLog("bReturn-result "+bReturn);
			WriteToLog("pbfHtml-result "+pbfHtml);
			
			WriteToLog("FINAL HTML >> "+resultHtml);
			
			if(pbfHtml!=null){
				if(pbfHtml.equalsIgnoreCase("skippdf")){
					WriteToLog("skippdf found ");
					timeDiff = System.currentTimeMillis()-startTime1;
					WriteToLog("skippdf time diff"+timeDiff);
					//WriteToLog("skippdf before "+resultHtml);
					out.clear();
					resultHtml=resultHtml.replaceAll("null","");
					//WriteToLog("skippdf after null replacment "+resultHtml);

					//out.println(resultHtml);  
					
					return;
				}
			}
		}
		else{
			WriteToLog("generateHTML-Start ");
			resultHtml = generateHTMLDoc(ht, htmlFilePath, destinationPath);//To Generate the final Doc File

			if(resultHtml!= null && !resultHtml.equalsIgnoreCase("FAIL")){
				bReturn = true;
				outputXml=resultHtml;
			}
			
			WriteToLog("bReturn-result "+bReturn);
			WriteToLog("pbfHtml-result "+pbfHtml);
			
			WriteToLog("FINAL HTML >> "+resultHtml);
			
			if(pbfHtml!=null){
				if(pbfHtml.equalsIgnoreCase("skippdf")){
					WriteToLog("skippdf found ");
					timeDiff = System.currentTimeMillis()-startTime1;
					WriteToLog("skippdf time diff"+timeDiff);
					//WriteToLog("skippdf before "+resultHtml);
					out.clear();
					resultHtml=resultHtml.replaceAll("null","");
					//WriteToLog("skippdf after null replacment "+resultHtml);
					//out.println(resultHtml);
					
					return;
				}
			}

		}
		
		timeDiff = System.currentTimeMillis()-startTime;
		System.out.println(timeDiff);
		WriteToLog("Mohit-generateHTMLDoc-End " + timeDiff +" bReturn "+bReturn);
		String query = "select DISTINCT(var_rec_1) from WFINSTRUMENTTABLE where processinstanceid = '" + workitemName + "'";
		WriteToLog("07112023 UPDATED fetching InputXml " + query);
		//String inputXmlSelect = APSelectWithcColumnName(query, sSessionId,cabinetName);
		String inputXmlSelect = "<?xml version='1.0'?><APSelect_Input><Option>APSelect</Option><Query>" + query + "</Query><SessionId>" + sSessionId + "</SessionId><EngineName>" + cabinetName + "</EngineName></APSelect_Input>";
		WriteToLog("1....updated...Mohit-processdefId fetching inputXmlSelect " + inputXmlSelect);
		String outputXmlSelect = WFCallBroker.execute(inputXmlSelect, sIpAddress, jtsPort,"WEBLOGIC");
		//String outputXmlSelect = WFCallBroker.execute(inputXmlSelect, sIpAddress, jtsPort, "WEBLOGIC");
		WriteToLog("updated fetching OutputXml " + outputXmlSelect);
		xmlParser = new XMLParser();
		xmlParser.setInputXML((outputXmlSelect));

		String mainCode = xmlParser.getValueOf("MainCode");
		WriteToLog("mainCode :: " + mainCode);
		
		//ADDED BY MEHAK ON APRIL 27
		
	
		if(mainCode.equals("0"))
		{
			//processDefId = xmlParser.getNextValueOf("td");
			WriteToLog("xmlParser.getValueOf('td')----- " + xmlParser.getValueOf("td"));
			folderIndex = Integer.parseInt(xmlParser.getValueOf("td"));
			
			WriteToLog("folderIndex " + folderIndex);
		}
		
		
		//ENDED BY MEHAK
		
	
		//String mainCode = "";
		System.out.println("Letter Generated Successfully (JSP) = " + bReturn);
		WriteToLog("Letter Generated Successfully (JSP) = " + bReturn);
		
		if(bReturn)
		{
			//jtsPort = Integer.parseInt(wDCabinetInfo.getM_strServerPort());
			
			//volumeId = wDCabinetInfo.getM_iVolId();
			
			//WriteToLog("jtsPort : " + jtsPort);
			//sIpAddress = wDCabinetInfo.getM_strServerIP();
			//WriteToLog("sIpAddress : " + sIpAddress);
			cabinetName = cabinetName;
			//WriteToLog("cabinetName : " + cabinetName);
			sessionId = Integer.parseInt(sSessionId);
			//WriteToLog("sessionId : " + sessionId);
			groupIndex = "0";
			fileObj = new File(destinationPath);
			//WriteToLog("fileObj : " + fileObj + " \n destinationPath : " + destinationPath);
			lFileLength = fileObj.length();
			//WriteToLog("lFileLength : " + lFileLength);
			iNoOfPages = 1;
			JPISIsIndex ISINDEX = new JPISIsIndex();
			//WriteToLog("ISINDEX : " + ISINDEX);
	        JPDBRecoverDocData JPISDEC = new JPDBRecoverDocData();
	      //  WriteToLog("JPISDEC : " + JPISDEC);
	        JPISDEC.m_cDocumentType = 'N';
	      //  WriteToLog("JPISDEC.m_cDocumentType : " + JPISDEC.m_cDocumentType);
			JPISDEC.m_nDocumentSize = (int) lFileLength;
			//WriteToLog("lFileLength : " + lFileLength);
			//WriteToLog("JPISDEC.m_nDocumentSize : " + JPISDEC.m_nDocumentSize);
			JPISDEC.m_sVolumeId = (short)volumeId;
			//WriteToLog("volumeId : " + volumeId);
		//	WriteToLog("JPISDEC.m_sVolumeId : " + JPISDEC.m_sVolumeId);
			
			WriteToLog(" jtsPort : " + jtsPort + " sIpAddress : " + sIpAddress+ " cabinetName : " + cabinetName+ " sessionId : " + sessionId+ " lFileLength : " + lFileLength+ " fileObj : " + fileObj+ " ISINDEX : " + ISINDEX+ " JPISDEC : " + JPISDEC+ " JPISDEC.m_nDocumentSize : " + JPISDEC.m_nDocumentSize+ " JPISDEC.m_sVolumeId : " + JPISDEC.m_sVolumeId+ " JPISDEC.m_sVolumeId : " + JPISDEC.m_sVolumeId);
			
			
			
			
				CPISDocumentTxn.AddDocument_MT(null, sIpAddress, (short)jtsPort, cabinetName, (short)volumeId, destinationPath, JPISDEC, "", ISINDEX);
			
			WriteToLog("Document added to IS successfully.");
			System.out.println("Document added to IS successfully.");
			
			String commentsChOut=comments;
			
			
			if(commentsChOut.indexOf("_")>-1)
			{
		    	commentsChOut=commentsChOut.substring(0,commentsChOut.lastIndexOf("_"));
			}
			
			query ="select  count(*) from PDBDocument doc, PDBDocumentContent docCont where doc.DocumentIndex = docCont.DocumentIndex and docCont.ParentFolderIndex = '"+folderIndex+"' and doc.name = '"+documentName+"' and COMMNT like  '%"+commentsChOut+"%' ";
			
			inputXmlSelect = "<?xml version='1.0'?><APSelect_Input><Option>APSelect</Option><Query>" + query + "</Query><SessionId>" + sSessionId + "</SessionId><EngineName>" + cabinetName + "</EngineName></APSelect_Input>";
			WriteToLog("Mohit-count inputXmlSelect " + inputXmlSelect);
			outputXmlSelect = WFCallBroker.execute(inputXmlSelect, sIpAddress, jtsPort, "WEBLOGIC");
		    WriteToLog(" in count outputXmlSelect "+outputXmlSelect);
			
			xmlParser = new XMLParser();
			xmlParser.setInputXML((outputXmlSelect));
			mainCode = xmlParser.getValueOf("MainCode");
			
           
			if(mainCode.equals("0"))
			{
				adddocument = true;
				WriteToLog("Adding document");
				
			}
			String inputXml  ="";
			String outputXmlAddDocument ="";
			if(adddocument)
			{
				WriteToLog("Add Document Start ");
				docIndex = JPISDEC.m_nDocIndex + "#" + volumeId;
				//String dataClassName=pro.getProperty("DataClassContract");
				String dataClassName=propObj.getProperty("CIBILDATACLASS");
				//WriteToLog("Cibil Data Class......... "+dataClassName);
				//out.println("dataClassName "+dataClassName);
				//int jtsIp=Integer.parseInt(wDCabinetInfo.getM_strServerPort());
				//String dataclassstr ="";
				String dataclassstr = getDataClassString1(dataClassName, cabinetName, sIpAddress ,jtsPort, sSessionId, workitemName);
				WriteToLog("docIndex : " + docIndex);
				inputXml = "<?xml version='1.0'?><NGOAddDocument_Input><Option>NGOAddDocument</Option><CabinetName>" + cabinetName + "</CabinetName><UserDBId>" + sessionId + "</UserDBId><GroupIndex>" + groupIndex + "</GroupIndex><ParentFolderIndex>" + folderIndex + "</ParentFolderIndex><DocumentName>" + documentName + "</DocumentName><CreatedByAppName>"+viewer+"</CreatedByAppName><Comment>"+comments+"</Comment><VolumeIndex>" + volumeId + "</VolumeIndex><FilePath>" + destinationPath + "</FilePath><ProcessDefId>" + processDefId + "</ProcessDefId><ISIndex>" + docIndex + "</ISIndex><NoOfPages>" + iNoOfPages + "</NoOfPages><AccessType>I</AccessType><VersionFlag>Y</VersionFlag><DocumentType>N</DocumentType><DocumentSize>" + lFileLength + "</DocumentSize>"+dataclassstr+"</NGOAddDocument_Input>";
				WriteToLog("inputXml add document   "+inputXml);
				
				outputXmlAddDocument = WFCallBroker.execute(inputXml, sIpAddress, jtsPort,"WEBLOGIC");
				WriteToLog("outputXmlAddDocument add document   "+outputXmlAddDocument);
				
				parserObj = new XMLParser();
				parserObj.setInputXML((outputXmlAddDocument));
				
				if(parserObj.getValueOf("Status").equals("0"))
				{
					docIndex = parserObj.getValueOf("DocumentIndex");
					OwnerName=parserObj.getValueOf("Owner");
					outputXml = "<Record><ErrorCode>0</ErrorCode><ErrorDesc>Letter Generated Successfully.</ErrorDesc><DocumentIndex>" + docIndex + "</DocumentIndex><DocumentName>" + parserObj.getValueOf("DocumentName") + "</DocumentName><ISIndex>" + parserObj.getValueOf("ISIndex") + "</ISIndex><NoOfPages>" + parserObj.getValueOf("NoOfPages") + "</NoOfPages><AnnotationFlag>" + parserObj.getValueOf("AnnotationFlag") + "</AnnotationFlag><DocumentType>" + parserObj.getValueOf("DocumentType") + "</DocumentType><CreatedByAppName>" + parserObj.getValueOf("CreatedByAppName") + "</CreatedByAppName><CreationDateTime>" + parserObj.getValueOf("CreationDateTime") + "</CreationDateTime><VersionFlag>" + parserObj.getValueOf("VersionFlag") + "</VersionFlag><DocumentVersionNo>" + parserObj.getValueOf("DocumentVersionNo") + "</DocumentVersionNo><CheckoutStatus>" + parserObj.getValueOf("CheckoutStatus") + "</CheckoutStatus><CheckoutBy>" + parserObj.getValueOf("CheckoutBy") + "</CheckoutBy><Comment>" + parserObj.getValueOf("Comment") + "</Comment><OwnerIndex>" + parserObj.getValueOf("OwnerIndex") + "</OwnerIndex><DocumentSize>" + parserObj.getValueOf("DocumentSize") + "</DocumentSize><Owner>" + parserObj.getValueOf("Owner") + "</Owner><RevisedDateTime>" + parserObj.getValueOf("RevisedDateTime") + "</RevisedDateTime></Record>";
					WriteToLog("to send outputXml   "+outputXml);
				}
				else
				{
					outputXml = "<Record><ErrorCode>1</ErrorCode><ErrorDesc>Error in generating the template. Contact to Support Team.</ErrorDesc></Record>";
				}
				WriteToLog("Add Document End ");
			}
			else
			{
				
				
				boolean bError = false;
				WriteToLog("Document Check In Check Out StartDocument Check In Check Out Start ");
				query ="select docCont.DocumentIndex,doc.ImageIndex,doc.VolumeId from PDBDocument doc ,PDBDocumentContent docCont where doc.DocumentIndex = docCont.DocumentIndex and docCont.ParentFolderIndex ='"+folderIndex+"' and doc.name = '"+documentName+"' and doc.COMMNT like '%"+commentsChOut+"%' order by docCont.DocumentOrderNo asc";

				inputXmlSelect = "<?xml version='1.0'?><APSelect_Input><Option>APSelect</Option><Query>" + query + "</Query><SessionId>" + sSessionId + "</SessionId><EngineName>" + cabinetName + "</EngineName></APSelect_Input>";
				WriteToLog("Mohit-count deletion inputXmlSelect " + inputXmlSelect);
				outputXmlSelect = WFCallBroker.execute(inputXmlSelect, sIpAddress, jtsPort, "WEBLOGIC");
				WriteToLog("Mohit-count outputXmlSelect " + outputXmlSelect);
				
				
				
				
				
				xmlParser.setInputXML((outputXmlSelect));

				mainCode = xmlParser.getValueOf("MainCode");
				//WriteToLog("mainCode "+mainCode);
				

				if(mainCode.equals("0"))
				{
				WriteToLog("mainCode 0 "+mainCode);
					docIndex = xmlParser.getNextValueOf("td");
					WriteToLog("Line 610 - docIndex is   "+docIndex);
					imageIndex = xmlParser.getNextValueOf("td");
					WriteToLog("Line 612 - imageIndex is   "+imageIndex);
					//volumeId = Integer.parseInt(xmlParser.getNextValueOf("td"));
					volumeId = 1;
					WriteToLog("Line 614 - volumeId is   "+volumeId);
				}
					
				SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SS");
			    String strDate = sdf.format(new java.util.Date());
				WriteToLog("Line 619 - strDate is   "+strDate);
			    
			
						
				    outputXml = "<Record><ErrorCode>0</ErrorCode><ErrorDesc>Letter Generated Successfully.</ErrorDesc><DocumentIndex>" + docIndex + "</DocumentIndex><DocumentName>CAM</DocumentName></Record>";
					WriteToLog("to send outputXml   "+outputXml);					
					
					
					
					//ADDED BY PRANJALI ON MAY 11 2018
					query ="DocumentIndex ='"+docIndex+"' and name = '"+documentName+"' and COMMNT like '%"+commentsChOut+"%'";
					
					inputXml="<?xml version=\"1.0\"?>"
                 + "<APUpdate_Input><Option>APUpdate</Option>"
                 + "<TableName>PDBDocument</TableName>"
                 + "<ColName>COMMNT</ColName>"
                 + "<Values>'" + comments + "'</Values>"
                 + "<WhereClause>" + query + "</WhereClause>"
                 + "<EngineName>" + cabinetName + "</EngineName>"
                 + "<SessionId>" + sessionId + "</SessionId>"
                 + "</APUpdate_Input>";
				 WriteToLog(" UPDATE inputXml " +inputXml);
				 outputXmlAddDocument = WFCallBroker.execute(inputXml, sIpAddress, jtsPort,"WEBLOGIC");
				 WriteToLog(" UPDATE output " +outputXmlAddDocument);
				 
				

					
					
					
				
				
			}
		}
		else
		{
			outputXml = "<Record><ErrorCode>1</ErrorCode><ErrorDesc>Error in generating the Letter. Contact to Support Team.</ErrorDesc></Record>";
		}
		//Added By MEHAK ON SEPT 24
		
		//String Values="'"+workitemName+"','"+documentName+"',"+docIndex+",SYSTIMESTAMP,'"+OwnerName+"'"+",'"+workStepName+"','"+viewer+"'";
			
		//String sInputXML = "<?xml version=\"1.0\"?>"
        //+ "<APInsert_Input>"
        //+ "<Option>APInsert</Option>"
        //+ "<TableName>NG_IRLOS_TEMPLATE_HISTORY</TableName>"
        //+"<ColName>WI_NAME,DOCUMENT_NAME,DOCUMENT_INDEX,GENERATION_DATETIME,GENERATED_BY,WORKSTEP_NAME,TEMPLATE_TYPE</ColName>"
        //+ "<Values>" + Values + "</Values>"
        //+ "<EngineName>" + cabinetName + "</EngineName>"
        //+ "<SessionId>" + sessionId + "</SessionId>"
        //+ "</APInsert_Input>";

				 
		//String outputXmlAddDocument = execute(sInputXML, sIpAddress, jtsPort, "JBOSSEAP");
		//WriteToLog(" UPDATE output " +outputXmlAddDocument);	
		
		
		
	}
	catch(Exception exp)
	{
		outputXml = "<Record><ErrorCode>1</ErrorCode><ErrorDesc>Error in generating the Letter. Contact to  Bank BPM Support Team</ErrorDesc></Record>";
		WriteToLog("Mohit : Error - " + exp);
	}
	finally
	{
		processName = null;
		workitemName = null;
		fileObj = null;
		
		parserObj = null;
		//ht = null;
	}


	response.setContentType("text/html");
	response.setHeader("Cache-Control","no-cache");
	response.getWriter().write(resultHtml);	
	
%>
<%!
//start code for configuration 
Hashtable ht = new Hashtable();

private String createsingularquery(String propertiesFilePath, String WiName) {
	Properties sqlPropertiesFile = new Properties();
	String finalSelectQuery = "Select * from ";
	try {
		sqlPropertiesFile.load(new FileInputStream(propertiesFilePath));
		int numberOfQueries = Integer.parseInt(sqlPropertiesFile.getProperty("Number_of_queries"));
		
		for(int i=1;i<= numberOfQueries; i++) {
			if(i<numberOfQueries) {
				finalSelectQuery = finalSelectQuery + sqlPropertiesFile.getProperty("query_" + String.valueOf(i)) + " , ";
			}
			else {
				finalSelectQuery = finalSelectQuery + sqlPropertiesFile.getProperty("query_" + String.valueOf(i));
			}
		}
		return finalSelectQuery.replace("#wi_name#", WiName);
	} catch (FileNotFoundException e) {
		e.printStackTrace();
	} catch (IOException e) {
		e.printStackTrace();
	}
	return finalSelectQuery;
	
}

private boolean validateData(ArrayList alRecordsValidation,String swi_name,String mstTblName,String addnlWhereClause,String sSessionId,String cabinetName,String sIpAddress,int jtsPort,Hashtable ht, String processName, String templateCode)
{
	String extName = "";
	String tempName = "";
	String isFormat = "";
	String format = "";
	String sReturnValue = "";
	String sErrorCode = "";
	String QueryResult = "";
	String scolnames = "";
	String Finalcolnames ="";
	String sorgcolnames="";
	String stempcolnames="";
	String orgFinalcolnames="";
	String tempFinalcolnames="";
	String swiname = "";
	String whereval="";
	boolean bReturn = false;
	XMLParser xmlParserobject = null;

	BusinessDataVO dc = null;
	BusinessDataVO df = null;
	BusinessValidation bv = null;
	try{
		WriteToLog("validateData ");
		bv = new BusinessValidation();
		WriteToLog("swiname 33:= "+bv);
		df = (BusinessDataVO)alRecordsValidation.get(0);
		WriteToLog("swiname 44:= "+df);
		swiname = df.getExtName();
		WriteToLog("swiname := "+swiname);
		for(int i = 0; i < alRecordsValidation.size(); i++)
		{
			WriteToLog("inside for loop := ");
			dc = (BusinessDataVO)alRecordsValidation.get(i);
			extName = dc.getExtName();
			tempName = dc.getTempName();
			//isFormat = dc.getIsFormat();
			//format = dc.getFormat();
			sorgcolnames = sorgcolnames.concat(extName).concat(",");
			orgFinalcolnames = sorgcolnames.substring(0,sorgcolnames.lastIndexOf(","));
			stempcolnames = stempcolnames.concat(tempName).concat(",");
			tempFinalcolnames = stempcolnames.substring(0,stempcolnames.lastIndexOf(","));
			sErrorCode = extName;



			WriteToLog("hereeeeeeee := ");

			if(extName.equalsIgnoreCase("GETDATE()"))
			{
			extName = "convert(varchar, "+extName+", 103) AS SYS_DATE";
			}
			/*else if(isFormat.equalsIgnoreCase("DATE"))
			{
			extName = "convert(varchar, "+extName+", 103) AS "+extName;
			}
			else if(isFormat.equalsIgnoreCase("SEPERATOR"))
			{
			extName = "REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,cast("+extName+" as int)),1), '.00','') AS "+extName;
			}*/
			else
			{
			//Noting
			}

			scolnames = scolnames.concat(extName).concat(",");
		}



		WriteToLog("Finalcolnames := "+Finalcolnames);
		Finalcolnames = scolnames.substring(0,scolnames.lastIndexOf(","));
		whereval = swi_name;
		QueryResult = bv.DynamicQuery(Finalcolnames,whereval,"test",mstTblName);

		Properties sqlPropertiesFile = new Properties();
		String sqlPropertiesFilePath = System.getProperty("user.dir") + File.separator + "TemplateGeneration" + File.separator + "preGeneratedtemplates"+ File.separator + processName + File.separator + processName + "_" + templateCode + "_singular_queries.properties";

		File sqlQueriesPropertiesFile = new File(sqlPropertiesFilePath);
		
		String sqlFIlePath = System.getProperty("user.dir") + File.separator + "TemplateGeneration" + File.separator + "preGeneratedtemplates"+ File.separator + processName + File.separator + processName + "_" + templateCode + "."+"sql";

		File sqlFile = new File(sqlFIlePath);
		
		if(sqlQueriesPropertiesFile.exists()){
			WriteToLog("reading sql properties file");
			QueryResult = createsingularquery(sqlPropertiesFilePath, workitemName);
		}
		else{
			sqlPropertiesFilePath = System.getProperty("user.dir") + File.separator + "TemplateGeneration" + File.separator + "preGeneratedtemplates"+ File.separator + processName + File.separator + templateCode + File.separator + processName + "_" + templateCode +"_singular_queries.properties";

			File newsqlQueriesPropertiesFile = new File(sqlPropertiesFilePath);
			if(newsqlQueriesPropertiesFile.exists()){
				QueryResult = createsingularquery(sqlPropertiesFilePath, workitemName);
			}
			else{	
				if(sqlFile.exists()){
					BufferedReader sqlBufferedReader = new BufferedReader(new FileReader(sqlFile));
					QueryResult = sqlBufferedReader.readLine().replace("#wi_name#",workitemName);
				}
				else{
					sqlFIlePath = System.getProperty("user.dir") + File.separator + "TemplateGeneration" + File.separator + "preGeneratedtemplates"+ File.separator + processName + File.separator + templateCode + File.separator + processName + "_" + templateCode + "."+"sql";

					File newSqlFile = new File(sqlFIlePath);
					if(newSqlFile.exists()){
						BufferedReader sqlBufferedReader = new BufferedReader(new FileReader(newSqlFile));
						QueryResult = sqlBufferedReader.readLine().replace("#wi_name#",workitemName);
					}
					else if(addnlWhereClause!=null && !addnlWhereClause.equalsIgnoreCase("")){
						QueryResult = QueryResult + addnlWhereClause;
					}
				}
			}
		}

		WriteToLog("QueryResult FINAL := "+QueryResult);

		QueryResult = QueryResult.replace("select", "SELECT ");

		WriteToLog("QueryResult := "+QueryResult);

		WriteToLog("sSessionId"+sSessionId);

		//String inputXml = APSelectWithcColumnName(QueryResult,sSessionId,cabinetName);
		
		String inputXml ="<?xml version='1.0'?><WFReusableComponent_Input><Option>WFSSelectwithColumnNames</Option><EngineName>"+ cabinetName +"</EngineName><SessionID>"+ sSessionId +"</SessionID><Query>"+QueryResult+"</Query><TableName>"+mstTblName+"</TableName></WFReusableComponent_Input>";

		WriteToLog("InputXml ::= "+inputXml);
		WriteToLog("ValidateData WFCallBroker :-Start " + sIpAddress + jtsPort);
		String outputXml = WFCallBroker.execute(inputXml, sIpAddress, jtsPort,"WEBLOGIC");
		outputXml = outputXml.replace("&lt;","<").replace("&gt;",">");
		WriteToLog("outputXml ::= "+outputXml);

		xmlParserobject = new XMLParser();
		xmlParserobject.setInputXML(outputXml);

		if(xmlParserobject.getValueOf("MainCode").equals("0"))
		{
			String arrcol[] = orgFinalcolnames.split(",");
			String arrtempcol[] = tempFinalcolnames.split(",");
			for(int i=0; i<arrcol.length; i++)
			{
				ht.put("##"+arrtempcol[i]+"##",xmlParserobject.getValueOf(arrcol[i]));
				//WriteToLog("arrtempcol[i] mehak" + arrtempcol[i]);
			}
			bReturn = true;
		}
	}
	catch(Exception ex)
		{
		bReturn = false;
		WriteToLog("Error during External table field Validations validateDat" + ex);
		ex.printStackTrace();

	}
	finally
		{
		extName = null;
		tempName = null;
		isFormat = null;
		format = null;
		sReturnValue = null;
		sErrorCode = null;
	}
	return bReturn;
}
private boolean validateTable(ArrayList alRecordsValidation,String swi_name,String tempVarGrid,String sDbTblName,String addnlWhereClause,String sSessionId,String cabinetName,String sIpAddress,int jtsPort,Hashtable ht, String processName, String templateCode)
{
	String sLblName = "";
	String sDbColName = "";
	String sMapColName = "";
	String sLblWidth = "";
	String sLblAlign = "";
	String sTbllblNames = "";
	String sMapColNames = "";
	String sDbColNames = "";
	String sAttributeName = "";
	String QueryResult = "";
	String whereval="";
	boolean bReturn = false;
	String resultOut="";
	String resultOutCI="";
	String resultOutBank="";
	BusinessDataVO dc = null;
	BusinessDataVO df = null;
	BusinessValidation bv = null;
	XMLParser xmlParserobject = null;
	XMLParser xmlParsen = null;
	XMLParser parserObj = null;
	
	try
	{
		bv = new BusinessValidation();
		df = (BusinessDataVO)alRecordsValidation.get(0);
		WriteToLog("validateTable called");

		WriteToLog("vikas table check  inside else ");
		sTbllblNames = sTbllblNames.concat("<table style='border:1px solid #000000;' id='customers' cellSpacing=0 cellPadding=5 width='100%'><tr>");
	
		sMapColNames = sMapColNames.concat("<tr>");
		//WriteToLog("sDbTblName is:= "+ sDbTblName);
		for(int i = 0; i < alRecordsValidation.size(); i++)
		{
			//WriteToLog("sDbTblName is:= "+ sDbTblName);
			dc = (BusinessDataVO)alRecordsValidation.get(i);
			
			sLblName = dc.getLblName();
			sDbColName = dc.getDBColName();
			sMapColName = dc.getMapColName();
			sLblWidth = dc.getLblWidth();
			sLblAlign = dc.getLblAlign();
			
			sTbllblNames = sTbllblNames.concat("<td  width="+sLblWidth+"% style='word-wrap: break-word:break-all; width:"+sLblWidth+"% ;font-size:15px;font-style:Times New Roman;padding:4px 5px 4px 5px; vertical-align: top; border-right:1px solid #000' id='customers' align ="+sLblAlign+">").concat("<b>"+sLblName+"</b>").concat("</td>");
			
			sMapColNames = sMapColNames.concat("<td  width="+sLblWidth+"% style='word-wrap: break-word:break-all; font-size:15px;width:"+sLblWidth+"%;font-weight:normal;font-style:Times New Roman;padding:4px 5px 4px 5px; vertical-align: top; border-top:1px solid #000;border-right:1px solid #000'  align ="+sLblAlign+" >").concat("##"+sMapColName+"##").concat("</td>");
			//if(!sDbColName.equalsIgnoreCase("NA"))
			sDbColNames = sDbColNames.concat(sDbColName).concat(",");
			sAttributeName = sAttributeName.concat(sMapColName).concat("#");
		}
		sTbllblNames = sTbllblNames.concat("</tr>");
		sMapColNames = sMapColNames.concat("</tr>");
		sDbColNames = sDbColNames.substring(0,sDbColNames.lastIndexOf(","));
		sAttributeName = sAttributeName.substring(0,sAttributeName.lastIndexOf("#"));
	
		
		whereval = swi_name;
		WriteToLog("sDbTblName is:= "+ sDbTblName);
		QueryResult = bv.DynamicQuery(sDbColNames,whereval,"test",sDbTblName);

		String sqlFIlePath = System.getProperty("user.dir") + File.separator + "TemplateGeneration" + File.separator + "preGeneratedtemplates"+ File.separator + processName + File.separator + processName + "_" + templateCode + "_" + tempVarGrid + "."+"sql";
		File sqlFile = new File(sqlFIlePath);
		
		if(sqlFile.exists()){
			BufferedReader sqlBufferedReader = new BufferedReader(new FileReader(sqlFile));
			QueryResult = sqlBufferedReader.readLine().replace("#wi_name#",workitemName);
		}
		else
		{
			sqlFIlePath = System.getProperty("user.dir") + File.separator + "TemplateGeneration" + File.separator + "preGeneratedtemplates"+ File.separator + processName + File.separator + templateCode + File.separator + processName + "_" + templateCode + "_" + tempVarGrid + "."+"sql";

			File newSqlFile = new File(sqlFIlePath);
			if(newSqlFile.exists()){
				BufferedReader sqlBufferedReader = new BufferedReader(new FileReader(newSqlFile));
				QueryResult = sqlBufferedReader.readLine().replace("#wi_name#",workitemName);
			}
			else if(addnlWhereClause!=null && !addnlWhereClause.equalsIgnoreCase("")){
				QueryResult = QueryResult + addnlWhereClause;
			}
		}
		
		WriteToLog("QueryResult is: 1 = "+ QueryResult);
		WriteToLog("sDbColNames is:= "+ sDbColNames);

		//String inputXml1 = APSelectWithcColumnName(QueryResult,sSessionId,cabinetName);
		String inputXml1="<?xml version='1.0'?><WFReusableComponent_Input><Option>WFSSelectwithColumnNames</Option><EngineName>"+ cabinetName +"</EngineName><SessionID>"+ sSessionId +"</SessionID><Query>"+QueryResult+"</Query><TableName>"+sDbTblName+"</TableName></WFReusableComponent_Input>";
		
		WriteToLog("Input XML:= "+ inputXml1);

		WriteToLog("Input XML 1:= "+ inputXml1);

		//String outputXml1 = execute(inputXml1, sIpAddress, jtsPort, "JBOSSEAP");
		String outputXml1 = WFCallBroker.execute(inputXml1, sIpAddress, jtsPort,"WEBLOGIC");
		outputXml1 = outputXml1.replace("&lt;","<").replace("&gt;",">");
		outputXml1 = outputXml1.replaceAll("&apos;","'");
		outputXml1 = outputXml1.replaceAll("&quot;","\"");

		WriteToLog("Output XML11:= " + outputXml1);

		Long startTimeD1 = System.currentTimeMillis();

		String tableXml1 = generateDynamicTbl(outputXml1, sMapColNames,sAttributeName,sDbColNames);

		Long timeDiffD1 = System.currentTimeMillis()-startTimeD1;

		WriteToLog("Mohit-generateDynamicTable-End34 "+timeDiffD1);

		
		xmlParserobject = new XMLParser();
		xmlParserobject.setInputXML(outputXml1);
		
		if(xmlParserobject.getValueOf("TotalRetrieved").equals("0"))
		{
			WriteToLog("TotalRetrieved is   0 ");
			ht.put("##"+tempVarGrid+"##","N/A<br>");
			
		}
		else
		{
			ht.put("##"+tempVarGrid+"##",sTbllblNames+tableXml1+"</table>");
		}
		
		
	}
	catch(Exception ex)
	{
		bReturn = false;
		WriteToLog("Error during Table Validations-->" + ex);
	}
	finally
	{
		sLblName = null;
		sDbColName = null;
		sMapColName = null;
		sLblWidth = null;
		sDbTblName = null;
		
	}
	return bReturn;
}




private boolean validateTable(ArrayList alRecordsValidation,String swi_name,WFSession wfsession,String tempVarGrid,String sDbTblName,String addnlWhereClause)
{
	String sLblName = "";
	String sDbColName = "";
	String sMapColName = "";
	String sLblWidth = "";
	String sLblAlign = "";
	String sTbllblNames = "";
	String sMapColNames = "";
	String sDbColNames = "";
	String sAttributeName = "";
	String QueryResult = "";
	String whereval="";
	boolean bReturn = false;
	BusinessDataVO dc = null;
	BusinessDataVO df = null;
	BusinessValidation bv = null;
	try
	{
		bv = new BusinessValidation();
		df = (BusinessDataVO)alRecordsValidation.get(0);
		
		
		if(tempVarGrid.equalsIgnoreCase("NGG_CLOS_SANCTION_CONDN") || tempVarGrid.equalsIgnoreCase("NGG_CLOS_COVE_FIN") || tempVarGrid.equalsIgnoreCase("NGG_CLOS_COVE_NONFIN"))
		{
			
			WriteToLog("painting NGG_CLOS_SANCTION_CONDN grid:::::::::::::::::::::::::::::::");
			
			sTbllblNames = sTbllblNames.concat("<table border=0 cellspacing=0 cellpadding=0 style='margin-left:5.4pt;border-collapse:collapse;border:none'>");
			sMapColNames = sMapColNames.concat("<tr>");
			WriteToLog("sDbTblName is:= "+ sDbTblName);
			for(int i = 0; i < alRecordsValidation.size(); i++)
			{
				WriteToLog("sDbTblName is:= "+ sDbTblName);
				dc = (BusinessDataVO)alRecordsValidation.get(i);
				
				sLblName = dc.getLblName();
				sDbColName = dc.getDBColName();
				sMapColName = dc.getMapColName();
				sLblWidth = dc.getLblWidth();
				sLblAlign = dc.getLblAlign();
				
				//sTbllblNames = sTbllblNames.concat("<td class='MsoListParagraphCxSpMiddle' style='font:7.0pt 'Times New Roman';font-size:10.0pt' >").concat("<b>"+sLblName+"</b>").concat("</td>");
				
				if(i==(alRecordsValidation.size()-1))
				{
					WriteToLog("*******************");
					sMapColNames = sMapColNames.concat("<td  class=MsoListParagraphCxSpMiddle style='word-wrap: break-word:break-all; font-size:10.0pt;' valign='top' >").concat("##"+sMapColName+"##").concat("</td>");
				}
				else
				{
					WriteToLog("---------------------");
					sMapColNames = sMapColNames.concat("<td  class=MsoListParagraphCxSpMiddle style='word-wrap: break-word:break-all; font-size:10.0pt;width:20' valign='top' >").concat("##"+sMapColName+"##").concat("</td>");
				}
				
			
				
				sDbColNames = sDbColNames.concat(sDbColName).concat(",");
				sAttributeName = sAttributeName.concat(sMapColName).concat("#");
			}
			//sTbllblNames = sTbllblNames.concat("</tr>");
			sMapColNames = sMapColNames.concat("</tr>");
			
			// <tr><td>S NO</td><td>DESCRIPTION</td></tr>
			// <tr><td>S_NO</td><td>DESCRIPTION</td></tr>
			// sDbColNames = S_NO,DESCRIPTION
			
		}
		else
		{
			sTbllblNames = sTbllblNames.concat("<table style='border:1px solid #000;' cellSpacing=0 cellPadding=0 width='100%'><tr>");
			sMapColNames = sMapColNames.concat("<tr>");
			WriteToLog("sDbTblName is:= "+ sDbTblName);
			for(int i = 0; i < alRecordsValidation.size(); i++)
			{
				WriteToLog("sDbTblName is:= "+ sDbTblName);
				dc = (BusinessDataVO)alRecordsValidation.get(i);
				
				sLblName = dc.getLblName();
				sDbColName = dc.getDBColName();
				sMapColName = dc.getMapColName();
				sLblWidth = dc.getLblWidth();
				sLblAlign = dc.getLblAlign();
				
				sTbllblNames = sTbllblNames.concat("<td  width="+sLblWidth+"% style='word-wrap: break-word:break-all; font-size:15px; font-style:Times New Roman; vertical-align: top; border-right:1px solid #000' align ="+sLblAlign+">").concat("<b>"+sLblName+"</b>").concat("</td>");
				
				sMapColNames = sMapColNames.concat("<td  width="+sLblWidth+"% style='word-wrap: break-word:break-all; font-size:15px; font-style:Times New Roman; vertical-align: top; border-top:1px solid #000;border-right:1px solid #000' align ="+sLblAlign+" >").concat("##"+sMapColName+"##").concat("</td>");
				//if(!sDbColName.equalsIgnoreCase("NA"))
				sDbColNames = sDbColNames.concat(sDbColName).concat(",");
				sAttributeName = sAttributeName.concat(sMapColName).concat("#");
			}
			sTbllblNames = sTbllblNames.concat("</tr>");
			sMapColNames = sMapColNames.concat("</tr>");
		}
		
		
		
		
		sDbColNames = sDbColNames.substring(0,sDbColNames.lastIndexOf(","));
		sAttributeName = sAttributeName.substring(0,sAttributeName.lastIndexOf("#"));
		whereval = swi_name;
		WriteToLog("sDbTblName is:= "+ sDbTblName);
		QueryResult = bv.DynamicQuery(sDbColNames,whereval,"test",sDbTblName);
		if(tempVarGrid.equalsIgnoreCase("NGG_CLOS_SANCTION_CONDN") || tempVarGrid.equalsIgnoreCase("NGG_CLOS_COVE_FIN") || tempVarGrid.equalsIgnoreCase("NGG_CLOS_COVE_NONFIN"))
		{
			QueryResult = QueryResult + " or WI_NAME = 'master' ";
			sDbColNames = sAttributeName.replaceAll("#", ",");
		}
		if(addnlWhereClause!=null && !addnlWhereClause.equalsIgnoreCase(""))
		{
			QueryResult = QueryResult + addnlWhereClause;
		}
		WriteToLog("QueryResult is:= "+ QueryResult);
		WriteToLog("sDbColNames is:= "+ sDbColNames);
		
		String inputXml = APSelectWithcColumnName(QueryResult,wfsession.getSessionId(),wfsession.getEngineName());
		WriteToLog("Input XML:= "+ inputXml);
		
			String outputXml = WFCallBroker.execute(inputXml, wfsession.getJtsIp(), wfsession.getJtsPort(), 1);
		
		WriteToLog("Output XML:= " + outputXml);
		
		Long startTimeD = System.currentTimeMillis();
		
		String tableXml = generateDynamicTbl(outputXml, sMapColNames,sAttributeName,sDbColNames);
		WriteToLog("tableXml:::"+tableXml);
		WriteToLog("sTbllblNames:::"+sTbllblNames);
		
		Long timeDiffD = System.currentTimeMillis()-startTimeD;
		System.out.println(timeDiffD);
		WriteToLog("Mohit-generateDynamicTable-End "+timeDiffD);
		
		
		ht.put("##"+tempVarGrid+"##",sTbllblNames+tableXml+"</table>");
		
	}
	catch(Exception ex)
	{
		bReturn = false;
		WriteToLog("Error during Table Validations-->" + ex);
	}
	finally
	{
		sLblName = null;
		sDbColName = null;
		sMapColName = null;
		sLblWidth = null;
		sDbTblName = null;
		
	}
	return bReturn;
}

private String replacePageBreak(String Xml)
{
	
	return Xml.replaceAll("<p><!-- pagebreak --></p>", "<p style=\"page-break-before: always\"></p>").replaceAll("<!-- pagebreak --></p>", "<p style=\"page-break-before: always\"></p>").replaceAll("<p><!-- pagebreak -->", "<p style=\"page-break-before: always\"></p>").replaceAll("<!-- pagebreak -->", "<p style=\"page-break-before: always\"></p>").replaceAll("\\$", "&#036;").replaceAll("\\\\", "&#092;");
}

private String APSelectWithcColumnName(String queryString,String sessionid,String cabinatename)
{
	WriteToLog("Input queryString:= "+ queryString);
	
	WriteToLog("Input sessionid:= "+ sessionid);
	
	WriteToLog("Input cabinatename:= "+ cabinatename);
	
	String inXML = "<?xml version='1.0'?><APSelectWithColumnNames_Input><Option>APSelectWithColumnNames</Option><Query>" + queryString + "</Query><EngineName>" + cabinatename + "</EngineName><SessionId>" + sessionid + "</SessionId></APSelectWithColumnNames_Input>";
	
	WriteToLog("ISuccccccc:= ");
	
	return inXML;
}

//start code for html file generation
private String generateHTMLDoc(Hashtable ht, String templatePathFilename, String outputPathFilename) 
{
	boolean bReturn = false;
	Long startTimeG;
	Long timeDiffG;
	String finalHTML = "";
	try 
	{	
		BufferedReader reader = new BufferedReader(new FileReader(templatePathFilename));
		File destination = new File(outputPathFilename);
		//BufferedWriter writer = new BufferedWriter(new FileWriter(destination));
		StringBuffer buffer = new StringBuffer();
		FileWriter writer = new FileWriter(destination);

		String thisLine;
		while ((thisLine = reader.readLine()) != null) 
		{
			buffer.append(thisLine);
			buffer.append("\r\n");
		}
		reader.close();
		String toWrite = buffer.toString();
		Long totalReplaceTime=0L;
			for (java.util.Enumeration e = ht.keys(); e.hasMoreElements();) 
			{
				String name = (String) e.nextElement();
				String value = ht.get(name).toString();
				startTimeG = System.currentTimeMillis();
				//WriteToLog("replaceName-Start "+name);		
				//thisLine = thisLine.replaceAll(name,value);
				//toWrite = toWrite.replaceAll(name, value);
				//toWrite = toWrite.replaceAll(name, Matcher.quoteReplacement(value));
				toWrite = toWrite.replace(name, value);
				timeDiffG = System.currentTimeMillis()-startTimeG;
				System.out.println(timeDiffG);
				//WriteToLog("replaceValue-End "+value);
				//WriteToLog("replaceName-End "+name+" | "+timeDiffG);		
				totalReplaceTime = totalReplaceTime + timeDiffG;
			}
		WriteToLog("totalReplaceTime "+totalReplaceTime);		
		startTimeG=System.currentTimeMillis();
		//WriteToLog("pbfHtml >> "+pbfHtml);
		
		// toWrite = toWrite.replace("##Reason##", pbfHtml);
		writer.write(toWrite);
		//	writer.write(thisLine);
		//	writer.newLine();
		writer.close();
		timeDiffG = System.currentTimeMillis()-startTimeG;
		System.out.println(timeDiffG);
		WriteToLog("Write-End " +timeDiffG);
		System.out.println("Template Generated Successfully.");
		bReturn = true;
		finalHTML = toWrite;
	}
	catch (Exception ex) 
	{
		//System.out.println("Error during generated HTML Document = " + ex);
		WriteToLog("Error during generateHTMLDoc = " + ex);
	}

	return finalHTML;
}

//end code for html file generation
private void WriteToLog(String strOutput)
{
	System.out.println(strOutput);
	//if(debugSwitch.equalsIgnoreCase("Y")){
		StringBuffer str = new StringBuffer();
		str.append(DateFormat.getDateTimeInstance(0,2).format(new java.util.Date()));
		str.append(" | ");
		str.append(strOutput);
		str.append("\n");
		StringBuffer stringBuffer = null;
		String tmpFilePath="";
		Calendar calendar=new GregorianCalendar();
		String DtString=String.valueOf(""+calendar.get(Calendar.DAY_OF_MONTH) +(calendar.get(Calendar.MONTH) + 1) +
		calendar.get(Calendar.YEAR));
		try
		{
			stringBuffer = new StringBuffer(50);
			stringBuffer.append(System.getProperty("user.dir"));
			stringBuffer.append(File.separatorChar);
			stringBuffer.append("TemplateGeneration");
			stringBuffer.append(File.separatorChar);
			stringBuffer.append("logs");
			File fBackup=new File(stringBuffer.toString());
			if(fBackup == null || !fBackup.isDirectory())
			{
			fBackup.mkdirs();
			}
			stringBuffer.append(File.separatorChar);
			stringBuffer.append("CLOS_HTMLTemplate_Generation_Log_"+DtString+"_"+workitemName+".xml");
			tmpFilePath = stringBuffer.toString();
			BufferedWriter out = new BufferedWriter(new FileWriter(tmpFilePath, true));
			out.write(str.toString());
			out.close();
		}
		catch (Exception exception)
		{

		}
		finally
		{
			stringBuffer = null;
		}
	//}
	
}

private String fetchOutputHtml(Hashtable ht, String templatePathFilename)
	{
		String returnStr = "";
		try
		{
			BufferedReader reader = new BufferedReader(new FileReader(templatePathFilename));
			StringBuffer buffer = new StringBuffer();
				WriteToLog("111111111 >>>test");
			String thisLine;
			WriteToLog("111111111 "+ht );
			while ((thisLine = reader.readLine()) != null) 
			{
				buffer.append(thisLine);
				buffer.append("\r\n");
			}
			reader.close();
			String toWrite = buffer.toString();
		WriteToLog("toWrite >>>test"+toWrite);
			Long totalReplaceTime=0L;
			for (java.util.Enumeration e = ht.keys(); e.hasMoreElements();) 
			{
				String name = (String) e.nextElement();
				String value = ht.get(name).toString();
				toWrite = toWrite.replace(name, value);
			}
			//WriteToLog("Exception pbfHtml>>>> " + pbfHtml);
			if(pbfHtml!=null && !pbfHtml.equals(""))
			toWrite = toWrite.replace("##NG_PBF##", pbfHtml);
			toWrite = toWrite.replace("null","");
			returnStr = toWrite;
		}
		catch(Exception ee)
		{
			WriteToLog("Exception fetchOutputHtml " + ee);
			returnStr = "FAIL";
		}
		return returnStr;
	}
	
	
private String generateHTMLPDF(Hashtable ht, String templatePathFilename, String outputPathFilename,String param) 
{
	boolean bReturn = false;
	OutputStream os = null;
	String returnStr = "";

              try {
               os = new FileOutputStream(outputPathFilename);

               try {
                     
                     PdfRendererBuilder builder = new PdfRendererBuilder();               
                     builder.withW3cDocument(html5ParseDocument(ht,templatePathFilename,outputPathFilename,param),"UTF-8");
					 	
						returnStr = fetchOutputHtml(ht,templatePathFilename);
						WriteToLog("returnStr......" + returnStr);
                    
                     builder.toStream(os);
					//  WriteToLog("after toStream ");
                     builder.run();
					 // WriteToLog("after run ");
					 bReturn=true;
					// WriteToLog("bReturn HERE " + bReturn);
               } catch (Exception e) {
                    WriteToLog("generateHTMLPDF Exception " + e);
					returnStr = "FAIL";
               } finally {
                     try {
                            os.close();
                     } catch (IOException e) {
                            WriteToLog("IOException Exception " + e);
                     }
               }
              }
              catch (IOException e1) {
					WriteToLog("generateHTMLPDF IOException " + e1);
              }
		WriteToLog("CHecking!!!!!!!!!!!!!!!!!!");

		return returnStr;
}	
public org.w3c.dom.Document html5ParseDocument(Hashtable ht, String templatePathFilename, String outputPathFilename,String param) throws IOException 
    {
      // String param="skippdf";
        org.jsoup.nodes.Document doc=null;
		Long startTimeG;
	Long timeDiffG;
	try 
	{	//WriteToLog("html5ParseDocument called "+templatePathFilename);	
		BufferedReader reader = new BufferedReader(new FileReader(templatePathFilename));
		File destination = new File(outputPathFilename);
		//BufferedWriter writer = new BufferedWriter(new FileWriter(destination));
		StringBuffer buffer = new StringBuffer();
		//FileWriter writer = new FileWriter(destination);
		//WriteToLog("readinf ghtml conetent >>"+templatePathFilename);
		//	String var1=readHtmlContent(templatePathFilename);
		//	WriteToLog("readinf ghtml var1 >>"+var1);
			
		String thisLine;
		while ((thisLine = reader.readLine()) != null) 
		{
			buffer.append(thisLine);
			//buffer.append("\r\n");
		}
		reader.close();
		String toWrite = buffer.toString();
		
		Long totalReplaceTime=0L;
			for (java.util.Enumeration e = ht.keys(); e.hasMoreElements();) 
			{
				String name = (String) e.nextElement();
				String value = ht.get(name).toString();
				WriteToLog("name >>> mehak "+name);
				WriteToLog("value >>> mehak "+value);
				
				startTimeG = System.currentTimeMillis();
					
				//thisLine = thisLine.replaceAll(name,value);
				//toWrite = toWrite.replaceAll(name, value);
				//toWrite = toWrite.replaceAll(name, Matcher.quoteReplacement(value));
				toWrite = toWrite.replace(name, value);
				WriteToLog("toWrite >>>>>> "+toWrite);
				timeDiffG = System.currentTimeMillis()-startTimeG;
				//System.out.println(timeDiffG);
				WriteToLog("replaceValue "+value);
				WriteToLog("replaceName"+name+" | "+timeDiffG);		
				totalReplaceTime = totalReplaceTime + timeDiffG;
			}
		WriteToLog("TotalReplaceTime pdf "+totalReplaceTime);		
		startTimeG=System.currentTimeMillis();
		
		String pbfHtml="";
		 toWrite = toWrite.replace("##NG_PBF##", pbfHtml);
		 toWrite = toWrite.replace("null","");
		 
		 WriteToLog("after NG_PBF replace");
		  doc =  Jsoup.parse(toWrite, "UTF-8");
		 
		
		//writer.write(toWrite);
			//writer.write(thisLine);
		//	writer.newLine();
		//writer.close();
		timeDiffG = System.currentTimeMillis()-startTimeG;
		//System.out.println(timeDiffG);
		WriteToLog("Mohit-Write-End PDF File" +timeDiffG);
		//System.out.println("Template Generated Successfully.");
		WriteToLog("ht >>" +ht);
		//	resultHtml=toWrite;
		//bReturn = true;
	}
	catch (Exception ex) 
	{
		//System.out.println("Error during generated HTML Document = " + ex);
		WriteToLog("Error during generateHTMLPDF = " + ex);
	}
  
        return DOMBuilder.jsoup2DOM(doc);
   }
	
	
private String makeDocumentName(String documentName, String workStepName){
	
	String documentType="";
	String docName = documentName;
	String wsName = workStepName;
	WriteToLog("Mohit-getDocumentName() documentName" + docName);
	WriteToLog("Mohit-getDocumentName() workStepName" + wsName);
	try{
		if(docName!=null || docName!=""	|| docName!=" "){
			
			boolean flag=true;
			String wrkItmDocTyp[] = docName.split("##");
			WriteToLog("wrkItmDocTyp[0]     " + wrkItmDocTyp[0]);
			for(int wiDt=0; wiDt<wrkItmDocTyp.length; wiDt++){
				WriteToLog("wrkItmDocTyp    " + wrkItmDocTyp);
				String docTypeTemp = wrkItmDocTyp[wiDt];
				WriteToLog("docTypeTemp       " + docTypeTemp);
				String docType[] = docTypeTemp.split("%");
			WriteToLog("docType[0]   " + docType[0]);
			WriteToLog("docType[1]    " + docType[1]);
			
				if(docType[0].trim().equalsIgnoreCase(wsName) && flag){
					WriteToLog("docType[1]        mayank " + docType[1]);
					documentType = docType[1].trim();
					WriteToLog("murtaza        "+docType[1].trim());
					flag=false;
					WriteToLog("Mohit-documentName : " + documentType);	
				}
				
				
				WriteToLog("Mohit-documentName : " + documentType);	
			}
		}
	
	}catch (Exception e) {
		
		WriteToLog("Mohit- getDocumentName() Error getting documentName " + e);
	}
	
	return documentType;
}
private boolean genrateDynamicHtml(ArrayList alRecordsValidation,String swi_name,String tempVarGrid,String sDbTblName,String addnlWhereClause,String sSessionId,String cabinetName,String sIpAddress,int jtsPort,String templateCode,Hashtable ht, String processName)
{
	String sLblName = "";
	String sDbColName = "";
	String sMapColName = "";
	String sLblWidth = "";
	String sLblAlign = "";
	String sTbllblNames = "";
	String sMapColNames = "";
	String sDbColNames = "";
	String sAttributeName = "";
	String QueryResult = "";
	String whereval="";
	boolean bReturn = false;
	BusinessDataVO dc = null;
	BusinessDataVO df = null;
	BusinessValidation bv = null;
	XMLParser xmlParserobject = null;
	XMLParser xmlParserobject1 = null;
	
	try
	{
	WriteToLog("genrateDynamicHtml called");
	
	
		bv = new BusinessValidation();
		df = (BusinessDataVO)alRecordsValidation.get(0);
		
		
		//WriteToLog("sDbTblName is:= "+ sDbTblName);
		
			for(int i = 0; i < alRecordsValidation.size(); i++)
			{
				//WriteToLog("sDbTblName is:= "+ sDbTblName);
				dc = (BusinessDataVO)alRecordsValidation.get(i);
				
				sLblName = dc.getLblName();
				sDbColName = dc.getDBColName();
				sMapColName = dc.getMapColName();
				sLblWidth = dc.getLblWidth();
				sLblAlign = dc.getLblAlign();
				
				sTbllblNames = sTbllblNames.concat("<td  width="+sLblWidth+"% style='word-wrap: break-word:break-all; font-size:15px; width:"+sLblWidth+"%;font-style:Times New Roman;padding:4px 5px 4px 5px; vertical-align: top; border-right:1px solid #000' id='customers' align ="+sLblAlign+">").concat("<b>"+sLblName+"</b>").concat("</td>");
				
				sMapColNames = sMapColNames.concat("<td  width="+sLblWidth+"% style='word-wrap: break-word:break-all; font-size:15px;width:"+sLblWidth+"%; font-weight:normal;font-style:Times New Roman;padding:4px 5px 4px 5px; vertical-align: top; border-top:1px solid #000;border-right:1px solid #000'  align ="+sLblAlign+" >").concat("##"+sMapColName+"##").concat("</td>");
				//if(!sDbColName.equalsIgnoreCase("NA"))
				sDbColNames = sDbColNames.concat(sDbColName).concat(",");
				sAttributeName = sAttributeName.concat(sMapColName).concat("#");
			}
			sTbllblNames = sTbllblNames.concat("</tr>");
			sMapColNames = sMapColNames.concat("</tr>");
		
		
		
	
		sDbColNames = sDbColNames.substring(0,sDbColNames.lastIndexOf(","));
		sAttributeName = sAttributeName.substring(0,sAttributeName.lastIndexOf("#"));
		whereval = swi_name;
		//WriteToLog("sDbTblName is:= "+ sDbTblName);
		QueryResult = bv.DynamicQuery(sDbColNames,whereval,"test",sDbTblName);
	
		
		String sqlFIlePath = System.getProperty("user.dir") + File.separator + "TemplateGeneration" + File.separator + "preGeneratedtemplates"+ File.separator + processName + File.separator + processName + "_" + templateCode + "_" + tempVarGrid + "."+"sql";
		File sqlFile = new File(sqlFIlePath);
		
		if(sqlFile.exists()){
			BufferedReader sqlBufferedReader = new BufferedReader(new FileReader(sqlFile));
			QueryResult = sqlBufferedReader.readLine().replace("#wi_name#",workitemName);
		}
		{
			sqlFIlePath = System.getProperty("user.dir") + File.separator + "TemplateGeneration" + File.separator + "preGeneratedtemplates"+ File.separator + processName + File.separator + templateCode + File.separator + processName + "_" + templateCode + "_" + tempVarGrid  + "."+"sql";

			File newSqlFile = new File(sqlFIlePath);
			if(newSqlFile.exists()){
				BufferedReader sqlBufferedReader = new BufferedReader(new FileReader(newSqlFile));
				QueryResult = sqlBufferedReader.readLine().replace("#wi_name#",workitemName);
			}
			else if(addnlWhereClause!=null && !addnlWhereClause.equalsIgnoreCase("")){
				QueryResult = QueryResult + addnlWhereClause;
			}
		}

	//WriteToLog("QueryResult is:= "+ QueryResult);
	//	WriteToLog("sDbColNames is:= "+ sDbColNames);
	WriteToLog("Code running till APSelectWithcColumnName ");
		//String inputXml = APSelectWithcColumnName(QueryResult,sSessionId,cabinetName);
		
		String inputXml = "<?xml version='1.0'?><WFReusableComponent_Input><Option>WFSSelectwithColumnNames</Option><Query>" + QueryResult + "</Query><SessionId>" + sSessionId + "</SessionId><EngineName>" + cabinetName + "</EngineName><TableName>"+sDbTblName+"</TableName></WFReusableComponent_Input>";
		
		WriteToLog("Code running after APSelectWithcColumnName ");
    	//WriteToLog("Input XML:= "+ inputXml);
		
		String outputXml = WFCallBroker.execute(inputXml, sIpAddress, jtsPort, "WEBLOGIC");
		outputXml = outputXml.replace("&lt;","<").replace("&gt;",">").replace("&quot;","\"");
		//WriteToLog("Output XML:= " + outputXml);
		WriteToLog("Code running after WFCallBroker ");

		Long startTimeD = System.currentTimeMillis();
		
		xmlParserobject = new XMLParser();
		xmlParserobject.setInputXML(outputXml);
		
				if(!xmlParserobject.getValueOf("TotalRetrieved").equals("0"))
					{
					//WriteToLog("TotalRetrieved is not  0 ");
					//WriteToLog("sMapColNames is:= "+ sDbColNames);
					//WriteToLog("sAttributeName is:= "+ sAttributeName);
					//WriteToLog("sDbColNames is:= "+ sDbColNames);
					WriteToLog("inside generateDynamicHtmltbl: "+ sDbTblName);
						String tableXml = generateDynamicHtmltbl(outputXml, sMapColNames,sAttributeName,sDbColNames,templateCode,sDbTblName,processName);
					//	WriteToLog("tableXml is:= "+ tableXml);
						ht.put("##"+tempVarGrid+"##",tableXml);
						
					}
				else
					{
						if(tempVarGrid.equalsIgnoreCase("NGV_CLOS_HDFC_SYSTEM_CLASSIFIACTION")||tempVarGrid.equalsIgnoreCase("NGV_CLOS_HDFC_SHAREHOLDING_PATTERN_NON_INDIVIDUAL")||tempVarGrid.equalsIgnoreCase("NGV_CLOS_HDFC_REPAYMENT_SCHEDULE")||tempVarGrid.equalsIgnoreCase("NGV_CLOS_HDFC_OTHER_DIRECTORSHIPS")||tempVarGrid.equalsIgnoreCase("NGV_CLOS_HDFC_NO_OF_UNIT_SOLD_COMMENTS")||tempVarGrid.equalsIgnoreCase("NGV_CLOS_HDFC_FUTURE_CASH_FLOWS")){
							ht.put("##"+tempVarGrid+"##","N/A<br>");
						}
						
						else{
							ht.put("##"+tempVarGrid+"##","");
						}
					}
		
	}
	catch(Exception ex)
	{
		bReturn = false;
		WriteToLog("Error during Table Validations-->" + ex);
	}
	finally
	{
		sLblName = null;
		sDbColName = null;
		sMapColName = null;
		sLblWidth = null;
		sDbTblName = null;
		
	}
	return bReturn;
}
private String generateDynamicHtmltbl(String XmlResponse, String subXml, String mapVar ,String tblColName,String templateCode,String sDbTblName, String processName) 
{
	boolean bReturn = false;
	StringBuffer stringBuf = null;
	StringBuffer stringBufHtml = null;
	XMLParser xmlParser = null;
	XMLParser xmlParserObj = null;
	StringTokenizer stringTokenizer = null;
	String mapVarName = null;
	String attributeName = null;
	String strHtml = null;
	String str = null;
	//Hashtable ht = null;
	StringBuffer stringBufferHtml = null;
	String blankValue = "&nbsp;";
	String dynamicHtmlPath="";
	//String processName="CLOS";
	//String templateCode="2";
	String result=null;
	try
	{
		xmlParser = new XMLParser();
		
		xmlParser.setInputXML(XmlResponse);
		stringBufferHtml = new StringBuffer();
		
	//	WriteToLog("tblColName dyn"+tblColName);
	//	WriteToLog("mapVar dyn"+mapVar);
	//	WriteToLog("subXml dyn"+subXml);

		dynamicHtmlPath = System.getProperty("user.dir") + File.separator+"TemplateGeneration"+File.separator+"preGeneratedtemplates" +File.separator+ processName +  File.separator+ templateCode+"_"+sDbTblName+"."+"html";

		File dynamichtmlFile = new File(dynamicHtmlPath);

		if(!dynamichtmlFile.exists()){
		dynamicHtmlPath = System.getProperty("user.dir") + File.separator+"TemplateGeneration"+File.separator+"preGeneratedtemplates" +File.separator+ processName +  File.separator + templateCode + File.separator+ templateCode+"_"+sDbTblName+"."+"html";
		}
		
		//WriteToLog("dynamicHtmlPath "+dynamicHtmlPath);
		
		result=readHtmlContent(dynamicHtmlPath);
		
		//WriteToLog("result html content "+result);
		
		
		if(xmlParser.getValueOf("MainCode").equals("0"))
		{
		
		
			//ht=new Hashtable();
			String arrtblColName[] = tblColName.split(",");
			String arrmapVar[] = mapVar.split("#");
			
			//here pick the dynamic html file
				
				for (int i = 0; i < (Integer.parseInt(xmlParser.getValueOf("TotalRetrieved"))); i++)
				{
					//WriteToLog("iside for loop ");
					Long startTimeR = System.currentTimeMillis();
					
					str = result;
					xmlParserObj=new XMLParser(xmlParser.getNextValueOf("Record"));
					for(int j=0; j<arrmapVar.length; j++)
					{
					//WriteToLog("line 1582 ");
					//WriteToLog("arrmapVar[j]) "+arrmapVar[j]);
					
						if(!xmlParserObj.getValueOf(arrtblColName[j]).equals(""))
						{
							str = str.replaceAll("##" + arrmapVar[j] + "##", replacePageBreak(xmlParserObj.getValueOf(arrtblColName[j])));
						}
						else
						str = str.replaceAll("##" + arrmapVar[j] + "##", blankValue);
					}
					//WriteToLog("line 1592 ");
					stringBufferHtml.append(str);
					Long timeDiff = System.currentTimeMillis()-startTimeR;
					//System.out.println( "time diffenerce" +sDbTblName+"-"+timeDiff);
					
					
				}
			//WriteToLog("line 1599 ");
		//	WriteToLog("str dynamic" +  str);
		
		}
	}
	catch (Exception ex) 
	{
		WriteToLog("Error During Generating dynamic table in HTML Template --> " + ex);
	}
	finally
	{
		sDbTblName=null;
		
	}
	return stringBufferHtml.toString();
	
}
private String readHtmlContent(String path)
{
	//	WriteToLog("readHtmlContent called");
		String content = null;
		StringBuilder contentBuilder = new StringBuilder();
		//WriteToLog("readHtmlContent path" +  path);
			try {
				BufferedReader in = new BufferedReader(new FileReader(path));
				String str;
				while ((str = in.readLine()) != null) {
					contentBuilder.append(str);
					//WriteToLog("readHtmlContent str>>>" +  str);
				}
				in.close();
			} catch (IOException e) {
			}
			 content = contentBuilder.toString();
			 return content;
		
			 
	
			 
			 
}


private String generateDynamicTbl(String XmlResponse, String subXml, String mapVar ,String tblColName) 
{
	boolean bReturn = false;
	StringBuffer stringBuf = null;
	StringBuffer stringBufHtml = null;
	XMLParser xmlParser = null;
	XMLParser xmlParserObj = null;
	StringTokenizer stringTokenizer = null;
	String mapVarName = null;
	String attributeName = null;
	String strHtml = null;
	String str = null;
	//Hashtable ht = null;
	StringBuffer stringBufferHtml = null;
	String blankValue = "&nbsp;";
	try
	{
	//WriteToLog("generateDynamicTbl called for ");
		xmlParser = new XMLParser();
		
		xmlParser.setInputXML(XmlResponse);
		stringBufferHtml = new StringBuffer();
		if(xmlParser.getValueOf("MainCode").equals("0"))
		{
			//ht=new Hashtable();
			String arrtblColName[] = tblColName.split(",");
			String arrmapVar[] = mapVar.split("#");
			
			if(xmlParser.getValueOf("TotalRetrieved").equals("0"))
			{
				str = subXml;
				//WriteToLog("Sumit-Test Replace-up");
				for(int j=0; j<arrmapVar.length; j++)
					{
						str = str.replaceAll("##" + arrmapVar[j] + "##", "-");
						
					}
					stringBufferHtml.append(str);
					//WriteToLog("Sumit-Test Replace-"+str);
			}
			
			else
			{
				//WriteToLog("Sumit-Test Replace-down");
				for (int i = 0; i < (Integer.parseInt(xmlParser.getValueOf("TotalRetrieved"))); i++)
				{
					Long startTimeR = System.currentTimeMillis();
					//WriteToLog("Sumit-validateTable Replace-"+Integer.parseInt(xmlParser.getValueOf("TotalRetrieved")));	
					str = subXml;
					xmlParserObj=new XMLParser(xmlParser.getNextValueOf("Record"));
					for(int j=0; j<arrmapVar.length; j++)
					{
						if(!xmlParserObj.getValueOf(arrtblColName[j]).equals(""))
						{
							str = str.replaceAll("##" + arrmapVar[j] + "##", replacePageBreak(xmlParserObj.getValueOf(arrtblColName[j])));
						}
						//added by pranjali sharma on 21 jan 2019 for blank financier on CIBIL CAM AL
						else if(arrtblColName[j].equalsIgnoreCase("a.* from (select NAME_FINANCIER"))
						{
							str = str.replaceAll("##" + arrmapVar[j] + "##", replacePageBreak(xmlParserObj.getValueOf("NAME_FINANCIER")));
						}
						else if(arrtblColName[j].equalsIgnoreCase("CASE WHEN MANUFACTURER IS NOT NULL THEN ROWNUM END AS SN"))
						{
							str = str.replaceAll("##" + arrmapVar[j] + "##", replacePageBreak(xmlParserObj.getValueOf("SN")));
						}
						else
						str = str.replaceAll("##" + arrmapVar[j] + "##", blankValue);
					}
					stringBufferHtml.append(str);
					Long timeDiff = System.currentTimeMillis()-startTimeR;
					//System.out.println(timeDiff);
					//WriteToLog("Sumit-validateTable Replace- " + timeDiff);
					
				}
			}
			
			/* for (int i = 0; i < (Integer.parseInt(xmlParser.getValueOf("TotalRetrieved"))); i++)
			{
				Long startTimeR = System.currentTimeMillis();
				WriteToLog("validateTable Replace-"+Integer.parseInt(xmlParser.getValueOf("TotalRetrieved")));	
				str = subXml;
				xmlParserObj=new XMLParser(xmlParser.getNextValueOf("Record"));
				for(int j=0; j<arrmapVar.length; j++)
				{
					//WriteToLog("arrmapVar::"+j+":"+arrmapVar[j]);
					//WriteToLog("arrtblColName::"+j+":"+arrtblColName[j]);
					//WriteToLog("db colm val:::"+xmlParserObj.getValueOf(arrtblColName[j]));
					if(!xmlParserObj.getValueOf(arrtblColName[j]).equals(""))
					{
						str = str.replaceAll("##" + arrmapVar[j] + "##", replacePageBreak(xmlParserObj.getValueOf(arrtblColName[j])));
					}
					else
					str = str.replaceAll("##" + arrmapVar[j] + "##", blankValue);
				}
				stringBufferHtml.append(str);
				Long timeDiff = System.currentTimeMillis()-startTimeR;
				//System.out.println(timeDiff);
				//WriteToLog("Mohit-validateTable Replace- " + timeDiff); 
				
			}*/
		}
	}
	catch (Exception ex) 
	{
		WriteToLog("Error During Generating dynamic table in HTML Template --> " + ex);
	}
	return stringBufferHtml.toString();
	
}


//added on AUG 31 2018 for Dynamic multiple Grid
	private boolean genrateDynamicGrid(ArrayList alRecordsValidation,
			String swi_name, String tempVarGrid, String sDbTblName,
			String addnlWhereClause, String sSessionId, String cabinetName,
			String sIpAddress, int jtsPort, String templateCode, Hashtable ht) {
		String sLblName = "";
		String sDbColName = "";
		String sMapColName = "";
		String sLblWidth = "";
		String sLblAlign = "";
		String sTbllblNames = "";
		String sMapColNames = "";
		String sDbColNames = "";
		String sAttributeName = "";
		String QueryResult = "";
		String whereval = "";
		
		boolean bReturn = false;
		BusinessDataVO dc = null;
		BusinessDataVO df = null;
		BusinessValidation bv = null;
		XMLParser xmlParser = null;
		XMLParser xmlParserobject = null;
		XMLParser xmlParserobject1 = null;

		try {
			//WriteToLog("genrateDynamicHtml called inside finacial");

			bv = new BusinessValidation();
			df = (BusinessDataVO) alRecordsValidation.get(0);
			/*for (int i = 0; i < alRecordsValidation.size(); i++) {
				//WriteToLog("sDbTblName is:= "+ sDbTblName);
				df = (BusinessDataVO) alRecordsValidation.get(i);
				sDbColName = df.getDBColName();
				sMapColName = df.getMapColName();
			sDbColNames = sDbColNames.concat(sDbColName).concat(",");
			sAttributeName = sAttributeName.concat(sMapColName).concat("#");
			
			}
			

			//sDbColNames = sDbColNames.substring(0, sDbColNames.lastIndexOf(","));
			//sAttributeName = sAttributeName.substring(0,sAttributeName.lastIndexOf("#"));
			whereval = swi_name;
			//WriteToLog("sDbTblName is:= " + sDbTblName);
			QueryResult = bv.DynamicQuery(sDbColNames, whereval, "test",
					sDbTblName);
					//WriteToLog("QueryResult is:= " + QueryResult);

			if (addnlWhereClause != null
					&& !addnlWhereClause.equalsIgnoreCase("")) {//WriteToLog("inside add query is:= "+ QueryResult);
				QueryResult = QueryResult + addnlWhereClause;
			}
			WriteToLog("QueryResult is:= " + QueryResult);
				WriteToLog("sDbColNames is:= "+ sDbColNames);

			String inputXml = APSelectWithcColumnName(QueryResult, sSessionId,
					cabinetName);

			//WriteToLog("Input XML:= "+ inputXml);

			String outputXml = WFCallBroker.execute(inputXml, sIpAddress,jtsPort, "WEBLOGIC");
			//WriteToLog("Output XML:= " + outputXml);

			Long startTimeD = System.currentTimeMillis();

			xmlParserobject = new XMLParser();
			xmlParserobject.setInputXML(outputXml);*/

			String query = "select  distinct row_id,COMP_NAME from NG_IRLOS_AUDITED_FIN_TXN where WI_NAME = '"
					+ swi_name + "' and SOURCING='EXCEL'";
			//WriteToLog(" fetching InputXml " + query);

		/*	String inputXmlSelect = "<?xml version='1.0'?><APSelect_Input><Option>APSelect</Option><Query>"
					+ query
					+ "</Query><SessionId>"
					+ sSessionId
					+ "</SessionId><EngineName>"
					+ cabinetName
					+ "</EngineName></APSelect_Input>";
			WriteToLog("Mohit-processdefId fetching inputXmlSelect "
					+ inputXmlSelect);*/
					
					
			String inputXmlSelect = APSelectWithcColumnName(query, sSessionId,
					cabinetName);
					//WriteToLog("inputXmlSelect4 " + inputXmlSelect);
			String outputXmlSelect = execute(inputXmlSelect,
					sIpAddress, jtsPort, "JBOSSEAP");
			//WriteToLog("OutputXml4 " + outputXmlSelect);
			xmlParser = new XMLParser();
			xmlParser.setInputXML((outputXmlSelect));

			String mainCode = xmlParser.getValueOf("MainCode");
			//WriteToLog("mainCode :: " + mainCode);

			if (!xmlParser.getValueOf("TotalRetrieved").equals("0")) {
				//WriteToLog("TotalRetrieved is not  0 ");
				//WriteToLog("sMapColNames is:= " + sDbColNames);
				//WriteToLog("sAttributeName is:= " + sAttributeName);
				//WriteToLog("sDbColNames is:= " + sDbColNames);
				String tableXml = generateDynamicHtmlGrid(alRecordsValidation,outputXmlSelect,
						sMapColNames, sAttributeName, sDbColNames,
						templateCode, sDbTblName,swi_name,sSessionId,cabinetName,sIpAddress,jtsPort);
						
				//WriteToLog("tableXml is:= " + tableXml);
				ht.put("##" + tempVarGrid + "##", tableXml
						);

			} else {
				
				ht.put("##" + tempVarGrid + "##", "No Audited Financial Uploaded");
			}

		} catch (Exception ex) {
			bReturn = false;
			WriteToLog("Error during Table Validations-->" + ex);
		} finally {
			sLblName = null;
			sDbColName = null;
			sMapColName = null;
			sLblWidth = null;
			sDbTblName = null;

		}
		return bReturn;
	}

	public String getDataClassString1(String dataclassname,String sCabname,String sJtsIp ,int port,String sSessionId,String wi_name) {
        String dataclassstr = "";
		//app_id="3001738";
        String inputXml = "";
        String outputXml = "";
        String sdatadefindex = "";
        String sIndexName = "";
        String sIndexID = "";
        String sIndexType = "";
        String sIndexValue = "";
        String sFieldString = "";
        //StringTokenizer _oStringTokenizer1 = null;
        //ArrayList alist = new ArrayList();
		XMLParser xmlParser = new XMLParser();
		
       
        try {
           

            
            inputXml = "<?xml version=\"1.0\"?><NGOGetDataDefIdForName_Input><Option>NGOGetDataDefIdForName</Option><CabinetName>"+sCabname+"</CabinetName><UserDBId>"+sSessionId+"</UserDBId><DataDefName>"+dataclassname+"</DataDefName></NGOGetDataDefIdForName_Input>";
           WriteToLog("inputXml  "+inputXml);
            outputXml = execute(inputXml,sJtsIp,port,"WEBLOGIC");
	   WriteToLog("outputXml  "+outputXml);
			
			 xmlParser.setInputXML(outputXml);

            if (xmlParser.getValueOf("Status").equalsIgnoreCase("0")) {
                sdatadefindex = xmlParser.getValueOf("DataDefIndex");
				
				WriteToLog("sdatadefindex   "+sdatadefindex);
            } else {
              WriteToLog("data def id not 0");
            }
		
			
            inputXml = "<?xml version=\"1.0\"?><NGOGetDataDefProperty_Input><Option>NGOGetDataDefProperty</Option><CabinetName>"+sCabname+"</CabinetName><UserDBId>"+sSessionId+"</UserDBId><DataDefIndex>"+sdatadefindex+"</DataDefIndex></NGOGetDataDefProperty_Input>";
			WriteToLog("inputXml  "+inputXml);
			
           outputXml = execute(inputXml,sJtsIp,port,"WEBLOGIC");
		    WriteToLog("outputXml  "+outputXml);
		 
		   
		    xmlParser.setInputXML(outputXml);
			
			if (xmlParser.getValueOf("Status").equalsIgnoreCase("0")) {
                String sFieldList = xmlParser.getValueOf("Fields");
			
               
                sFieldList = sFieldList.replaceAll("</Field>", "~");
				
                StringTokenizer oStringTokenizer1 = new StringTokenizer(sFieldList, "~");
				 while (oStringTokenizer1.hasMoreTokens()) {
                    sIndexName = "";
                    sIndexID = "";
                    sIndexType = "";
                    sIndexValue = "";
                    String sToken1 = oStringTokenizer1.nextToken().trim();
                    if ((sToken1.indexOf("<IndexId>") != -1) && (sToken1.length() > 0)) {
                        
                        xmlParser.setInputXML(sToken1);
                        HashMap fieldvaluehm = new HashMap();
                        sIndexName = xmlParser.getValueOf("IndexName").trim();
                        sIndexID = xmlParser.getValueOf("IndexId").trim();
                        sIndexType = xmlParser.getValueOf("IndexType").trim();
						
						if(sIndexName.equalsIgnoreCase("WI_NAME"))
                              sIndexValue = wi_name;
                       
						
						
											
							sFieldString = sFieldString + "<Field><IndexId>" + sIndexID + "</IndexId>"
                                + "<IndexType>" + sIndexType + "</IndexType>"
                                + "<IndexValue>" + sIndexValue + "</IndexValue></Field>";
								
                       
                    }
                } 
            }
            dataclassstr = "<DataDefinition><DataDefIndex>" + sdatadefindex + "</DataDefIndex><DataDefName>" + dataclassname + "</DataDefName><Fields>" + sFieldString + "</Fields></DataDefinition>";
	
        } catch (Exception e) {
            
				
           
        } finally {
			
            inputXml = null;
            outputXml = null;
            sdatadefindex = null;
            sIndexName = null;
            sIndexID = null;
            sIndexType = null;
            sIndexValue = null;
            sFieldString = null;
            //oStringTokenizer1 = null;
        }
		

        return dataclassstr; //change
    }


	private String generateDynamicHtmlGrid(ArrayList alRecordsValidation,String XmlResponse, String sMapColNames, String sAttributeName ,String sDbColNames,String templateCode,String sDbTblName,String swi_name,String sSessionId, String cabinetName,
			String sIpAddress, int jtsPort) 
{
	boolean bReturn = false;
	StringBuffer stringBuf = null;
	StringBuffer stringBufHtml = null;
	XMLParser xmlParser = null;
	XMLParser xmlParserObj = null;
	StringTokenizer stringTokenizer = null;
	String mapVarName = null;
	String attributeName = null;
	String strHtml = null;
	String str = null;
	//Hashtable ht = null;
	StringBuffer stringBufferHtml = null;
	String blankValue = "&nbsp;";
	String dynamicHtmlPath="";
	String processName="RLOS";
	//String templateCode="2";
	String result=null;
	String Query=null;
	String tableXml=null;
	String whereval = "";
	String sLblName = "";
		String sDbColName = "";
		String sMapColName = "";
		String sLblWidth = "";
		String sLblAlign = "";
		String sTbllblNames = "";
		String QueryResult=null;
		String row_id="";
		String  company_name="";
		BusinessValidation bv = null;
		BusinessDataVO dc = null;
		String addnlWhereClause="";
		String tableXmlfinal=null;

	try
	{
		bv = new BusinessValidation();
		xmlParser = new XMLParser();
		
		
		
		xmlParser.setInputXML(XmlResponse);
		stringBufferHtml = new StringBuffer();
		

		
		
		if(xmlParser.getValueOf("MainCode").equals("0"))
		{
		
		
			//ht=new Hashtable();
			//String arrtblColName[] = tblColName.split(",");
			//String arrmapVar[] = mapVar.split("#");
			
			//here pick the dynamic html file
				
				for (int i = 0; i < (Integer.parseInt(xmlParser.getValueOf("TotalRetrieved"))); i++)
				{
					//WriteToLog("iside for loop ");
					sDbColNames="";
					sAttributeName="";
					sMapColNames="";
					
					Long startTimeR = System.currentTimeMillis();
					
					//str = result;
					xmlParserObj=new XMLParser(xmlParser.getNextValueOf("Record"));
					row_id=xmlParserObj.getValueOf("ROW_ID");
					//WriteToLog("row_id is:= "+ row_id);
					company_name=xmlParserObj.getValueOf("COMP_NAME");
					//WriteToLog("company_name is:= "+ company_name);
					
					//fun calling for grid
			if(sDbTblName.equalsIgnoreCase("NGV_IRLOS_TMP_CAM_AL_FIN"))
					{
			
					sTbllblNames = sTbllblNames.concat("<table width='100%' border=1  id='customers11' cellspacing=0 cellpadding=0 style='margin-left:5.4pt;border-collapse:collapse;solid #000000;'>");
					sMapColNames = sMapColNames.concat("<tr>");
			
					//WriteToLog("sDbTblName is:= "+ sDbTblName);
			
					for(int j = 0; j < alRecordsValidation.size(); j++)
			{
				//WriteToLog("sDbTblName is:= "+ sDbTblName);
				dc = (BusinessDataVO)alRecordsValidation.get(j);
				
				//sLblName = dc.getLblName();
				sDbColName = dc.getDBColName();
				sMapColName = dc.getMapColName();
				sLblWidth = dc.getLblWidth();
				sLblAlign = dc.getLblAlign();
				
				//WriteToLog("sLblName is >>  "+ sLblName);
				//WriteToLog("sLblName is >>  "+ sLblName);
				
				//WriteToLog("size of record EXP,FIN >>  "+ alRecordsValidation.size());
				if(j==0)
				{
					//WriteToLog("exp,fin first row");
					sMapColNames = sMapColNames.concat("<td  id='customers' class=MsoListParagraphCxSpMiddle style='word-wrap:break-all; width:"+sLblWidth+"%; break-word:break-all;font-size:15px;' valign='top' >").concat("##"+sMapColName+"##").concat("</td>");
					//WriteToLog("**sMapColNames*"+sMapColNames);
				}
				else if(j==(alRecordsValidation.size()-1))
				{
					//WriteToLog("*******************");
					sMapColNames = sMapColNames.concat("<td  class=MsoListParagraphCxSpMiddle style='word-wrap: break-word:break-all;width:"+sLblWidth+"%;font-size:15px;font-weight:normal;border-right: 1px solid #000000;border-bottom: 1px solid #000000;' align ="+sLblAlign+" valign='top' >").concat("##"+sMapColName+"##").concat("</td>");
					//WriteToLog("**sMapColNames*"+sMapColNames);
				}
				else
				{
					//WriteToLog("------------inside else---------");
					sMapColNames = sMapColNames.concat("<td  class=MsoListParagraphCxSpMiddle style='word-wrap: break-word:break-all;width:"+sLblWidth+"%;font-size:15px;width:16;font-weight:normal; border-right: 1px solid #000000;border-bottom: 1px solid #000000;' align ="+sLblAlign+" valign='top' >").concat("##"+sMapColName+"##").concat("</td>");
				}
				
			
				
				sDbColNames = sDbColNames.concat(sDbColName).concat(",");
				sAttributeName = sAttributeName.concat(sMapColName).concat("#");
			}
			sDbColNames = sDbColNames.substring(0, sDbColNames.lastIndexOf(","));
			sMapColNames = sMapColNames.concat("</tr>");
			
			whereval = swi_name;
			addnlWhereClause = " AND ROW_ID='"+row_id+"'";
			//WriteToLog("Input addnlWhereClause:= "+ addnlWhereClause);
			QueryResult = bv.DynamicQuery(sDbColNames,whereval,"test",sDbTblName);
			if (addnlWhereClause != null && !addnlWhereClause.equalsIgnoreCase("")) {
			//WriteToLog("inside add query is:= "+ QueryResult);
			QueryResult = QueryResult + addnlWhereClause;
			WriteToLog("Input QueryResult:= "+ QueryResult);
			
			}
		String inputXml = APSelectWithcColumnName(QueryResult, sSessionId,
					cabinetName);

			//WriteToLog("Input XML:= "+ inputXml);

			String outputXml = WFCallBroker.execute(inputXml, sIpAddress,jtsPort, "WEBLOGIC");
			//WriteToLog("Output XML:= " + outputXml);

			//WriteToLog("Output sMapColNames:= " + sMapColNames);
			//WriteToLog("Output sAttributeName:= " + sAttributeName);
			//WriteToLog("Output sDbColNames:= " + sDbColNames);
		
		 tableXml = generateDynamicTbl(outputXml, sMapColNames,sAttributeName,sDbColNames);
		
		 tableXml="<table width='100%' border=1  id='customers12' cellspacing=0 cellpadding=0 style='margin-left:5.4pt;border-collapse:collapse;solid #000000;'><tr><td id='heading' colspan='50' class=MsoListParagraphCxSpMiddle style='word-wrap: width:100%; color: black; text-align:center; font-weight:bold; break-word:break-all;font-size:15px;' valign='top'>".concat(company_name+"-(Rs in Million except Ratios)").concat("</td></tr>").concat(tableXml).concat("</table>");
		
		// WriteToLog("Output tableXml:= " + tableXml);
		 tableXmlfinal=tableXmlfinal+"<br>"+tableXml;
		// WriteToLog("Output tableXmlfinal:= " + tableXmlfinal);
		 
		
		//if(tempVarGrid.equalsIgnoreCase("NGV_IRLOS_TMP_CAM_AL_FIN"))
		  //  QueryResult = QueryResult;
			//QueryResult = QueryResult + " AND APPLICANT_TYPE ='P' ";
			//sDbColNames = sAttributeName.replaceAll("#", ",");
		
		
	
	
					
					
					//stringBufferHtml.append(str);
					//Long timeDiff = System.currentTimeMillis()-startTimeR;
					//System.out.println( "time diffenerce" +sDbTblName+"-"+timeDiff);
					}			
					
	}
}
	}
	catch (Exception ex) 
	{
		WriteToLog("Error During Generating dynamic table in HTML Template --> " + ex);
	}
	finally
	{
		sDbTblName=null;
		xmlParserObj=null;
		
	}
	return tableXmlfinal;
}

%>

<%!
static NGEjbClient ngEjbClient=null;
static String execute (String inputXmlSelect, String sIpAddress, int jtsPort, String appServerType){
	String outputXML="";
	try{
		if (ngEjbClient == null) {
		ngEjbClient = NGEjbClient.getSharedInstance();
		ngEjbClient.initialize(sIpAddress, ""+jtsPort, appServerType);
		}
		outputXML = ngEjbClient.makeCall(inputXmlSelect);
	}
	catch (Exception ex) 
	{
		System.out.println(ex);
	}
	
	return outputXML;
}
	
%>