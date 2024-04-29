--------------------------------------------------------
--  DDL for Package Body BIS_ERROR_MESSAGE_FORM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_ERROR_MESSAGE_FORM_PVT" AS
/* $Header: BISVERFB.pls 115.10 1999/12/14 08:32:09 pkm ship      $ */
-- +=======================================================================+
-- |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
-- |                         All rights reserved.                          |
-- +=======================================================================+
-- | FILENAME                                                              |
-- |     BISVERFB.pls                                                      |
-- |                                                                       |
-- | DESCRIPTION                                                           |
-- |     Private API for displaying errors
-- | NOTES                                                                 |
-- |                                                                       |
-- | HISTORY                                                               |
-- | 15-APR-99 ansingha Creation
-- |
-- +=======================================================================+


-- Data Types: Records
G_PKG_NAME CONSTANT VARCHAR2(30) := 'BIS_ERROR_MESSAGE_FORM_PVT';
G_WINDOW_NAME CONSTANT VARCHAR2(30) := 'Error Window';
-- Procedure just puts the relevant function in the javascript
-- with all the messages displayed as specified in the p_msg_window_text
PROCEDURE Put_Errors
( p_api_version         IN NUMBER
, p_msg_window_text     IN VARCHAR2
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN

  htp.p('<SCRIPT LANGUAGE="JavaScript">');

  htp.p('FUNCTION '||BIS_ERROR_MESSAGE_FORM_PVT.G_ONLOAD_FUNCTION_NAME||'(){');
--  htp.p('alert("'|| p_msg_window_text||'");');
  htp.p('
  popupWin = window.open( ""
                        ,"'||G_WINDOW_NAME||'"
                        , "width=350,height=400,status=no,toolbar=no,
                           menubar=no,scrollbars=yes,resizable=yes,
                           titlebar=no"
                        );

  popupWin.document.open();
  popupWin.document.title = '||BIS_UTILITIES_PVT.getPrompt
                               ('BIS_ERROR_WINDOW_TITLE')||';
  popupWin.document.write("'||p_msg_window_text||'");
  popupWin.document.close();

       }');
  htp.p('</SCRIPT>');

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Put_Errors'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Put_Errors;
--
-- Procedure just puts the relevant function in the javascript
-- with all the messages displayed as specified by caption and error table
PROCEDURE Put_Errors
( p_api_version         IN NUMBER
, p_caption             IN VARCHAR2
, p_error_Tbl           IN BIS_UTILITIES_PUB.Error_Tbl_Type
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_str VARCHAR2(32000);
BEGIN

  Put_Errors( p_api_version
            , p_caption
            , p_error_Tbl
            , NULL
            , x_return_status
            , x_error_Tbl
            );
/*      BIS_ERROR_MESSAGE_FORM_PVT.Get_Error_String
  				( p_api_version     => p_api_version
  				, p_caption         => p_caption
  				, p_error_Tbl       => p_error_Tbl
  				, x_msg_window_text => l_str
  				, x_return_status   => x_return_status
  				, x_error_Tbl       => x_error_Tbl
  				);
--      htp.header(3, l_str);
      BIS_ERROR_MESSAGE_FORM_PVT.Put_Errors
  				( p_api_version     => p_api_version
  				, p_msg_window_text => l_str
  				, x_return_status   => x_return_status
  				, x_error_Tbl       => x_error_Tbl
  				);

  end if;
*/
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Put_Errors'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Put_Errors;
--
PROCEDURE Put_Errors
( p_api_version         IN  NUMBER
, p_caption             IN  VARCHAR2
, p_error_Tbl           IN  BIS_UTILITIES_PUB.Error_Tbl_Type
, p_form_name           IN  VARCHAR2
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_str VARCHAR2(32000);
BEGIN

  htp.p('<SCRIPT LANGUAGE="JavaScript">');
  htp.p('function '||G_ONLOAD_FUNCTION_NAME||'(){');

  if (p_form_name is NOT NULL) then
    htp.p('if (document.'||p_form_name||'.'||G_ERROR_VARIABLE_NAME||'.value==1){');
  end if;

  if (p_error_Tbl.COUNT > 0) then
    htp.p('alert("'||p_error_Tbl(1).Error_Description||'");');
  elsif (p_caption IS NOT NULL) then
    htp.p('alert("'||p_caption||'");');
  else
    htp.p('null;');
  end if;

  if (p_form_name is NOT NULL) then
    htp.p('}');
    htp.p('document.'||p_form_name||'.'||G_ERROR_VARIABLE_NAME||'.value=0;');
    htp.p('alert(document.'||p_form_name||'.'||G_ERROR_VARIABLE_NAME||'.value);');
  end if;

  htp.p('}');
  htp.p('</SCRIPT>');
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Put_Errors'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Put_Errors;
----
---- Walid's verion: reads the error message form the form variable
----
PROCEDURE Put_Errors
( p_api_version         IN  NUMBER
, p_form_name           IN  VARCHAR2
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_str VARCHAR2(32000);
BEGIN

  htp.p('<SCRIPT LANGUAGE="JavaScript">');
  htp.p('function '||G_ONLOAD_FUNCTION_NAME||'(){');

  if (p_form_name is NULL)
    then
     htp.p('null
	   }'
	   );
     return;
  end if;

  ---- form is OK

  htp.p('if  (LB_isChanged())
	{CF_setChanged();'
--	document.'||p_form_name||'.'||G_ERROR_VARIABLE_NAME||'.value="";
||	'
	};
	if (document.'||p_form_name||'.'||G_ERROR_VARIABLE_NAME||'.value!=""
	    &&
	    !CF_isChanged())
            {'
	);
  htp.p('alert(document.'||p_form_name||'.'
	||G_ERROR_VARIABLE_NAME||'.value)'
	);

--  htp.p('document.'||p_form_name||'.'||G_ERROR_VARIABLE_NAME||'.value="";');
--  htp.p('alert("BEFORE : " + document.'||p_form_name||'.'||G_ERROR_VARIABLE_NAME||'.value);');
--  htp.p('history.go(-1);');
  --htp.p('location.reload(true);');
--  htp.p('alert("AFTER : " + document.'||p_form_name||'.'||G_ERROR_VARIABLE_NAME||'.value);');

  htp.p('}'); --- closes the javascript  if
  htp.p('}'); --- closes the function definition
  htp.p('</SCRIPT>');
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Put_Errors'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Put_Errors;
--
-- Just alerts the SQLERRM and go back 1 page.
--
Procedure Put_Errors
( p_error VARCHAR2
)
IS
BEGIN
    htp.p('<SCRIPT LANGUAGE="JavaScript">');
    htp.p('alert("'||p_error||'");');
    htp.p('history.go(-1)');
    htp.p('</SCRIPT>');

END Put_Errors;

----
----
---- Walid's verions: stores the error mesage in the form field.
----
PROCEDURE Put_Error_Variable
( p_api_version         IN  NUMBER
, p_form_name           IN  VARCHAR2
, p_error_message       IN  VARCHAR2
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN

  BIS_UTILITIES_PVT.PutHtmlVarcharHiddenField
                   ( G_ERROR_VARIABLE_NAME
                   , p_error_message
                   );

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Put_Error_Variable'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Put_Error_Variable;

PROCEDURE Put_Error_Variable
( p_api_version         IN  NUMBER
, p_form_name           IN  VARCHAR2
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN

  BIS_UTILITIES_PVT.PutHtmlNumberHiddenField
                   ( G_ERROR_VARIABLE_NAME
                   , 1
                   );

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Put_Error_Variable'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Put_Error_Variable;

-- Procedure returns a window_text_string to be used in any manner
PROCEDURE Get_Error_String
( p_api_version         IN NUMBER
, p_caption             IN VARCHAR2
, p_error_Tbl           IN BIS_UTILITIES_PUB.Error_Tbl_Type
, x_msg_window_text     OUT VARCHAR2
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_str VARCHAR2(32000) := NULL;
l_msg VARCHAR2(2000);
BEGIN

  l_str := htf.tableOpen;

  if (BIS_UTILITIES_PUB.Value_Not_NULL(p_caption) = FND_API.G_TRUE) then
    -- put main message
    l_str := l_str || htf.tableRowOpen;
--    l_str := l_str || BIS_UTILITIES_PVT.PutNullString(p_caption, 'LEFT',1,5);
    l_str := l_str || BIS_UTILITIES_PVT.PutNullString(htf.bold(p_caption), 'LEFT',1,5);
    l_str := l_str || htf.tableRowClose;
    -- put spacing line
    l_str := l_str || htf.tableRowOpen;
    l_str := l_str || BIS_UTILITIES_PVT.PutNullString(NULL, 'LEFT',1,5);
    l_str := l_str || htf.tableRowClose;
  end if;

  if (p_error_Tbl.COUNT > 0) then

    l_str := l_str || htf.tableRowOpen;
    l_msg := BIS_UTILITIES_PVT.getPrompt('BIS_ERROR_MSG_ID');
    l_str := l_str || htf.tableHeader(l_msg);
    l_msg := BIS_UTILITIES_PVT.getPrompt('BIS_ERROR_MSG_NAME');
    l_str := l_str || htf.tableHeader(l_msg);
    l_msg := BIS_UTILITIES_PVT.getPrompt('BIS_ERROR_DESCRIPTION');
    l_str := l_str || htf.tableHeader(l_msg);
    l_msg := BIS_UTILITIES_PVT.getPrompt('BIS_ERROR_PROC_NAME');
    l_str := l_str || htf.tableHeader(l_msg);
    l_msg := BIS_UTILITIES_PVT.getPrompt('BIS_ERROR_TYPE');
    l_str := l_str || htf.tableHeader(l_msg);
    l_str := l_str || htf.tableRowClose;

    FOR i in 1 .. p_error_Tbl.COUNT loop
      l_str := l_str || htf.tableRowOpen;
--      l_str := l_str || htf.tableData(p_error_tbl(i).Error_Msg_ID      );
--      l_str := l_str || htf.tableData(p_error_tbl(i).Error_Msg_Name    );
--      l_str := l_str || htf.tableData(p_error_tbl(i).Error_Description );
--      l_str := l_str || htf.tableData(p_error_tbl(i).Error_Proc_Name   );
--      l_str := l_str || htf.tableData(p_error_tbl(i).Error_Type        );
      l_str := l_str || htf.tableData(htf.bold(p_error_tbl(i).Error_Msg_ID)      );
      l_str := l_str || htf.tableData(htf.bold(p_error_tbl(i).Error_Msg_Name)    );
      l_str := l_str || htf.tableData(htf.bold(p_error_tbl(i).Error_Description) );
      l_str := l_str || htf.tableData(htf.bold(p_error_tbl(i).Error_Proc_Name)   );
      l_str := l_str || htf.tableData(htf.bold(p_error_tbl(i).Error_Type)        );
      l_str := l_str || htf.tableRowClose;
    end LOOP;
  end if;
  l_str := l_str || htf.tableClose;

  x_msg_window_text := l_str;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Get_Error_String'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Error_String;
--
END BIS_ERROR_MESSAGE_FORM_PVT;

/
