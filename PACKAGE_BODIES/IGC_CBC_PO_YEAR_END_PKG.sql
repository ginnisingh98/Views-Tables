--------------------------------------------------------
--  DDL for Package Body IGC_CBC_PO_YEAR_END_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CBC_PO_YEAR_END_PKG" AS
/*$Header: IGCPOYEB.pls 120.25.12010000.2 2008/08/29 13:20:18 schakkin ship $*/


TYPE exception_rec_type IS RECORD
(document_type     igc_cbc_po_process_excpts_all.document_type%TYPE,
 document_id       igc_cbc_po_process_excpts_all.document_id%TYPE,
 line_id           igc_cbc_po_process_excpts_all.line_id%TYPE,
 line_location_id  igc_cbc_po_process_excpts_all.line_location_id%TYPE,
 distribution_id   igc_cbc_po_process_excpts_all.distribution_id%TYPE,
 exception_reason  igc_cbc_po_process_excpts_all.exception_reason%TYPE,
 exception_code    igc_cbc_po_process_excpts_all.exception_code%TYPE
);

TYPE exception_tbl_type IS TABLE OF exception_rec_type
INDEX BY BINARY_INTEGER;

g_exception_tbl  exception_tbl_type ;
g_exception_tbl_index  NUMBER := 0;
g_pkg_name CONSTANT    VARCHAR2(30):= 'IGC_CBC_PO_YEAR_END_PKG';

g_debug_mode VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
-- bug 2804025 ssmales 19-Feb-2003 created 3 globals below
g_user_id    NUMBER      := FND_GLOBAL.user_id ;
g_login      NUMBER      := FND_GLOBAL.login_id;
g_resp_id    NUMBER      := FND_GLOBAL.resp_id ;


--following variables added for bug 3199488: fnd logging changes: sdixit
   g_debug_level number :=  FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_state_level number :=  FND_LOG.LEVEL_STATEMENT;
   g_proc_level number  :=  FND_LOG.LEVEL_PROCEDURE;
   g_event_level number :=  FND_LOG.LEVEL_EVENT;
   g_excep_level number :=  FND_LOG.LEVEL_EXCEPTION;
   g_error_level number :=  FND_LOG.LEVEL_ERROR;
   g_unexp_level number :=  FND_LOG.LEVEL_UNEXPECTED;
   g_path varchar2(500) :=      'igc.plsql.igcpoyeb.igc_cbc_po_year_end_pkg.';

-- NOTE that in all of the following processing, the return code value signifies the following:
--    0  -  Processing should terminate successfully
--    1  -  Processing should terminate with warnings
--    2  -  Processing should terminate with errors
--  -99  -  Processing should continue



--  Procedure Put_Debug_Msg
--  =======================
--
--  This Procedure writes debug messages to the log file
--
--  IN Parameters
--  -------------
--  p_debug_msg      Message to be output to log file
--
--  OUT Parameters
--  --------------
--
--
/*modifed for 3199488 - fnd logging changes*/
PROCEDURE Put_Debug_Msg (
   p_path           IN VARCHAR2,
   p_debug_msg      IN VARCHAR2,
   p_sev_level      IN VARCHAR2 := g_state_level
) IS
BEGIN

  IF p_sev_level >= g_debug_level THEN
    fnd_log.string(p_sev_level, p_path, p_debug_msg);
  END IF;
END;
/****************
PROCEDURE Put_Debug_Msg (l_full_path,
   p_debug_msg IN VARCHAR2
) IS

-- Constants :

   l_Return_Status    VARCHAR2(1);
   l_api_name         CONSTANT VARCHAR2(30) := 'Put_Debug_Msg';
   l_prod             VARCHAR2(3)           := 'IGC';
   l_sub_comp         VARCHAR2(5)           := 'POYEB';
   l_profile_name     VARCHAR2(255)         := 'IGC_DEBUG_LOG_DIRECTORY';

BEGIN

   IGC_MSGS_PKG.Put_Debug_Msg (l_full_path,p_debug_message    => p_debug_msg,
                               p_profile_log_name => l_profile_name,
                               p_prod             => l_prod,
                               p_sub_comp         => l_sub_comp,
                               p_filename_val     => NULL,
                               x_Return_Status    => l_Return_Status
                              );
   IF (l_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
      fnd_file.put_line(fnd_file.log,'g_exc_error');
      raise FND_API.G_EXC_ERROR;
   END IF;

   RETURN;

-- --------------------------------------------------------------------
-- Exception handler section for the Put_Debug_Msg procedure.
-- --------------------------------------------------------------------
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
       RETURN;

   WHEN OTHERS THEN
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       RETURN;

END Put_Debug_Msg;
*****************/


--  Function Lock_Documents
--  =======================
--
--  This procedure locks the header document, as well as any related lines, shipments and
--  distributions
--
--  IN Parameters
--  -------------
--  p_document_type      Type of document: PO, REQ or REL
--  p_document_id        Id of document
--
--  OUT Parameters
--  --------------
--  Returns Fnd_Api.G_True for success, otherwise G_False
--
FUNCTION Lock_Documents(p_document_type   IN VARCHAR2,
                        p_document_id     IN NUMBER
                        ) RETURN VARCHAR2 AS

CURSOR c_lock_req IS
SELECT 'x'
FROM   po_requisition_headers  prh,
       po_requisition_lines  prl,
       po_req_distributions  prd
WHERE  prh.requisition_header_id = p_document_id
AND    prh.requisition_header_id = prl.requisition_header_id
AND    prl.requisition_line_id = prd.requisition_line_id
FOR UPDATE NOWAIT;

-- Amended Cursor below whilst testing Relock failure
CURSOR c_lock_po IS
SELECT 'x'
FROM   po_headers  poh,
       po_lines   pol ,
       po_line_locations  poll,
       po_distributions  pod
WHERE  poh.po_header_id = p_document_id
AND    poh.po_header_id = pol.po_header_id
AND    pol.po_header_id = poll.po_header_id
AND    poll.po_header_id = pod.po_header_id
FOR UPDATE NOWAIT;

CURSOR c_lock_release IS
SELECT 'x'
FROM   po_releases  por,
       po_line_locations  poll,
       po_distributions  pod
WHERE  por.po_release_id = p_document_id
AND    por.po_release_id = poll.po_release_id
AND    poll.po_release_id = pod.po_release_id
FOR UPDATE NOWAIT;

CURSOR c_lock_bpa IS
SELECT 'x'
FROM   po_headers  poh,
       po_distributions  pod
WHERE  poh.po_header_id = p_document_id
AND    poh.po_header_id = pod.po_header_id
FOR UPDATE NOWAIT;

l_lock_req       c_lock_req%ROWTYPE;
l_lock_po        c_lock_po%ROWTYPE;
l_lock_release   c_lock_release%ROWTYPE;
l_lock_bpa       c_lock_bpa%ROWTYPE;
l_exception      BOOLEAN;
l_full_path      VARCHAR2(500) := g_path||'Lock_Documents';
BEGIN

  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg (l_full_path,p_debug_msg => '**** Lock Document ****');
  END IF;

-- lock document header and children, depending upon document type
  IF p_document_type = 'PO'
  THEN
     FOR i IN 1 .. 10000 LOOP
        l_exception := FALSE;
        BEGIN
           OPEN c_lock_po;
           FETCH c_lock_po INTO l_lock_po;
           CLOSE c_lock_po;
        EXCEPTION
           WHEN OTHERS THEN
              IF (SQLCODE = -54) THEN -- record already locked
                 l_exception := TRUE ;
              ELSE
                 APP_EXCEPTION.Raise_Exception;
              END IF;
        END;
        IF l_exception = FALSE THEN
           IF g_debug_mode = 'Y' THEN
               Put_Debug_Msg (l_full_path,p_debug_msg => 'lock loop:'||i);
           END IF;
        END IF;
        EXIT WHEN l_exception = FALSE;
     END LOOP;
  ELSIF p_document_type = 'REQ'
  THEN
     FOR i IN 1 .. 10000 LOOP
        l_exception := FALSE;
        BEGIN
           OPEN c_lock_req;
           FETCH c_lock_req INTO l_lock_req;
           CLOSE c_lock_req;
        EXCEPTION
           WHEN OTHERS THEN
              IF (SQLCODE = -54) THEN -- record already locked
                 l_exception := TRUE ;
              ELSE
                 APP_EXCEPTION.Raise_Exception;
              END IF;
        END;
        IF l_exception = FALSE THEN
           IF g_debug_mode = 'Y' THEN
               Put_Debug_Msg (l_full_path,p_debug_msg => 'lock loop:'||i);
           END IF;
        END IF;
        EXIT WHEN l_exception = FALSE;
     END LOOP;
  ELSIF p_document_type = 'REL'
  THEN
     FOR i IN 1 .. 10000 LOOP
        l_exception := FALSE;
        BEGIN
           OPEN c_lock_release;
           FETCH c_lock_release INTO l_lock_release;
           CLOSE c_lock_release;
        EXCEPTION
           WHEN OTHERS THEN
              IF (SQLCODE = -54) THEN -- record already locked
                 l_exception := TRUE ;
              ELSE
                 APP_EXCEPTION.Raise_Exception;
              END IF;
        END;
        IF l_exception = FALSE THEN
           IF g_debug_mode = 'Y' THEN
               Put_Debug_Msg (l_full_path,p_debug_msg => 'lock loop:'||i);
           END IF;
        END IF;
        EXIT WHEN l_exception = FALSE;
     END LOOP;
  -- Added for PRC.FP.J, 3173178
  ELSIF p_document_type = 'PA'
  THEN
     FOR i IN 1 .. 10000 LOOP
        l_exception := FALSE;
        BEGIN
           OPEN c_lock_bpa;
           FETCH c_lock_bpa INTO l_lock_bpa;
           CLOSE c_lock_bpa;
        EXCEPTION
           WHEN OTHERS THEN
              IF (SQLCODE = -54) THEN -- record already locked
                 l_exception := TRUE ;
              ELSE
                 APP_EXCEPTION.Raise_Exception;
              END IF;
        END;
        IF l_exception = FALSE THEN
           IF g_debug_mode = 'Y' THEN
               Put_Debug_Msg (l_full_path,p_debug_msg => 'lock loop:'||i);
           END IF;
        END IF;
        EXIT WHEN l_exception = FALSE;
     END LOOP;
  END IF; -- p_document_type = 'PO'

  IF l_exception = FALSE THEN
     RETURN FND_API.G_RET_STS_SUCCESS;
  ELSE
     RETURN FND_API.G_RET_STS_ERROR;
  END IF;


EXCEPTION
  WHEN OTHERS THEN
     IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Lock_Documents');
     END IF;
     IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
     END IF;
     APP_EXCEPTION.Raise_Exception;
END Lock_Documents;



--  Procedure Log_Error
--  ===================
--
--  This procedure copies any exceptions logged in the pl/sql table to the CBC exceptions table.
--  The purpose of this is to minimize database i/o  calls.
--
--  IN Parameters
--  -------------
--  p_sob_id             Set of Books Id
--  p_org_id             Org Id
--  p_conc_request_id    Concurrent Request Id
--  p_process_phase      User entered processing phase: F - Final, P - Preliminary
--
--  OUT Parameters
--  --------------
--
--
PROCEDURE Log_Error(p_sobid            IN NUMBER,
                    p_org_id           IN NUMBER,
                    p_conc_request_id  IN NUMBER,
                    p_process_phase    IN VARCHAR2
                    ) IS



l_full_path      VARCHAR2(500) := g_path||'Log_error';
BEGIN

  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg (l_full_path,p_debug_msg => '**** Log Error ****');
  END IF;

-- check to ensure that exceptions are present in pl/sql table
  IF g_exception_tbl_index > 0
  THEN
-- insert any records in global pl/sql exception table into igc exceptions table
-- bug 2804025 ssmales 19-Feb-2003 amended below to user g_user_id,g_login
     FOR l_index IN g_exception_tbl.FIRST .. g_exception_tbl.LAST
     LOOP
     INSERT INTO igc_cbc_po_process_excpts_all
                    (
                     document_type,
                     document_id,
                     line_id,
                     line_location_id,
                     distribution_id,
                     org_id,
                     sob_id,
                     process_type,
                     process_phase,
                     conc_request_id,
                     exception_code,
                     exception_reason,
                     last_update_date,
                     last_updated_by,
                     last_update_login,
                     creation_date,
                     created_by
                     )
                    VALUES
                    (
                     g_exception_tbl(l_index).document_type,
                     g_exception_tbl(l_index).document_id,
                     g_exception_tbl(l_index).line_id,
                     g_exception_tbl(l_index).line_location_id,
                     g_exception_tbl(l_index).distribution_id,
                     p_org_id,
                     p_sobid,
                     'YE',
                     p_process_phase,
                     p_conc_request_id,
                     g_exception_tbl(l_index).exception_code,
                     g_exception_tbl(l_index).exception_reason,
                     SYSDATE,
                     g_user_id,
                     g_login,
                     SYSDATE,
                     g_user_id
                     );
     END LOOP
     COMMIT;
   -- reset index and clear pl/sql  table
     g_exception_tbl_index := 0;
     g_exception_tbl.DELETE;

  END IF; -- g_exception_tbl_index > 0

  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg (l_full_path,p_debug_msg => '**** Log Error - Completed ****');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Log_Error');
     END IF;
     IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
     END IF;
     APP_EXCEPTION.Raise_Exception;
END Log_Error;



--  Procedure Execute_Exceptions_Report
--  ===================================
--
--  This procedure initiates a concurrent process to run the PO CBC Year End Exceptions report.
--
--  IN Parameters
--  -------------
--  p_sob_id             Set of Books Id
--  p_org_id             Org Id
--  p_conc_request_id    Concurrent Request Id
--  p_process_phase      User entered processing phase: F - Final, P - Preliminary
--  p_year               User entered Year being closed
--
--  OUT Parameters
--  --------------
--
--
PROCEDURE Execute_Exceptions_Report(p_sobid            IN NUMBER,
                                    p_org_id           IN NUMBER,
                                    p_conc_request_id  IN NUMBER,
                                    p_process_phase    IN VARCHAR2,
                                    p_year             IN NUMBER
                                    ) IS

l_request_id     NUMBER := 0;

l_full_path      VARCHAR2(500) := g_path||'Execute_Exceptions_Report';
------Variables related to XML Report
l_terr                      VARCHAR2(10):='US';
l_lang                      VARCHAR2(10):='en';
l_layout                    BOOLEAN;
BEGIN
    IF (g_debug_mode = 'Y') THEN
       Put_Debug_Msg (l_full_path,p_debug_msg => '**** Execute Exceptions Report ****');
    END IF;

-- Initiate Exceptions Report

/*Bug No : 6341012. MOAC uptake. Set Operaating Unit for the request before submitting. */

    fnd_request.set_org_id(p_org_id);

    l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                         APPLICATION => 'IGC',
                         PROGRAM     => 'IGCPOYEE',
                         DESCRIPTION => 'PO Year End Exceptions Report',
                         START_TIME  => NULL,
                         SUB_REQUEST => FALSE,
                         ARGUMENT1   => p_sobid,
                         ARGUMENT2   => p_org_id,
                         ARGUMENT3   => p_process_phase,
                         ARGUMENT4   => p_year,
                         ARGUMENT5   => p_conc_request_id,
                         ARGUMENT6   => NULL,
                         ARGUMENT7   => NULL,
                         ARGUMENT8   => NULL,
                         ARGUMENT9   => NULL,
                         ARGUMENT10  => NULL,
                         ARGUMENT11  => NULL,
                         ARGUMENT12  => NULL,
                         ARGUMENT13 => NULL, ARGUMENT14 => NULL,
                         ARGUMENT15  => NULL, ARGUMENT16 => NULL, ARGUMENT17 => NULL,
                         ARGUMENT18  => NULL, ARGUMENT19 => NULL, ARGUMENT20 => NULL,
                         ARGUMENT21  => NULL, ARGUMENT22 => NULL, ARGUMENT23 => NULL,
                         ARGUMENT24  => NULL, ARGUMENT25 => NULL, ARGUMENT26 => NULL,
                         ARGUMENT27  => NULL, ARGUMENT28 => NULL, ARGUMENT29 => NULL,
                         ARGUMENT30  => NULL, ARGUMENT31 => NULL, ARGUMENT32 => NULL,
                         ARGUMENT33  => NULL, ARGUMENT34 => NULL, ARGUMENT35 => NULL,
                         ARGUMENT36  => NULL, ARGUMENT37 => NULL, ARGUMENT38 => NULL,
                         ARGUMENT39  => NULL, ARGUMENT40 => NULL, ARGUMENT41 => NULL,
                         ARGUMENT42  => NULL, ARGUMENT43 => NULL, ARGUMENT44 => NULL,
                         ARGUMENT45  => NULL, ARGUMENT46 => NULL, ARGUMENT47 => NULL,
                         ARGUMENT48  => NULL, ARGUMENT49 => NULL, ARGUMENT50 => NULL,
                         ARGUMENT51  => NULL, ARGUMENT52 => NULL, ARGUMENT53 => NULL,
                         ARGUMENT54  => NULL, ARGUMENT55 => NULL, ARGUMENT56 => NULL,
                         ARGUMENT57  => NULL, ARGUMENT58 => NULL, ARGUMENT59 => NULL,
                         ARGUMENT60  => NULL, ARGUMENT61 => NULL, ARGUMENT62 => NULL,
                         ARGUMENT63  => NULL, ARGUMENT64 => NULL, ARGUMENT65 => NULL,
                         ARGUMENT66  => NULL, ARGUMENT67 => NULL, ARGUMENT68 => NULL,
                         ARGUMENT69  => NULL, ARGUMENT70 => NULL, ARGUMENT71 => NULL,
                         ARGUMENT72  => NULL, ARGUMENT73 => NULL, ARGUMENT74 => NULL,
                         ARGUMENT75  => NULL, ARGUMENT76 => NULL, ARGUMENT77 => NULL,
                         ARGUMENT78  => NULL, ARGUMENT79 => NULL, ARGUMENT80 => NULL,
                         ARGUMENT81  => NULL, ARGUMENT82 => NULL, ARGUMENT83 => NULL,
                         ARGUMENT84  => NULL, ARGUMENT85 => NULL, ARGUMENT86 => NULL,
                         ARGUMENT87  => NULL, ARGUMENT88 => NULL, ARGUMENT89 => NULL,
                         ARGUMENT90  => NULL, ARGUMENT91 => NULL, ARGUMENT92 => NULL,
                         ARGUMENT93  => NULL, ARGUMENT94 => NULL, ARGUMENT95 => NULL,
                         ARGUMENT96  => NULL, ARGUMENT97 => NULL, ARGUMENT98 => NULL,
                         ARGUMENT99  => NULL, ARGUMENT100 => NULL );

    IF l_request_id = 0 THEN
       fnd_message.set_name('IGC','IGC_CC_ER_SUBMIT_EXCPTION_RPT');
       IF (g_debug_mode = 'Y')  THEN
          Put_Debug_Msg (l_full_path,fnd_message.get,g_event_level);
       END IF;
       app_exception.raise_exception;
    END IF; -- l_request_id = 0

    IF (g_debug_mode = 'Y') THEN
       Put_Debug_Msg (l_full_path,p_debug_msg => '**** Completed Execute Exceptions Report ****');
    END IF;

---------------------------------
------Run XML Report
---------------------------------
    IF IGC_CC_COMMON_UTILS_PVT.xml_report_enabled THEN
               IGC_CC_COMMON_UTILS_PVT.get_xml_layout_info(
                                            l_lang,
                                            l_terr,
                                            'IGCPOYEE_XML',
                                            'IGC',
                                            'IGCPOYEE_XML' );

               l_layout :=  FND_REQUEST.ADD_LAYOUT(
                                            'IGC',
                                            'IGCPOYEE_XML',
                                            l_lang,
                                            l_terr,
                                            'RTF');
             IF l_layout then
		    l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                         APPLICATION => 'IGC',
                         PROGRAM     => 'IGCPOYEE_XML',
                         DESCRIPTION => 'PO Year End Exceptions Report',
                         START_TIME  => NULL,
                         SUB_REQUEST => FALSE,
                         ARGUMENT1   => p_sobid,
                         ARGUMENT2   => p_org_id,
                         ARGUMENT3   => p_process_phase,
                         ARGUMENT4   => p_year,
                         ARGUMENT5   => p_conc_request_id,
                         ARGUMENT6   => NULL,
                         ARGUMENT7   => NULL,
                         ARGUMENT8   => NULL,
                         ARGUMENT9   => NULL,
                         ARGUMENT10  => NULL,
                         ARGUMENT11  => NULL,
                         ARGUMENT12  => NULL,
                         ARGUMENT13 => NULL, ARGUMENT14 => NULL,
                         ARGUMENT15  => NULL, ARGUMENT16 => NULL, ARGUMENT17 => NULL,
                         ARGUMENT18  => NULL, ARGUMENT19 => NULL, ARGUMENT20 => NULL,
                         ARGUMENT21  => NULL, ARGUMENT22 => NULL, ARGUMENT23 => NULL,
                         ARGUMENT24  => NULL, ARGUMENT25 => NULL, ARGUMENT26 => NULL,
                         ARGUMENT27  => NULL, ARGUMENT28 => NULL, ARGUMENT29 => NULL,
                         ARGUMENT30  => NULL, ARGUMENT31 => NULL, ARGUMENT32 => NULL,
                         ARGUMENT33  => NULL, ARGUMENT34 => NULL, ARGUMENT35 => NULL,
                         ARGUMENT36  => NULL, ARGUMENT37 => NULL, ARGUMENT38 => NULL,
                         ARGUMENT39  => NULL, ARGUMENT40 => NULL, ARGUMENT41 => NULL,
                         ARGUMENT42  => NULL, ARGUMENT43 => NULL, ARGUMENT44 => NULL,
                         ARGUMENT45  => NULL, ARGUMENT46 => NULL, ARGUMENT47 => NULL,
                         ARGUMENT48  => NULL, ARGUMENT49 => NULL, ARGUMENT50 => NULL,
                         ARGUMENT51  => NULL, ARGUMENT52 => NULL, ARGUMENT53 => NULL,
                         ARGUMENT54  => NULL, ARGUMENT55 => NULL, ARGUMENT56 => NULL,
                         ARGUMENT57  => NULL, ARGUMENT58 => NULL, ARGUMENT59 => NULL,
                         ARGUMENT60  => NULL, ARGUMENT61 => NULL, ARGUMENT62 => NULL,
                         ARGUMENT63  => NULL, ARGUMENT64 => NULL, ARGUMENT65 => NULL,
                         ARGUMENT66  => NULL, ARGUMENT67 => NULL, ARGUMENT68 => NULL,
                         ARGUMENT69  => NULL, ARGUMENT70 => NULL, ARGUMENT71 => NULL,
                         ARGUMENT72  => NULL, ARGUMENT73 => NULL, ARGUMENT74 => NULL,
                         ARGUMENT75  => NULL, ARGUMENT76 => NULL, ARGUMENT77 => NULL,
                         ARGUMENT78  => NULL, ARGUMENT79 => NULL, ARGUMENT80 => NULL,
                         ARGUMENT81  => NULL, ARGUMENT82 => NULL, ARGUMENT83 => NULL,
                         ARGUMENT84  => NULL, ARGUMENT85 => NULL, ARGUMENT86 => NULL,
                         ARGUMENT87  => NULL, ARGUMENT88 => NULL, ARGUMENT89 => NULL,
                         ARGUMENT90  => NULL, ARGUMENT91 => NULL, ARGUMENT92 => NULL,
                         ARGUMENT93  => NULL, ARGUMENT94 => NULL, ARGUMENT95 => NULL,
                         ARGUMENT96  => NULL, ARGUMENT97 => NULL, ARGUMENT98 => NULL,
                         ARGUMENT99  => NULL, ARGUMENT100 => NULL );

                   IF l_request_id = 0 THEN
                         fnd_message.set_name('IGC','IGC_CC_ER_SUBMIT_EXCPTION_RPT');
                         IF (g_debug_mode = 'Y')  THEN
                             Put_Debug_Msg (l_full_path,fnd_message.get,g_event_level);
                         END IF;
                        app_exception.raise_exception;
                  END IF; -- l_request_id = 0
                 IF (g_debug_mode = 'Y') THEN
                     Put_Debug_Msg (l_full_path,p_debug_msg => '**** Completed Execute Exceptions Report ****');
                 END IF;
	     END IF;
         END IF;
--------------------
-- End of XML Report
--------------------
   COMMIT;


EXCEPTION
    WHEN OTHERS THEN
       fnd_message.set_name('IGC','IGC_CC_ER_SUBMIT_EXCPTION_RPT');
       IF g_debug_mode = 'Y' THEN
          Put_Debug_Msg (l_full_path,fnd_message.get,g_error_level);
       END IF;
       app_exception.raise_exception;
     IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
     END IF;

END Execute_Exceptions_Report;



--  Procedure Insert_Exception_Record
--  =================================
--
--  This procedure inserts exception detail records into the pl/sql exceptions table.
--
--  IN Parameters
--  -------------
--  p_document_type      Type of document: PO, REQ , 'PA' or REL
--  p_document_id        Id of document
--  p_line_id            Id of document line
--  p_line_location_id   Id of document line location
--  p_distribution_id    Id of document distribution
--  p_exception_reason   Description of exception
--  p_exception_code     Code of exception
--
--  OUT Parameters
--  --------------
--
--
PROCEDURE Insert_Exception_Record(p_document_type    IN VARCHAR2 := NULL,
                                  p_document_id      IN NUMBER   := NULL,
                                  p_line_id          IN NUMBER   := NUll,
                                  p_line_location_id IN NUMBER   := NULL,
                                  p_distribution_id  IN NUMBER   := NULL,
                                  p_exception_reason IN VARCHAR2,
                                  p_exception_code   IN VARCHAR2 := NULL
                                  ) AS

l_full_path      VARCHAR2(500) := g_path||'Insert_Exception_Record';
BEGIN

  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg (l_full_path,p_debug_msg => '**** Insert Exception Record ****');
  END IF;

-- insert exception record into pl/sql table

  g_exception_tbl_index := g_exception_tbl_index + 1;

  g_exception_tbl(g_exception_tbl_index).document_type     := p_document_type ;
  g_exception_tbl(g_exception_tbl_index).document_id       := p_document_id ;
  g_exception_tbl(g_exception_tbl_index).line_id           := p_line_id ;
  g_exception_tbl(g_exception_tbl_index).line_location_id  := p_line_location_id ;
  g_exception_tbl(g_exception_tbl_index).distribution_id   := p_distribution_id ;
  g_exception_tbl(g_exception_tbl_index).exception_reason  := p_exception_reason ;
  g_exception_tbl(g_exception_tbl_index).exception_code    := p_exception_code ;

EXCEPTION
  WHEN OTHERS THEN
     IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Insert_Exception_Record');
     END IF;
     IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
     END IF;
     APP_EXCEPTION.Raise_Exception;

END Insert_Exception_Record;



--  Procedure Validate_BC_Params
--  ============================
--
--  The purpose of this procedure is to check whether Budgetary Control is enabled
--  in the Standard and Commitment Budgets for PO's and Requisitions.
--  In the event of both Standard PO and Requisition encumbrance being disabled, terminate processing
--
--  IN Parameters
--  -------------
--  p_sob_id             Set of Books Id
--  p_org_id             Org Id
--  p_process_phase      User entered processing phase: F - Final, P - Preliminary
--  p_year               User entered Year being closed
--  p_trunc_exception    User entered choice to truncate the exception table: Y or N
--
--  OUT Parameters
--  --------------
--  x_po_enc_on          Flag indicating whether SBC PO encumbrance is enabled
--  x_req_enc_on         Flag indicating whether SBC Req encumbrance is enabled
--  x_return_code        Indicates the return status of the procedure:
--                           0 - Need to terminate processing successfully
--                           1 - Need to terminate processing with warning
--                           2 - Need to terminate processing with error
--                         -99 - Successful, continue processing
--  x_msg_buf            stores any error message encountered
--
--
PROCEDURE Validate_BC_Params
(
  p_sobid                         IN       NUMBER,
  p_org_id                        IN       NUMBER,
  p_process_phase                 IN       VARCHAR2,
  p_year                          IN       NUMBER,
  p_trunc_exception               IN       VARCHAR2,
  x_po_enc_on                     OUT NOCOPY  BOOLEAN,
  x_req_enc_on                    OUT NOCOPY  BOOLEAN,
  x_return_code                   OUT NOCOPY  NUMBER,
  x_msg_buf                       OUT NOCOPY  VARCHAR2
) AS


  CURSOR c_sbc_enabled IS
  SELECT glsob.enable_budgetary_control_flag
        ,glsob.chart_of_accounts_id
  FROM   gl_sets_of_books glsob
  WHERE glsob.set_of_books_id = p_sobid ;

  CURSOR c_sbc_encumbrances IS
  SELECT req_encumbrance_type_id,
         purch_encumbrance_type_id,
         req_encumbrance_flag,
         purch_encumbrance_flag
  FROM   financials_system_parameters
  WHERE  set_of_books_id = p_sobid ;

/*Bug No : 6341012. SLA uptake. The table IGC_CC_ENCMBRNC_CTRLS_V no more exists.

  CURSOR c_cbc_encumbrances IS
  SELECT cc_prov_encmbrnc_type_id,
         cc_conf_encmbrnc_type_id,
         cc_prov_encmbrnc_enable_flag,
         cc_conf_encmbrnc_enable_flag
  FROM   igc_cc_encmbrnc_ctrls_v
  WHERE  org_id = p_org_id ;
*/

  l_cbc_enabled               VARCHAR2(1) := 'N' ;
  l_sbc_enabled               VARCHAR2(1) := 'N' ;
  l_coa_id                    NUMBER := 0 ;
  l_req_enc_type_id           NUMBER := 0 ;
  l_pur_enc_type_id           NUMBER := 0 ;
  l_req_enc_flag              VARCHAR2(1) := 'N' ;
  l_pur_enc_flag              VARCHAR2(1) := 'N' ;
/*Bug No : 6341012. SLA uptake. Encumbrance_Type_Ids are not required.  */
--  l_prv_enc_type_id           NUMBER := 0 ;
--  l_con_enc_type_id           NUMBER := 0 ;
--  l_prv_enc_flag              VARCHAR2(1) := 'N' ;
--  l_con_enc_flag              VARCHAR2(1) := 'N' ;
  l_sql_string                VARCHAR2(100) := null ;
  l_return_status             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count                 NUMBER := 0 ;
  l_msg_data                  VARCHAR2(2000) := null ;
  l_err_code                  VARCHAR2(100) := null ;

  E_IGC_CBC_PO_DISABLE_YEP    EXCEPTION ;
  E_IGC_CBC_PO_ON_SBC_OFF     EXCEPTION ;
  E_IGC_CC_INVALID_SET_UP     EXCEPTION ;


l_full_path      VARCHAR2(500) := g_path||'Validate_BC_Params';
BEGIN

   IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg (l_full_path,p_debug_msg => '**** Validate Budgetary Control Parameters ****');
   END IF;

-- Check if CBC is enabled for Purchasing

   IGC_CBC_PO_GRP.IS_CBC_ENABLED(
                                 p_api_version            => 1
                                ,p_init_msg_list          => 'T'
                                ,p_commit                 => 'F'
                                ,p_validation_level       => 100
                                ,x_return_status          => l_return_status
                                ,x_msg_count              => l_msg_count
                                ,x_msg_data               => l_msg_data
                                ,x_cbc_enabled            => l_cbc_enabled
                                ) ;

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS
  THEN
     -- if update unsuccessful report errors
     l_msg_data := '';
     For j in 1..NVL(l_msg_count,0) LOOP
        l_msg_data := FND_MSG_PUB.Get(p_msg_index => j,
                                      p_encoded   => 'T');
        Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                                p_exception_code     =>  l_return_status
                                );
     END LOOP;
     x_return_code := 2;
     x_msg_buf := l_msg_data;
     RETURN ;
  END IF ;

  IF l_cbc_enabled = 'N'
  THEN
     -- since CBC is not enabled for PO, Year End Process should not be run. Terminate with Error
     Raise E_IGC_CBC_PO_DISABLE_YEP ;
  ELSE -- l_cbc_enabled = 'N'
     -- Check that Standard Budgetary Control is enabled
     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => 'Checking SBC enabled');
     END IF;

     OPEN  c_sbc_enabled ;
     FETCH c_sbc_enabled
     INTO l_sbc_enabled
         ,l_coa_id ;
     CLOSE c_sbc_enabled ;

     IF l_sbc_enabled = 'N'
     THEN
        -- Error, as CBC cannot be enabled without SBC being enabled.  Terminate with Error
        Raise E_IGC_CBC_PO_ON_SBC_OFF ;
     END IF;

  END IF; -- l_cbc_enabled = 'N'

-- Clear the exceptions table if user has selected Yes for Truncate parameter
  IF p_trunc_exception = 'Y'
  THEN
     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => 'Truncating igc_cbc_po_process_excpts_all table');
     END IF;

     DELETE FROM igc_cbc_po_process_excpts_all;
--     l_sql_string := 'TRUNCATE table igc_cbc_po_process_excpts_all' ;
--     EXECUTE IMMEDIATE l_sql_string;
  END IF ; -- p_trunc_exception = 'Y'

  -- Both SBC and CBC are enabled, so get encumbrance types
  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg (l_full_path,p_debug_msg => 'Getting sbc encumbrance details');
  END IF;
  OPEN c_sbc_encumbrances ;
  FETCH c_sbc_encumbrances INTO
         l_req_enc_type_id,
         l_pur_enc_type_id,
         l_req_enc_flag,
         l_pur_enc_flag ;
  CLOSE c_sbc_encumbrances ;

  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg (l_full_path,p_debug_msg => 'Getting cbc encumbrance details');
  END IF;

/*Bug No : 6341012. SLA uptake. This cursor is not required as the table IGC_CC_ENCMBRNC_CTRLS_V is obsoleted.

  OPEN c_cbc_encumbrances ;
  FETCH c_cbc_encumbrances INTO
         l_prv_enc_type_id,
         l_con_enc_type_id,
         l_prv_enc_flag,
         l_con_enc_flag ;
  CLOSE c_cbc_encumbrances ;

-- Check for Invalid setup.  If invalid terminate with Error.
  IF (l_req_enc_type_id IS NOT NULL AND l_prv_enc_type_id IS NULL ) OR
     (l_pur_enc_type_id IS NOT NULL AND l_con_enc_type_id IS NULL )
  THEN
     RAISE E_IGC_CC_INVALID_SET_UP ;
  END IF ;
*/

-- Set encumbrance OUT parameters
  IF l_req_enc_flag = 'Y'
  THEN
     x_req_enc_on := TRUE ;
  ELSE
     x_req_enc_on := FALSE ;
  END IF;

  IF l_pur_enc_flag = 'Y'
  THEN
      x_po_enc_on := TRUE ;
  ELSE
      x_po_enc_on := FALSE ;
  END IF ;

-- Record encumbrance exceptions
  IF NOT x_req_enc_on
  THEN
     l_err_code := 'IGC_PO_YEP_REQ_ENC_OFF';
     FND_MESSAGE.set_name('IGC',l_err_code);
     l_msg_data := FND_MESSAGE.get;
     Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                             p_exception_code     =>  l_err_code);
  END IF; -- NOT x_req_enc_on

  IF NOT x_po_enc_on
  THEN
     l_err_code := 'IGC_PO_YEP_PO_ENC_OFF';
     FND_MESSAGE.set_name('IGC',l_err_code);
     l_msg_data := FND_MESSAGE.get;
     Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                             p_exception_code     =>  l_err_code);
  END IF ; -- NOT x_po_enc_on

-- If both Req and PO encumbrances are off then terminate processing

  IF NOT x_req_enc_on AND NOT x_po_enc_on
  THEN
     x_return_code := 0;
     RETURN;

  END IF; -- NOT x_req_enc_on AND NOT x_po_enc_on
  x_return_code := -99;

EXCEPTION
  WHEN E_IGC_CBC_PO_DISABLE_YEP THEN
     l_err_code := 'IGC_CBC_PO_DISABLE_YEP';
     FND_MESSAGE.set_name('IGC',l_err_code);
     IF(g_excep_level >= g_debug_level) THEN
          FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
     END IF;
     x_msg_buf := FND_MESSAGE.Get;
     x_return_code := 2 ;
  WHEN E_IGC_CBC_PO_ON_SBC_OFF THEN
     l_err_code := 'IGC_CBC_PO_ON_SBC_OFF';
     FND_MESSAGE.set_name('IGC',l_err_code);
     IF(g_excep_level >= g_debug_level) THEN
          FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
     END IF;
     x_msg_buf := FND_MESSAGE.Get;
     x_return_code := 2 ;
  WHEN E_IGC_CC_INVALID_SET_UP THEN
     l_err_code := 'IGC_CC_INVALID_SET_UP';
     FND_MESSAGE.set_name('IGC',l_err_code);
     IF(g_excep_level >= g_debug_level) THEN
          FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
     END IF;
     x_msg_buf := FND_MESSAGE.Get;
     x_return_code := 2 ;
  WHEN OTHERS THEN
     IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Validate_BC_Params');
     END IF;
     fnd_message.set_name('IGC','IGC_LOGGING_USER_ERROR');
     x_msg_buf := fnd_message.get;
     x_return_code := 2 ;
     IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
     END IF;


END Validate_BC_Params;




--  Function Validate_Period_Status
--  ===============================
--
--  The purpose of this function is to check whether the GL and PO periods are in the expected
--  state to process Year End, and determine specific dates required by subsequent processing.
--  Validations are only carried out if in Final Mode.
--
--  IN Parameters
--  -------------
--  p_sob_id             Set of Books Id
--  p_org_id             Org Id
--  p_process_phase      User entered processing phase: F - Final, P - Preliminary
--  p_year               User entered Year being closed
--
--  OUT Parameters
--  --------------
--  x_prev_year_start_date    Start Date of year being closed
--  x_prev_year_end_date      End Date of year being closed
--  x_prev_year_end_period    End period name of year being closed
--  x_prev_year_end_num       End period number of year being closed
--  x_prev_year_end_quarter   End quarter number of year being closed
--  x_curr_year_start_date    Start Date of the current year
--  x_curr_year_start_period  First period name of the current year
--  x_curr_year_start_num     First period number of the current year
--  x_curr_year_start_quarter First quarter number of the current year
--
--  Function returns True for success, False for validation failure.
--
-- bug 2804025 ssmales 19-Feb-2003 added prev_year_end_period/num/quarter and curr_year_start_num/quarter
FUNCTION  Validate_Period_Status(p_sobid                   IN NUMBER,
                                 p_org_id                  IN NUMBER,
                                 p_process_phase           IN VARCHAR2,
                                 p_year                    IN NUMBER,
                                 x_prev_year_start_date    OUT NOCOPY DATE,
                                 x_prev_year_end_date      OUT NOCOPY DATE,
                                 x_prev_year_end_period    OUT NOCOPY VARCHAR2,
                                 x_prev_year_end_num       OUT NOCOPY NUMBER,
                                 x_prev_year_end_quarter   OUT NOCOPY NUMBER,
                                 x_curr_year_start_date    OUT NOCOPY DATE,
                                 x_curr_year_start_period  OUT NOCOPY VARCHAR2,
                                 x_curr_year_start_num     OUT NOCOPY NUMBER,
                                 x_curr_year_start_quarter OUT NOCOPY NUMBER
                                ) RETURN BOOLEAN IS



-- bug 2804025 ssmales 19-Feb-2003 added quarter num to period_dtls_rec_type
TYPE period_dtls_rec_type IS RECORD
(period_num         igc_tbl_number,
 period_name        igc_tbl_varchar30,
 start_date         igc_tbl_date,
 end_date           igc_tbl_date,
 gl_period_status   igc_tbl_varchar5,
 po_period_status   igc_tbl_varchar5,
 quarter_num        igc_tbl_number );


l_prd_dtls_rec       period_dtls_rec_type ;
l_curr_period_rec    period_dtls_rec_type ;

l_msg_data         VARCHAR2(2000) := null ;
l_err_code         VARCHAR2(100) := null ;


-- bug 2804025 ssmales 19-Feb-2003 added quarter_num to select below
CURSOR c_get_prd_dtls(c_p_year NUMBER) IS
SELECT gp.period_num,
       gp.period_name,
       gps.start_date,
       gps.end_date,
       gps.closing_status   gl_period_status,
       pos.closing_status   po_period_status,
       gp.quarter_num
FROM   gl_period_statuses   gps,
       gl_periods           gp,
       gl_period_statuses   pos,
       gl_sets_of_books     gb,
       fnd_application      gl,
       fnd_application      po
WHERE  gb.set_of_books_id = p_sobid
AND    gp.period_set_name = gb.period_set_name
AND    gp.period_type = gb.accounted_period_type
AND    gps.set_of_books_id = gb.set_of_books_id
AND    gps.period_name = gp.period_name
AND    gps.application_id = gl.application_id
AND    gps.period_num = gp.period_num
AND    gl.application_short_name = 'SQLGL'
AND    gp.period_year = c_p_year
AND    gp.adjustment_period_flag = 'N'
AND    pos.set_of_books_id = gb.set_of_books_id
AND    pos.period_name = gp.period_name
AND    pos.application_id = po.application_id
AND    po.application_short_name = 'PO'
AND    pos.period_num = gps.period_num
ORDER BY gp.period_num ASC ;


l_full_path      VARCHAR2(500) := g_path||'Validate_Period_Status';
BEGIN

  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg (l_full_path,p_debug_msg => '**** Validate Period Status ****');
  END IF;


-- Validate Previous Year's details
  OPEN  c_get_prd_dtls(p_year) ;

  FETCH c_get_prd_dtls BULK COLLECT INTO l_prd_dtls_rec.period_num,
                                         l_prd_dtls_rec.period_name,
                                         l_prd_dtls_rec.start_date,
                                         l_prd_dtls_rec.end_date,
                                         l_prd_dtls_rec.gl_period_status,
                                         l_prd_dtls_rec.po_period_status,
                                         l_prd_dtls_rec.quarter_num ;


  CLOSE c_get_prd_dtls ;

  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg (l_full_path,p_debug_msg => 'Completed getting period details');
  END IF;

-- Validate First Period
  FOR l_period_index IN l_prd_dtls_rec.period_num.FIRST .. l_prd_dtls_rec.period_num.LAST
  LOOP

     IF l_period_index = 1
     THEN
        IF (g_debug_mode = 'Y') THEN
           Put_Debug_Msg (l_full_path,p_debug_msg => 'Processing First Period');
        END IF;
        x_prev_year_start_date := l_prd_dtls_rec.start_date(l_period_index) ;

        -- PO Period has to be closed for all periods in previous year except last period
        IF l_prd_dtls_rec.po_period_status(l_period_index) NOT IN ('C','P','N')
           AND p_process_phase = 'F'
        THEN
           l_err_code := 'IGC_PO_YEP_PO_PRD_STATUS';
           FND_MESSAGE.set_name('IGC',l_err_code);
           FND_MESSAGE.set_token('PREV_YEAR',p_year);
           l_msg_data := FND_MESSAGE.get;
           Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                                   p_exception_code     =>  l_err_code);
        END IF ; -- po_period_status

-- Validate Last Period
     ELSIF l_period_index = l_prd_dtls_rec.period_num.LAST    -- l_period_index = 1
     THEN
        IF (g_debug_mode = 'Y') THEN
           Put_Debug_Msg (l_full_path,p_debug_msg => 'Processing Last Period');
        END IF;
        x_prev_year_end_date    := l_prd_dtls_rec.end_date(l_period_index) ;
        x_prev_year_end_period  := l_prd_dtls_rec.period_name(l_period_index);
        x_prev_year_end_num     := l_prd_dtls_rec.period_num(l_period_index);
        x_prev_year_end_quarter := l_prd_dtls_rec.quarter_num(l_period_index);

        -- Last PO Period of previous year should be open
        IF l_prd_dtls_rec.po_period_status(l_period_index) <> 'O'
           AND p_process_phase = 'F'
        THEN
           l_err_code := 'IGC_PO_YEP_PO_LAST_PERIOD';
           FND_MESSAGE.set_name('IGC',l_err_code);
           FND_MESSAGE.set_token('PREV_YEAR',p_year);
           l_msg_data := FND_MESSAGE.get;
           Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                                   p_exception_code     =>  l_err_code);
        END IF ; -- po_period_status

        -- Last GL Period of previous year should be open
        IF l_prd_dtls_rec.gl_period_status(l_period_index) <> 'O'
           AND p_process_phase = 'F'
        THEN
           l_err_code := 'IGC_PO_YEP_GL_LAST_PERIOD';
           FND_MESSAGE.set_name('IGC',l_err_code );
           FND_MESSAGE.set_token('PREV_YEAR',p_year);
           l_msg_data := FND_MESSAGE.get;
           Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                                   p_exception_code     =>  l_err_code);
        END IF ; -- gl_period_status

     ELSE  -- l_period_index = 1

        IF (g_debug_mode = 'Y') THEN
           Put_Debug_Msg (l_full_path,p_debug_msg => 'Processing other periods');
        END IF;
        -- Perform validation for other periods

        -- PO Period has to be closed for all periods in previous year except last period
        IF l_prd_dtls_rec.po_period_status(l_period_index) NOT IN ('C','P','N')
           AND p_process_phase = 'F'
        THEN
           l_err_code := 'IGC_PO_YEP_PO_PRD_STATUS';
           FND_MESSAGE.set_name('IGC',l_err_code);
           FND_MESSAGE.set_token('PREV_YEAR',p_year);
           l_msg_data := FND_MESSAGE.get;
           Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                                   p_exception_code     =>  l_err_code);
        END IF ; -- po_poeriod_status

     END IF; -- l_period_index = 1

  END LOOP ;

-- Validate First Period Status of Current Year
  OPEN  c_get_prd_dtls(p_year + 1) ;
  FETCH c_get_prd_dtls BULK COLLECT INTO l_curr_period_rec.period_num,
                                         l_curr_period_rec.period_name,
                                         l_curr_period_rec.start_date,
                                         l_curr_period_rec.end_date,
                                         l_curr_period_rec.gl_period_status,
                                         l_curr_period_rec.po_period_status,
                                         l_curr_period_rec.quarter_num ;
  CLOSE c_get_prd_dtls ;

   IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg (l_full_path,p_debug_msg => 'Completed getting next years period details');
   END IF;
  x_curr_year_start_date    := l_curr_period_rec.start_date(1) ;
  x_curr_year_start_period  := l_curr_period_rec.period_name(1);
  x_curr_year_start_num     := l_curr_period_rec.period_num(1);
  x_curr_year_start_quarter := l_curr_period_rec.quarter_num(1);

-- First PO Period of current year should be Open or Future Entry
  IF l_curr_period_rec.po_period_status(1) NOT IN ('O', 'F')
     AND p_process_phase = 'F'
  THEN
     l_err_code := 'IGC_PO_YEP_PO_FIRST_PERIOD';
     FND_MESSAGE.set_name('IGC',l_err_code);
     FND_MESSAGE.set_token('CURR_YEAR',(p_year + 1));
     l_msg_data := FND_MESSAGE.get;
     Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                             p_exception_code     =>  l_err_code);

  END IF ; -- po_period_status

-- First GL Period of current year should be Open or Future Entry
  IF l_curr_period_rec.gl_period_status(1) NOT IN ('O', 'F')
     AND p_process_phase = 'F'
  THEN
     l_err_code := 'IGC_PO_YEP_GL_FIRST_PERIOD';
     FND_MESSAGE.set_name('IGC',l_err_code);
     FND_MESSAGE.set_token('CURR_YEAR',(p_year + 1));
     l_msg_data := FND_MESSAGE.get;
     Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                             p_exception_code     =>  l_err_code);

  END IF ; -- gl_period_status

-- If any validations failed and we are in Final Mode then terminate processing
  IF l_err_code IS NOT NULL AND p_process_phase = 'F'
  THEN

     RETURN FALSE;

  END IF; -- l_err_code IS NULL AND p_process_phase = 'F'

  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
     IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Validate_Period_Status');
     END IF;
     IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
     END IF;
     APP_EXCEPTION.Raise_Exception;

END Validate_Period_Status ;




--  Procedure Fetch_PO_And_Releases
--  ===============================
--
--  This procedure retrieves all PO and Release documents that satisfy the selection criteria
--  and places them into the global temporary table for processing.
--
--  IN Parameters
--  -------------
--  p_org_id                Org Id
--  p_prev_year_start_date  Start Date of year being closed
--  p_prev_year_end_date    End Date of year being closed
--
--  OUT Parameters
--  --------------
--
--
PROCEDURE Fetch_PO_And_Releases(p_org_id                IN NUMBER,
                                p_prev_year_start_date  IN DATE,
                                p_prev_year_end_date    IN DATE
                               ) IS
l_rec_count   NUMBER;

l_full_path      VARCHAR2(500) := g_path||'fetch_PO_and_releases';
BEGIN
  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg (l_full_path,p_debug_msg => '**** Fetch PO and Releases ****');
  END IF;

-- Fetch into global temporary table all documents that satisfy our initial selection criteria
  INSERT INTO igc_cbc_po_process_gt
              (document_type,
               po_header_id,
               po_release_id,
               line_id,
               line_location_id,
               distribution_id,
               accrue_on_receipt,
               quantity_ordered,
               quantity_billed,
               encumbered_flag,
               gl_encumbered_date,
               gl_encumbered_period_name
              )
              SELECT
              DECODE(pod.po_release_id, NULL, 'PO', 'REL') document_type,
              pod.po_header_id,
              pod.po_release_id,
              pod.po_line_id,
              pod.line_location_id,
              pod.po_distribution_id,
              pod.accrue_on_receipt_flag,
              pod.quantity_ordered,
              pod.quantity_billed,
              NVL(pod.encumbered_flag,'N'),
              pod.gl_encumbered_date,
              pod.gl_encumbered_period_name
  FROM        po_distributions_all pod,
              po_line_locations_all poll,
              po_lines_all pol
  WHERE       DECODE(poll.accrue_on_receipt_flag,
                     'N',
                     NVL(pod.quantity_ordered,0) - GREATEST(NVL(pod.quantity_billed,0),
                                                            NVL(pod.unencumbered_quantity,0)),
                     'Y',
                     NVL(pod.quantity_ordered,0) - GREATEST(NVL(pod.quantity_delivered,0),
                                                            NVL(pod.unencumbered_quantity,0)),
                     0)<> 0
              AND pol.po_header_id              =  poll.po_header_id
              AND poll.po_line_id               =  pol.po_line_id
              AND pod.line_location_id          =  poll.line_location_id
              AND pod.po_line_id                =  pol.po_line_id
              AND pod.po_header_id              =  pol.po_header_id
              AND pod.po_line_id                =  pol.po_line_id
              AND NVL(pol.closed_code,'X')      <> 'FINALLY CLOSED'
              AND NVL(pol.cancel_flag,'N')      =  'N'
              AND pol.org_id                    =  p_org_id
              AND NVL(poll.closed_code,'X')     <> 'FINALLY CLOSED'
              AND poll.shipment_type            IN ('STANDARD','PLANNED','BLANKET','SCHEDULED')
              AND NVL(poll.cancel_flag,'N')     =  'N'
              AND poll.org_id                   =  p_org_id
              AND pod.prevent_encumbrance_flag  =  'N'
              AND pod.org_id                    =  p_org_id
              AND pod.gl_encumbered_date        >= p_prev_year_start_date
              AND pod.gl_encumbered_date        <= p_prev_year_end_date
              ;

  IF (g_debug_mode = 'Y') THEN
    SELECT COUNT(1) INTO  l_rec_count FROM igc_cbc_po_process_gt;
    Put_Debug_Msg (l_full_path,p_debug_msg => 'Insert Record Count: '||l_rec_count);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Fetch_PO_And_Releases');
     END IF;
     IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
     END IF;
     APP_EXCEPTION.Raise_Exception;

END Fetch_PO_And_Releases;




--  Procedure Fetch_Requisitions
--  ============================
--
--  This procedure clears down the global temporary table and then retrieves all Requisition
--  documents that satisfy the selection criteria, placing them into the table for processing.
--
--  IN Parameters
--  -------------
--  p_org_id                Org Id
--  p_prev_year_start_date  Start Date of year being closed
--  p_prev_year_end_date    End Date of year being closed
--
--  OUT Parameters
--  --------------
--
--
--
--
PROCEDURE Fetch_Requisitions(p_org_id                IN NUMBER,
                             p_prev_year_start_date  IN DATE,
                             p_prev_year_end_date    IN DATE
                            ) IS

l_sql_string    VARCHAR2(100) := null ;
l_rec_count     NUMBER;

l_full_path      VARCHAR2(500) := g_path||'Fetch_Requisitions';
BEGIN
  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg (l_full_path,p_debug_msg => '**** Fetch Requisitions ****');
  END IF;

  DELETE FROM IGC_CBC_PO_PROCESS_GT ;
--  l_sql_string := 'TRUNCATE table IGC_CBC_PO_PROCESS_GT' ;
--  EXECUTE IMMEDIATE l_sql_string;

-- Fetch into global temporary table all documents that satisfy our initial selection criteria
   -- Added the OR clause for REQs having
   -- backing BPA. In this case the gl_encumbered_date and the
   -- cbc accounting date should be updated even though there
   -- is no actual encumbrance to be moved.
   -- 3173178, Bidisha S
   INSERT INTO igc_cbc_po_process_gt
               (
                document_type,
                req_header_id,
                line_id,
                distribution_id,
                encumbered_flag,
                gl_encumbered_date,
                gl_encumbered_period_name,
                prevent_encumbrance_flag,
                blanket_po_header_id
               )
              SELECT
                 'REQ',
                 prl.requisition_header_id,
                 prl.requisition_line_id,
                 prd.distribution_id,
                 NVL(prd.encumbered_flag, 'N'),
                 prd.gl_encumbered_date,
                 prd.gl_encumbered_period_name,
                 Nvl(prd.prevent_encumbrance_flag,'N'),
                 prl.blanket_po_header_id
              FROM
                 po_requisition_lines_all  prl,
                 po_req_distributions_all  prd
              WHERE
                 NVL(prl.closed_code, 'X') NOT IN ('CANCELLED','FINALLY CLOSED')
                 AND NVL(prl.cancel_flag, 'N') = 'N'
                 AND NVL(prl.line_location_id, -999) = -999
                 AND prl.source_type_code = 'VENDOR'
                 AND prl.org_id = p_org_id
                 AND (NVL(prd.prevent_encumbrance_flag, 'N') = 'N'
                 OR  (NVL(prd.prevent_encumbrance_flag, 'N') = 'Y'
                 AND  prl.blanket_po_header_id IS NOT NULL))
                 AND prd.requisition_line_id = prl.requisition_line_id
                 AND prd.org_id = p_org_id
                 AND prd.gl_encumbered_date BETWEEN p_prev_year_start_date AND p_prev_year_end_date ;

  IF (g_debug_mode = 'Y') THEN
    SELECT COUNT(1) INTO  l_rec_count FROM igc_cbc_po_process_gt;
    Put_Debug_Msg (l_full_path,p_debug_msg => 'Insert Record Count: '||l_rec_count);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Fetch_Requisitions');
     END IF;
     IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
     END IF;
     APP_EXCEPTION.Raise_Exception;

END Fetch_Requisitions ;


--  Procedure Fetch_BPAs
--  ============================
--
--  This procedure clears down the global temporary table and then retrieves all BPA
--  documents that satisfy the selection criteria, placing them into the table for processing.
--  Procedure has been added as part of changes being done for PRC.FP.J
--  under bug 3173178
--
--  IN Parameters
--  -------------
--  p_org_id                Org Id
--  p_prev_year_start_date  Start Date of year being closed
--  p_prev_year_end_date    End Date of year being closed
--
--  OUT Parameters
--  --------------
--
--
--
--
PROCEDURE Fetch_BPAs(p_org_id                IN NUMBER,
                     p_prev_year_start_date  IN DATE,
                     p_prev_year_end_date    IN DATE
                            ) IS

l_sql_string    VARCHAR2(100) := null ;
l_rec_count     NUMBER;

l_full_path      VARCHAR2(500) := g_path||'Fetch_BPAs';
BEGIN
  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg (l_full_path,p_debug_msg => '**** Fetch Blanket Agreements  ****');
  END IF;

  DELETE FROM IGC_CBC_PO_PROCESS_GT ;

  -- Fetch into global temporary table all documents that satisfy our initial selection criteria
  INSERT INTO igc_cbc_po_process_gt
               (
                document_type,
                po_header_id,
                line_id,
                distribution_id,
                quantity_ordered,
                quantity_billed,
          encumbered_flag,
          gl_encumbered_date,
          gl_encumbered_period_name
               )
              SELECT
                 'PA',
                 poh.po_header_id,
                 NULL,
                 pod.po_distribution_id,
                 pod.encumbered_amount+ pod.unencumbered_amount, --pod.amount_to_encumber,
                 pod.unencumbered_quantity,
                 Nvl(pod.encumbered_flag,'N'),
                 pod.gl_encumbered_date,
                 pod.gl_encumbered_period_name
              FROM po_distributions_all pod,
                   po_headers_all poh
              WHERE  (Nvl(pod.encumbered_amount+ pod.unencumbered_amount,0) > 0
              AND Nvl(pod.encumbered_amount+ pod.unencumbered_amount,0) <> Nvl(pod.unencumbered_amount,0)
              OR  Nvl(pod.encumbered_amount+ pod.unencumbered_amount,0) <> Nvl(poh.blanket_total_amount,0))
              AND Nvl(poh.encumbrance_required_flag,'N')  = 'Y'
              AND poh.type_lookup_code  = 'BLANKET'
              AND poh.closed_date IS NULL
              AND Nvl(poh.cancel_flag,'N') = 'N'
              AND pod.po_header_id  = poh.po_header_id
              AND pod.distribution_type   = 'AGREEMENT'
              AND Nvl(pod.prevent_encumbrance_flag,'N') = 'N'
              AND pod.org_id  = p_org_id
              AND poh.org_id  = p_org_id
              AND pod.gl_encumbered_date    >= p_prev_year_start_date
              AND pod.gl_encumbered_date    <= p_prev_year_end_date;

  IF (g_debug_mode = 'Y') THEN
    SELECT COUNT(1) INTO  l_rec_count FROM igc_cbc_po_process_gt;
    Put_Debug_Msg (l_full_path,p_debug_msg => 'Insert Record Count: '||l_rec_count);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Fetch_BPAs');
     END IF;
     IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
     END IF;
     APP_EXCEPTION.Raise_Exception;

END Fetch_BPAs ;


--  Validate Distributions
--  ======================
--
--  This procedure validates the distributions of the document being processed.
--
--  IN Parameters
--  -------------
--  p_batch_size         User entered value used to determine batch size of bulk fetches
--  p_document_type      Type of document: PO, REQ or REL
--  p_document_subtype   Subtype of document type: BLANKET, SCHEDULED, PLANNED, STANDARD, etc
--  p_document_id        Id of document
--
--  OUT Parameters
--  --------------
--
--
FUNCTION  Validate_Distributions(p_batch_size       IN NUMBER,
                                 p_document_type    IN VARCHAR2,
                                 p_document_subtype IN VARCHAR2,
                                 p_document_id      IN NUMBER
                                ) RETURN VARCHAR2 AS

TYPE valid_dist_rec_type IS RECORD
(line_id           igc_tbl_number,
 line_location_id  igc_tbl_number,
 distribution_id   igc_tbl_number,
 invoice_number    igc_tbl_varchar100,
 result_error_code igc_tbl_varchar40);

l_valid_dist_rec   valid_dist_rec_type ;

TYPE c_valid_dist_type IS REF CURSOR ;

c_valid_dist c_valid_dist_type;

l_msg_data       VARCHAR2(2000) := null ;
l_return_status  VARCHAR2(1):=  FND_API.G_RET_STS_SUCCESS;

l_full_path      VARCHAR2(500) := g_path||'Validate_Distributions';
BEGIN

  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg (l_full_path,p_debug_msg => '**** Validate Distributions ****');
  END IF;

-- Set cursor to check distributions for Standard PO's
  IF p_document_type = 'PO' and p_document_subtype = 'STANDARD'
  THEN
     OPEN c_valid_dist FOR
     SELECT DISTINCT tmp.line_id,
                     tmp.line_location_id,
                     tmp.distribution_id,
                     ai.invoice_num,
                     DECODE(NVL(aid.match_status_flag, 'N'), 'N', 'IGC_PO_YEP_INV_NAPPR',
                                                             'T', 'IGC_PO_YEP_INV_NAPPR',
                         DECODE(NVL(ai.payment_status_flag, 'N'), 'N', 'IGC_PO_YEP_INV_NPAID',
                           DECODE(NVL(aip.posted_flag, 'N'), 'N', 'IGC_PO_YEP_INV_PAY_NPOST',
                              DECODE(SIGN(tmp.quantity_ordered - tmp.quantity_billed), -1,
                                 'IGC_PO_YEP_PO_OVERBILLED'))))  result_error_code
     FROM  ap_invoices ai,
           ap_invoice_payments aip,
           ap_invoice_distributions aid,
           igc_cbc_po_process_gt tmp
     WHERE ai.invoice_id = aid.invoice_id
     AND   aip.invoice_id(+) = ai.invoice_id
     AND   aid.po_distribution_id = tmp.distribution_id
     AND   tmp.accrue_on_receipt  = 'N'
     AND   tmp.encumbered_flag = 'Y'
     AND   tmp.po_header_id = p_document_id
     AND   ai.cancelled_date IS NULL
     ORDER BY result_error_code ASC;

-- Set cursor to check distributions for Scheduled and Blanket Releases
  ELSIF p_document_type = 'REL'
     AND p_document_subtype IN ('SCHEDULED', 'BLANKET')
  THEN
     OPEN c_valid_dist FOR
     SELECT DISTINCT tmp.line_id,
                     tmp.line_location_id,
                     tmp.distribution_id,
                     ai.invoice_num,
                     DECODE(NVL(aid.match_status_flag, 'N'), 'N', 'IGC_PO_YEP_INV_NAPPR',
                                                             'T', 'IGC_PO_YEP_INV_NAPPR',
                        DECODE(NVL(ai.payment_status_flag, 'N'), 'N', 'IGC_PO_YEP_INV_NPAID',
                           DECODE(NVL(aip.posted_flag, 'N'), 'N', 'IGC_PO_YEP_INV_PAY_NPOST',
                              DECODE(SIGN(tmp.quantity_ordered - tmp.quantity_billed), -1,
                                 'IGC_PO_YEP_REL_OVERBILLED'))))  result_error_code
     FROM  ap_invoices ai,
           ap_invoice_payments aip,
           ap_invoice_distributions aid,
           igc_cbc_po_process_gt tmp
     WHERE ai.invoice_id = aid.invoice_id
     AND   aip.invoice_id(+) = ai.invoice_id
     AND   aid.po_distribution_id = tmp.distribution_id
     AND   tmp.accrue_on_receipt  = 'N'
     AND   tmp.encumbered_flag = 'Y'
     AND   tmp.encumbered_flag = 'Y'
     AND   tmp.po_release_id = p_document_id
     AND   ai.cancelled_date IS NULL
     ORDER BY result_error_code ASC;

-- If not a Standard PO, Blanket Release or Scheduled Release, then no distributions so return success
  ELSE
     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => 'No distributions for this document type');
     END IF;
     RETURN  FND_API.G_RET_STS_SUCCESS;
  END IF; -- p_document_type = 'PO' and p_document_subtype = 'STANDARD'

-- fetch distributions in batches determined by user parameter
  LOOP
     FETCH c_valid_dist BULK COLLECT INTO l_valid_dist_rec.line_id,
                                          l_valid_dist_rec.line_location_id,
                                          l_valid_dist_rec.distribution_id,
                                          l_valid_dist_rec.invoice_number,
                                          l_valid_dist_rec.result_error_code
     LIMIT p_batch_size;
-- replaced line below, as this does not work !
--     IF c_valid_dist%NOTFOUND
     IF l_valid_dist_rec.distribution_id.FIRST IS NULL
     THEN
        IF (g_debug_mode = 'Y') THEN
           Put_Debug_Msg (l_full_path,p_debug_msg => 'No more distributions retrieved');
        END IF;
        EXIT ;
     END IF;
     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => 'Fetched latest batch');
     END IF;

--  Loop through retrieved distribution details
     FOR l_index IN l_valid_dist_rec.distribution_id.FIRST .. l_valid_dist_rec.distribution_id.LAST
     LOOP
        IF (g_debug_mode = 'Y') THEN
           Put_Debug_Msg (l_full_path,p_debug_msg => 'distribution id:'||l_valid_dist_rec.distribution_id(l_index));
        END IF;
        IF l_valid_dist_rec.result_error_code(l_index) IS NOT NULL
        THEN
           -- report any errors and set return status to error
           FND_MESSAGE.set_name('IGC',l_valid_dist_rec.result_error_code(l_index));
           IF l_valid_dist_rec.result_error_code(l_index) LIKE 'IGC_PO_YEP_INV_%'
           THEN
              FND_MESSAGE.set_token('INVOICE_NUM',l_valid_dist_rec.invoice_number(l_index));
           END IF;
           l_msg_data := FND_MESSAGE.get;
           Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                                   p_exception_code     =>  l_valid_dist_rec.result_error_code(l_index),
                                   p_document_type      =>  p_document_type,
                                   p_document_id        =>  p_document_id,
                                   p_line_id            =>  l_valid_dist_rec.line_id(l_index),
                                   p_line_location_id   =>  l_valid_dist_rec.line_location_id(l_index),
                                   p_distribution_id    =>  l_valid_dist_rec.distribution_id(l_index)
                                   );
           l_return_status := FND_API.G_RET_STS_ERROR;
        ELSE
           EXIT;
        END IF; -- result_error_code(l_index) IS NOT NULL
     END LOOP;

     l_valid_dist_rec.distribution_id.DELETE;

  END LOOP;

  CLOSE c_valid_dist;

  RETURN l_return_status;

EXCEPTION
  WHEN OTHERS THEN
     IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Validate_Distributions');
     END IF;
     IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
     END IF;
     APP_EXCEPTION.Raise_Exception;


END Validate_Distributions ;


--  Procedure Create_Journal_Adjustments
--  ====================================
--
--  This Procedure creates adjustments journals to back out the carried forward encumbrances
--  of backing documents that have already been created by the call to the PO funds checker.
--
--  IN Parameters
--  -------------
--  p_sob_id                   Set of Books Id
--  p_year                     Year being processed
--  p_document_type            Type of document
--  p_document_subtype         Subtype of document
--  p_distribution_id_tbl      Table of distribution id's being processed for this document
--  p_prev_year_end_period     Name of final period of year being rolled forward
--  p_prev_year_end_num        Number of final period of year being rolled forward
--  p_prev_year_end_quarter    Number of final quarter of year being rolled forward
--  p_curr_year_start_period   Name of final period of new year
--  p_curr_year_end_num        Number of final period of new year
--  p_prev_year_end_quarter    Number of final quarter of new year
--
--  OUT Parameters
--  --------------
--  x_return_code            Indicates the return status of the procedure:
--                              0 - Need to terminate processing successfully
--                              1 - Need to terminate processing with warning
--                              2 - Need to terminate processing with error
--                            -99 - Successful, continue processing
--
-- bug 2804025 ssmales 19-Feb-2003 new procedure create_journal_adjustments
--
PROCEDURE  Create_Journal_Adjustments(p_sobid                   IN NUMBER,
                                      p_year                    IN NUMBER,
                                      p_document_type           IN VARCHAR2,
                                      p_document_subtype        IN VARCHAR2,
                                      p_distribution_id_tbl     IN igc_tbl_number,
                                      p_prev_year_end_period    IN VARCHAR2,
                                      p_prev_year_end_num       IN NUMBER,
                                      p_prev_year_end_quarter   IN NUMBER,
                                      p_curr_year_start_period  IN VARCHAR2,
                                      p_curr_year_start_num     IN NUMBER,
                                      p_curr_year_start_quarter IN NUMBER,
                                      x_return_code             OUT NOCOPY NUMBER
                                      ) AS

l_packet_id    NUMBER;
l_result_code  BOOLEAN;
l_return_code  VARCHAR2(1);

l_full_path      VARCHAR2(500) := g_path||'create_journal_adjustments';
BEGIN

  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg (l_full_path,p_debug_msg => '**** Create Journal Adjustments ****');
  END IF;

  --Process Standard and Planned PO's with Backing Requisitions
  IF p_document_type = 'PO' AND p_document_subtype IN ('STANDARD','PLANNED')
  THEN
     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => 'Starting Req Adjustments for POs');
     END IF;
     -- cancel the requisition encumbrance in the previous year
     SELECT gl_bc_packets_s.nextval
     INTO l_packet_id
     FROM DUAL;

     FORALL l_index IN p_distribution_id_tbl.FIRST .. p_distribution_id_tbl.LAST
     INSERT INTO gl_bc_packets
        (
         packet_id,
         Ledger_id,
         je_source_name,
         je_category_name,
         code_combination_id,
         actual_flag,
         period_name,
         period_year,
         period_num,
         quarter_num,
         currency_code,
         status_code,
         last_update_date,
         last_updated_by,
         budget_version_id,
         encumbrance_type_id,
         entered_dr,
         entered_cr,
         accounted_dr,
         accounted_cr,
         ussgl_transaction_code,
         reference1,
         reference2,
         reference3,
         reference4,
         reference5,
         je_line_description
         )
        SELECT
         l_packet_id,
         glsob.set_of_books_id,
         'Purchasing',
         'Requisitions',
         prd.budget_account_id,
         'E',
         p_prev_year_end_period,
         p_year,
         p_prev_year_end_num,
         p_prev_year_end_quarter,
         glsob.currency_code,
         'P',
         sysdate,
         g_user_id,
         NULL,
         fsp.req_encumbrance_type_id,
         -1 * (DECODE(base_cur.minimum_accountable_unit,
                       NULL,
                       ROUND((prl.unit_price + po_tax_sv.get_tax('REQ',prd.distribution_id)
                              / prd.req_line_quantity)
                              * (GREATEST
                                   (
                                    DECODE
                                     (NVL(poll.accrue_on_receipt_flag,'N'),
                                      'N',
                                      (prd.req_line_quantity
                                       - po_uom_s.po_uom_convert_p(pol.unit_meas_lookup_code,
                                                                   prl.unit_meas_lookup_code,
                                                                   prl.item_id)
                                       * GREATEST(NVL(pod.quantity_billed,0),
                                                  NVL(pod.unencumbered_quantity,0)
                                                  )
                                       ),
                                      'Y',
                                      (prd.req_line_quantity
                                       - po_uom_s.po_uom_convert_p(pol.unit_meas_lookup_code,
                                                                   prl.unit_meas_lookup_code,
                                                                   prl.item_id)
                                       * GREATEST(NVL(pod.quantity_delivered,0),
                    NVL(pod.unencumbered_quantity,0))
                                       )
                                      )  -- DECODE
                                   ,0) -- GREATEST
                                 ),
                             base_cur.precision),  -- ROUND

                       ROUND(((prl.unit_price + po_tax_sv.get_tax('REQ',prd.distribution_id)
                               / prd.req_line_quantity)
                               * ((GREATEST
                                    (
                                     DECODE
                                      (NVL(poll.accrue_on_receipt_flag,'N'),
                                       'N',
                                       (prd.req_line_quantity
                                        - po_uom_s.po_uom_convert_p(pol.unit_meas_lookup_code,
                                                                    prl.unit_meas_lookup_code,
                                                                    prl.item_id)
                                        * GREATEST(NVL(pod.quantity_billed,0),
                                                   NVL(pod.unencumbered_quantity,0)
                                                   )
                                        ),
                                       'Y',
                                       (prd.req_line_quantity
                                        - po_uom_s.po_uom_convert_p(pol.unit_meas_lookup_code,
                                                                    prl.unit_meas_lookup_code,
                                                                    prl.item_id)
                                        * GREATEST (NVL(pod.quantity_delivered,0),
                                                   NVL(pod.unencumbered_quantity,0))

                                        )
                                       )  -- DECODE
                                     ,0) -- GREATEST
                                    ) / base_cur.minimum_accountable_unit)
                                 * base_cur.minimum_accountable_unit),
                             base_cur.precision))) Entered_Dr,
         0 Entered_Cr,
         -1 * (DECODE(base_cur.minimum_accountable_unit,
                       NULL,
                       ROUND((prl.unit_price + po_tax_sv.get_tax('REQ',prd.distribution_id)
                              / prd.req_line_quantity)
                              * (GREATEST
                                   (
                                    DECODE
                                     (NVL(poll.accrue_on_receipt_flag,'N'),
                                      'N',
                                      (prd.req_line_quantity
                                       - po_uom_s.po_uom_convert_p(pol.unit_meas_lookup_code,
                                                                   prl.unit_meas_lookup_code,
                                                                   prl.item_id)
                                       * GREATEST(NVL(pod.quantity_billed,0),
                                                  NVL(pod.unencumbered_quantity,0)
                                                  )
                                       ),
                                      'Y',
                                      (prd.req_line_quantity
                                       - po_uom_s.po_uom_convert_p(pol.unit_meas_lookup_code,
                                                                   prl.unit_meas_lookup_code,
                                                                   prl.item_id)
                                       * GREATEST(NVL(pod.quantity_delivered,0),
                                                  NVL(pod.unencumbered_quantity,0))
                                       )
                                      )  -- DECODE
                                   ,0) -- GREATEST
                                 ),
                             base_cur.precision),  -- ROUND

                       ROUND(((prl.unit_price + po_tax_sv.get_tax('REQ',prd.distribution_id)
                               / prd.req_line_quantity)
                               * ((GREATEST
                                    (
                                     DECODE
                                      (NVL(poll.accrue_on_receipt_flag,'N'),
                                       'N',
                                       (prd.req_line_quantity
                                        - po_uom_s.po_uom_convert_p(pol.unit_meas_lookup_code,
                                                                    prl.unit_meas_lookup_code,
                                                                    prl.item_id)
                                        * GREATEST(NVL(pod.quantity_billed,0),
                                                   NVL(pod.unencumbered_quantity,0)
                                                   )
                                        ),
                                       'Y',
                                       (prd.req_line_quantity
                                        - po_uom_s.po_uom_convert_p(pol.unit_meas_lookup_code,
                                                                    prl.unit_meas_lookup_code,
                                                                    prl.item_id)
                                        * GREATEST(NVL(pod.quantity_delivered,0),
                                                   NVL(pod.unencumbered_quantity,0))

                                        )
                                       )  -- DECODE
                                     ,0) -- GREATEST
                                    ) / base_cur.minimum_accountable_unit)
                                 * base_cur.minimum_accountable_unit),
                             base_cur.precision))) Accounted_Dr,
         0 Accounted_Cr,
         prd.ussgl_transaction_code,
         'REQ',
         prl.requisition_header_id,
         prd.distribution_id,
         prh.segment1,
         prl.reference_num,
         SUBSTR(prl.item_description,1,25) || '-Year End Process, Adjust Requisition Encumbrance entry'
        FROM
        fnd_currencies                base_cur,
        gl_sets_of_books              glsob,
        financials_system_parameters  fsp,
        po_requisition_lines          prl,
        po_req_distributions          prd,
        po_requisition_headers        prh,
        po_line_locations             poll,
        po_distributions              pod,
        po_lines                      pol
        WHERE
        NVL(prl.closed_code,'OPEN') NOT IN ('CANCELLED','FINALLY CLOSED')
        AND NVL(prl.cancel_flag,'N')              = 'N'
        AND NVL(prd.prevent_encumbrance_flag,'N') = 'N'
        AND prd.requisition_line_id               = prl.requisition_line_id
        AND prl.line_location_id                  = poll.line_location_id
        AND pod.line_location_id                  = poll.line_location_id
        AND pod.po_distribution_id                = p_distribution_id_tbl(l_index)
        AND poll.shipment_type IN ('STANDARD','PLANNED')
        AND NVL(poll.cancel_flag,'N')             = 'N'
        AND NVL(poll.closed_code,'OPEN')          <> 'FINALLY CLOSED'
        AND base_cur.currency_code                = glsob.currency_code
        AND fsp.set_of_books_id                   = glsob.set_of_books_id
        AND pol.po_line_id                        = poll.po_line_id
        AND prh.requisition_header_id             = prl.requisition_header_id ;

--     COMMIT;

     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => 'Completed insert to gl_bc_packets');
     END IF;
     l_result_code := gl_funds_checker_pkg.glxfck(
                                                  p_sobid              => p_sobid,
                                                  p_packetid           => l_packet_id,
                                                  p_mode               => 'F',
                                                  p_partial_resv_flag  => 'N',
                                                  p_override           => 'N',
                                                  p_conc_flag          => 'Y',
                                                  p_user_id            => g_user_id,
                                                  p_user_resp_id       => g_resp_id,
                                                  p_return_code        => l_return_code
                                                  );
--     COMMIT;

     IF NOT(l_result_code) OR (l_return_code NOT IN ('A','S'))
     THEN
       IF (g_debug_mode = 'Y') THEN
          Put_Debug_Msg (l_full_path,p_debug_msg => 'gl funds check failure:'||gl_funds_checker_pkg.get_debug);
       END IF;
       x_return_code := 2 ;
       RETURN;
     END IF;
     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => 'Completed prev year adjustment');
     END IF;

     -- Now repeat the above to cancel the requisition encumbrances in the current year
     SELECT gl_bc_packets_s.nextval
     INTO l_packet_id
     FROM DUAL;

     FORALL l_index IN p_distribution_id_tbl.FIRST .. p_distribution_id_tbl.LAST
     INSERT INTO gl_bc_packets
        (
         packet_id,
         Ledger_id,
         je_source_name,
         je_category_name,
         code_combination_id,
         actual_flag,
         period_name,
         period_year,
         period_num,
         quarter_num,
         currency_code,
         status_code,
         last_update_date,
         last_updated_by,
         budget_version_id,
         encumbrance_type_id,
         entered_dr,
         entered_cr,
         accounted_dr,
         accounted_cr,
         ussgl_transaction_code,
         reference1,
         reference2,
         reference3,
         reference4,
         reference5,
         je_line_description
         )
        SELECT
         l_packet_id,
         glsob.set_of_books_id,
         'Purchasing',
         'Requisitions',
         prd.budget_account_id,
         'E',
         p_curr_year_start_period,
         p_year + 1,
         p_curr_year_start_num,
         p_curr_year_start_quarter,
         glsob.currency_code,
         'P',
         sysdate,
         g_user_id,
         NULL,
         fsp.req_encumbrance_type_id,
         0 Entered_Dr,
         -1 * (DECODE(base_cur.minimum_accountable_unit,
                       NULL,
                       ROUND((prl.unit_price + po_tax_sv.get_tax('REQ',prd.distribution_id)
                              / prd.req_line_quantity)
                              * (GREATEST
                                   (
                                    DECODE
                                     (NVL(poll.accrue_on_receipt_flag,'N'),
                                      'N',
                                      (prd.req_line_quantity
                                       - po_uom_s.po_uom_convert_p(pol.unit_meas_lookup_code,
                                                                   prl.unit_meas_lookup_code,
                                                                   prl.item_id)
                                       * GREATEST(NVL(pod.quantity_billed,0),
                                                  NVL(pod.unencumbered_quantity,0)
                                                  )
                                       ),
                                      'Y',
                                      (prd.req_line_quantity
                                       - po_uom_s.po_uom_convert_p(pol.unit_meas_lookup_code,
                                                                   prl.unit_meas_lookup_code,
                                                                   prl.item_id)
                                       * GREATEST(NVL(pod.quantity_delivered,0),
                                                  NVL(pod.unencumbered_quantity,0))
                                       )
                                      )  -- DECODE
                                   ,0) -- GREATEST
                                 ),
                             base_cur.precision),  -- ROUND

                       ROUND(((prl.unit_price + po_tax_sv.get_tax('REQ',prd.distribution_id)
                               / prd.req_line_quantity)
                               * ((GREATEST
                                    (
                                     DECODE
                                      (NVL(poll.accrue_on_receipt_flag,'N'),
                                       'N',
                                       (prd.req_line_quantity
                                        - po_uom_s.po_uom_convert_p(pol.unit_meas_lookup_code,
                                                                    prl.unit_meas_lookup_code,
                                                                    prl.item_id)
                                        * GREATEST(NVL(pod.quantity_billed,0),
                                                   NVL(pod.unencumbered_quantity,0)
                                                   )
                                        ),
                                       'Y',
                                       (prd.req_line_quantity
                                        - po_uom_s.po_uom_convert_p(pol.unit_meas_lookup_code,
                                                                    prl.unit_meas_lookup_code,
                                                                    prl.item_id)
                                        * GREATEST(NVL(pod.quantity_delivered,0),
                                                  NVL(pod.unencumbered_quantity,0))
                                        )
                                       )  -- DECODE
                                     ,0) -- GREATEST
                                    ) / base_cur.minimum_accountable_unit)
                                 * base_cur.minimum_accountable_unit),
                             base_cur.precision))) Entered_Cr,
         0 Accounted_Dr,
         -1 * (DECODE(base_cur.minimum_accountable_unit,
                       NULL,
                       ROUND((prl.unit_price + po_tax_sv.get_tax('REQ',prd.distribution_id)
                              / prd.req_line_quantity)
                              * (GREATEST
                                   (
                                    DECODE
                                     (NVL(poll.accrue_on_receipt_flag,'N'),
                                      'N',
                                      (prd.req_line_quantity
                                       - po_uom_s.po_uom_convert_p(pol.unit_meas_lookup_code,
                                                                   prl.unit_meas_lookup_code,
                                                                   prl.item_id)
                                       * GREATEST(NVL(pod.quantity_billed,0),
                                                  NVL(pod.unencumbered_quantity,0)
                                                  )
                                       ),
                                      'Y',
                                      (prd.req_line_quantity
                                       - po_uom_s.po_uom_convert_p(pol.unit_meas_lookup_code,
                                                                   prl.unit_meas_lookup_code,
                                                                   prl.item_id)
                                       * GREATEST(NVL(pod.quantity_delivered,0),
                                                  NVL(pod.unencumbered_quantity,0))
                                       )
                                      )  -- DECODE
                                   ,0) -- GREATEST
                                 ),
                             base_cur.precision),  -- ROUND

                       ROUND(((prl.unit_price + po_tax_sv.get_tax('REQ',prd.distribution_id)
                               / prd.req_line_quantity)
                               * ((GREATEST
                                    (
                                     DECODE
                                      (NVL(poll.accrue_on_receipt_flag,'N'),
                                       'N',
                                       (prd.req_line_quantity
                                        - po_uom_s.po_uom_convert_p(pol.unit_meas_lookup_code,
                                                                    prl.unit_meas_lookup_code,
                                                                    prl.item_id)
                                        * GREATEST(NVL(pod.quantity_billed,0),
                                                   NVL(pod.unencumbered_quantity,0)
                                                   )
                                        ),
                                       'Y',
                                       (prd.req_line_quantity
                                        - po_uom_s.po_uom_convert_p(pol.unit_meas_lookup_code,
                                                                    prl.unit_meas_lookup_code,
                                                                    prl.item_id)
                                        * GREATEST(NVL(pod.quantity_delivered,0),
                                                  NVL(pod.unencumbered_quantity,0))
                                        )
                                       )  -- DECODE
                                     ,0) -- GREATEST
                                    ) / base_cur.minimum_accountable_unit)
                                 * base_cur.minimum_accountable_unit),
                             base_cur.precision))) Accounted_Cr,
         prd.ussgl_transaction_code,
         'REQ',
         prl.requisition_header_id,
         prd.distribution_id,
         prh.segment1,
         prl.reference_num,
         SUBSTR(prl.item_description,1,25) || '-Year End Process, Adjust Requisition Encumbrance entry'
        FROM
        fnd_currencies                base_cur,
        gl_sets_of_books              glsob,
        financials_system_parameters  fsp,
        po_requisition_lines          prl,
        po_req_distributions          prd,
        po_requisition_headers        prh,
        po_line_locations             poll,
        po_distributions              pod,
        po_lines                      pol
        WHERE
        NVL(prl.closed_code,'OPEN') NOT IN ('CANCELLED','FINALLY CLOSED')
        AND NVL(prl.cancel_flag,'N') = 'N'
        AND NVL(prd.prevent_encumbrance_flag,'N') = 'N'
        AND prd.requisition_line_id  = prl.requisition_line_id
        AND prl.line_location_id = poll.line_location_id
        AND pod.line_location_id = poll.line_location_id
        AND pod.po_distribution_id  = p_distribution_id_tbl(l_index)
        AND poll.shipment_type IN ('STANDARD','PLANNED')
        AND NVL(poll.cancel_flag,'N') = 'N'
        AND NVL(poll.closed_code,'OPEN') <> 'FINALLY CLOSED'
        AND base_cur.currency_code = glsob.currency_code
        AND fsp.set_of_books_id = glsob.set_of_books_id
        AND pol.po_line_id = poll.po_line_id
        AND prh.requisition_header_id = prl.requisition_header_id
        ;

--     COMMIT;

     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => 'Completed insert to gl_bc_packets');
     END IF;
     l_result_code := gl_funds_checker_pkg.glxfck(
                                                  p_sobid              => p_sobid,
                                                  p_packetid           => l_packet_id,
                                                  p_mode               => 'F',
                                                  p_partial_resv_flag  => 'N',
                                                  p_override           => 'N',
                                                  p_conc_flag          => 'Y',
                                                  p_user_id            => g_user_id,
                                                  p_user_resp_id       => g_resp_id,
                                                  p_return_code        => l_return_code
                                                  );
--     COMMIT;

     IF NOT(l_result_code) OR (l_return_code NOT IN ('A','S'))
     THEN
       IF (g_debug_mode = 'Y') THEN
          Put_Debug_Msg (l_full_path,p_debug_msg => 'gl funds check failure');
       END IF;
       x_return_code := 2 ;
       RETURN;
     END IF ;

  --Process Blanket Releases with Backing Requisitions
  ELSIF p_document_type = 'REL' AND p_document_subtype IN ('BLANKET')
  THEN
     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => 'Starting Req Adjustments for Releases');
     END IF;
     -- cancel the requisition encumbrance in the previous year
     SELECT gl_bc_packets_s.nextval
     INTO l_packet_id
     FROM DUAL;

     FORALL l_index IN p_distribution_id_tbl.FIRST .. p_distribution_id_tbl.LAST
     INSERT INTO gl_bc_packets
        (
         packet_id,
         Ledger_id,
         je_source_name,
         je_category_name,
         code_combination_id,
         actual_flag,
         period_name,
         period_year,
         period_num,
         quarter_num,
         currency_code,
         status_code,
         last_update_date,
         last_updated_by,
         budget_version_id,
         encumbrance_type_id,
         entered_dr,
         entered_cr,
         accounted_dr,
         accounted_cr,
         ussgl_transaction_code,
         reference1,
         reference2,
         reference3,
         reference4,
         reference5,
         je_line_description
         )
        SELECT
         l_packet_id,
         glsob.set_of_books_id,
         'Purchasing',
         'Requisitions',
         prd.budget_account_id,
         'E',
         p_prev_year_end_period,
         p_year,
         p_prev_year_end_num,
         p_prev_year_end_quarter,
         glsob.currency_code,
         'P',
         sysdate,
         g_user_id,
         NULL,
         fsp.req_encumbrance_type_id,
         -1 * (DECODE(base_cur.minimum_accountable_unit,
                       NULL,
                       ROUND((prl.unit_price + po_tax_sv.get_tax('REQ',prd.distribution_id)
                              / prd.req_line_quantity)
                              * (GREATEST
                                   (
                                    DECODE
                                     (NVL(poll.accrue_on_receipt_flag,'N'),
                                      'N',
                                      (prd.req_line_quantity
                                       - po_uom_s.po_uom_convert_p(pol.unit_meas_lookup_code,
                                                                   prl.unit_meas_lookup_code,
                                                                   prl.item_id)
                                       * GREATEST(NVL(pod.quantity_billed,0),
                                                  NVL(pod.quantity_delivered,0)
                                                  )
                                       ),
                                      'Y',
                                      (prd.req_line_quantity
                                       - po_uom_s.po_uom_convert_p(pol.unit_meas_lookup_code,
                                                                   prl.unit_meas_lookup_code,
                                                                   prl.item_id)
                                       * NVL(pod.quantity_delivered,0)
                                       )
                                      )  -- DECODE
                                   ,0) -- GREATEST
                                 ),
                             base_cur.precision),  -- ROUND

                       ROUND(((prl.unit_price + po_tax_sv.get_tax('REQ',prd.distribution_id)
                               / prd.req_line_quantity)
                               * ((GREATEST
                                    (
                                     DECODE
                                      (NVL(poll.accrue_on_receipt_flag,'N'),
                                       'N',
                                       (prd.req_line_quantity
                                        - po_uom_s.po_uom_convert_p(pol.unit_meas_lookup_code,
                                                                    prl.unit_meas_lookup_code,
                                                                    prl.item_id)
                                        * GREATEST(NVL(pod.quantity_billed,0),
                                                   NVL(pod.quantity_delivered,0)
                                                   )
                                        ),
                                       'Y',
                                       (prd.req_line_quantity
                                        - po_uom_s.po_uom_convert_p(pol.unit_meas_lookup_code,
                                                                    prl.unit_meas_lookup_code,
                                                                    prl.item_id)
                                        * NVL(pod.quantity_delivered,0)
                                        )
                                       )  -- DECODE
                                     ,0) -- GREATEST
                                    ) / base_cur.minimum_accountable_unit)
                                 * base_cur.minimum_accountable_unit),
                             base_cur.precision))) Entered_Dr,
         0 Entered_Cr,
         -1 * (DECODE(base_cur.minimum_accountable_unit,
                       NULL,
                       ROUND((prl.unit_price + po_tax_sv.get_tax('REQ',prd.distribution_id)
                              / prd.req_line_quantity)
                              * (GREATEST
                                   (
                                    DECODE
                                     (NVL(poll.accrue_on_receipt_flag,'N'),
                                      'N',
                                      (prd.req_line_quantity
                                       - po_uom_s.po_uom_convert_p(pol.unit_meas_lookup_code,
                                                                   prl.unit_meas_lookup_code,
                                                                   prl.item_id)
                                       * GREATEST(NVL(pod.quantity_billed,0),
                                                  NVL(pod.quantity_delivered,0)
                                                  )
                                       ),
                                      'Y',
                                      (prd.req_line_quantity
                                       - po_uom_s.po_uom_convert_p(pol.unit_meas_lookup_code,
                                                                   prl.unit_meas_lookup_code,
                                                                   prl.item_id)
                                       * NVL(pod.quantity_delivered,0)
                                       )
                                      )  -- DECODE
                                   ,0) -- GREATEST
                                 ),
                             base_cur.precision),  -- ROUND

                       ROUND(((prl.unit_price + po_tax_sv.get_tax('REQ',prd.distribution_id)
                               / prd.req_line_quantity)
                               * ((GREATEST
                                    (
                                     DECODE
                                      (NVL(poll.accrue_on_receipt_flag,'N'),
                                       'N',
                                       (prd.req_line_quantity
                                        - po_uom_s.po_uom_convert_p(pol.unit_meas_lookup_code,
                                                                    prl.unit_meas_lookup_code,
                                                                    prl.item_id)
                                        * GREATEST(NVL(pod.quantity_billed,0),
                                                   NVL(pod.quantity_delivered,0)
                                                   )
                                        ),
                                       'Y',
                                       (prd.req_line_quantity
                                        - po_uom_s.po_uom_convert_p(pol.unit_meas_lookup_code,
                                                                    prl.unit_meas_lookup_code,
                                                                    prl.item_id)
                                        * NVL(pod.quantity_delivered,0)
                                        )
                                       )  -- DECODE
                                     ,0) -- GREATEST
                                    ) / base_cur.minimum_accountable_unit)
                                 * base_cur.minimum_accountable_unit),
                             base_cur.precision))) Accounted_Dr,
         0 Accounted_Cr,
         prd.ussgl_transaction_code,
         'REQ',
         prl.requisition_header_id,
         prd.distribution_id,
         prh.segment1,
         prl.reference_num,
         SUBSTR(prl.item_description,1,25) || '-Year End Process, Adjust Requisition Encumbrance entry'
        FROM
        fnd_currencies                base_cur,
        gl_sets_of_books              glsob,
        financials_system_parameters  fsp,
        po_requisition_lines          prl,
        po_req_distributions          prd,
        po_requisition_headers        prh,
        po_line_locations             poll,
        po_distributions              pod,
        po_lines                      pol
        WHERE
        NVL(prl.closed_code,'OPEN') NOT IN ('CANCELLED','FINALLY CLOSED')
        AND NVL(prl.cancel_flag,'N') = 'N'
        AND NVL(prd.prevent_encumbrance_flag,'N') = 'N'
        AND prd.requisition_line_id  = prl.requisition_line_id
        AND prl.line_location_id = poll.line_location_id
        AND pod.line_location_id = poll.line_location_id
        AND pod.po_distribution_id  = p_distribution_id_tbl(l_index)
        AND NVL(poll.cancel_flag,'N') = 'N'
        AND NVL(poll.closed_code,'OPEN') <> 'FINALLY CLOSED'
        AND base_cur.currency_code = glsob.currency_code
        AND fsp.set_of_books_id = glsob.set_of_books_id
        AND pol.po_line_id = poll.po_line_id
        AND poll.shipment_type IN ('BLANKET')
        AND prh.requisition_header_id = prl.requisition_header_id
        ;

     l_result_code := gl_funds_checker_pkg.glxfck(
                                                  p_sobid              => p_sobid,
                                                  p_packetid           => l_packet_id,
                                                  p_mode               => 'F',
                                                  p_partial_resv_flag  => 'N',
                                                  p_override           => 'N',
                                                  p_conc_flag          => 'Y',
                                                  p_user_id            => g_user_id,
                                                  p_user_resp_id       => g_resp_id,
                                                  p_return_code        => l_return_code
                                                  );
     IF NOT(l_result_code) OR (l_return_code NOT IN ('A','S'))
     THEN
       x_return_code := 2 ;
       RETURN;
     END IF;
     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => 'Completed prev year adjustment');
     END IF;

     -- Now repeat the above to cancel the requisition encumbrances in the current year
     SELECT gl_bc_packets_s.nextval
     INTO l_packet_id
     FROM DUAL;

     FORALL l_index IN p_distribution_id_tbl.FIRST .. p_distribution_id_tbl.LAST
     INSERT INTO gl_bc_packets
        (
         packet_id,
         Ledger_id,
         je_source_name,
         je_category_name,
         code_combination_id,
         actual_flag,
         period_name,
         period_year,
         period_num,
         quarter_num,
         currency_code,
         status_code,
         last_update_date,
         last_updated_by,
         budget_version_id,
         encumbrance_type_id,
         entered_dr,
         entered_cr,
         accounted_dr,
         accounted_cr,
         ussgl_transaction_code,
         reference1,
         reference2,
         reference3,
         reference4,
         reference5,
         je_line_description
         )
        SELECT
         l_packet_id,
         glsob.set_of_books_id,
         'Purchasing',
         'Requisitions',
         prd.budget_account_id,
         'E',
         p_curr_year_start_period,
         p_year + 1,
         p_curr_year_start_num,
         p_curr_year_start_quarter,
         glsob.currency_code,
         'P',
         sysdate,
         g_user_id,
         NULL,
         fsp.req_encumbrance_type_id,
         0 Entered_Dr,
         -1 * (DECODE(base_cur.minimum_accountable_unit,
                       NULL,
                       ROUND((prl.unit_price + po_tax_sv.get_tax('REQ',prd.distribution_id)
                              / prd.req_line_quantity)
                              * (GREATEST
                                   (
                                    DECODE
                                     (NVL(poll.accrue_on_receipt_flag,'N'),
                                      'N',
                                      (prd.req_line_quantity
                                       - po_uom_s.po_uom_convert_p(pol.unit_meas_lookup_code,
                                                                   prl.unit_meas_lookup_code,
                                                                   prl.item_id)
                                       * GREATEST(NVL(pod.quantity_billed,0),
                                                  NVL(pod.quantity_delivered,0)
                                                  )
                                       ),
                                      'Y',
                                      (prd.req_line_quantity
                                       - po_uom_s.po_uom_convert_p(pol.unit_meas_lookup_code,
                                                                   prl.unit_meas_lookup_code,
                                                                   prl.item_id)
                                       * NVL(pod.quantity_delivered,0)
                                       )
                                      )  -- DECODE
                                   ,0) -- GREATEST
                                 ),
                             base_cur.precision),  -- ROUND

                       ROUND(((prl.unit_price + po_tax_sv.get_tax('REQ',prd.distribution_id)
                               / prd.req_line_quantity)
                               * ((GREATEST
                                    (
                                     DECODE
                                      (NVL(poll.accrue_on_receipt_flag,'N'),
                                       'N',
                                       (prd.req_line_quantity
                                        - po_uom_s.po_uom_convert_p(pol.unit_meas_lookup_code,
                                                                    prl.unit_meas_lookup_code,
                                                                    prl.item_id)
                                        * GREATEST(NVL(pod.quantity_billed,0),
                                                   NVL(pod.quantity_delivered,0)
                                                   )
                                        ),
                                       'Y',
                                       (prd.req_line_quantity
                                        - po_uom_s.po_uom_convert_p(pol.unit_meas_lookup_code,
                                                                    prl.unit_meas_lookup_code,
                                                                    prl.item_id)
                                        * NVL(pod.quantity_delivered,0)
                                        )
                                       )  -- DECODE
                                     ,0) -- GREATEST
                                    ) / base_cur.minimum_accountable_unit)
                                 * base_cur.minimum_accountable_unit),
                             base_cur.precision))) Entered_Cr,
         0 Accounted_Dr,
         -1 * (DECODE(base_cur.minimum_accountable_unit,
                       NULL,
                       ROUND((prl.unit_price + po_tax_sv.get_tax('REQ',prd.distribution_id)
                              / prd.req_line_quantity)
                              * (GREATEST
                                   (
                                    DECODE
                                     (NVL(poll.accrue_on_receipt_flag,'N'),
                                      'N',
                                      (prd.req_line_quantity
                                       - po_uom_s.po_uom_convert_p(pol.unit_meas_lookup_code,
                                                                   prl.unit_meas_lookup_code,
                                                                   prl.item_id)
                                       * GREATEST(NVL(pod.quantity_billed,0),
                                                  NVL(pod.quantity_delivered,0)
                                                  )
                                       ),
                                      'Y',
                                      (prd.req_line_quantity
                                       - po_uom_s.po_uom_convert_p(pol.unit_meas_lookup_code,
                                                                   prl.unit_meas_lookup_code,
                                                                   prl.item_id)
                                       * NVL(pod.quantity_delivered,0)
                                       )
                                      )  -- DECODE
                                   ,0) -- GREATEST
                                 ),
                             base_cur.precision),  -- ROUND

                       ROUND(((prl.unit_price + po_tax_sv.get_tax('REQ',prd.distribution_id)
                               / prd.req_line_quantity)
                               * ((GREATEST
                                    (
                                     DECODE
                                      (NVL(poll.accrue_on_receipt_flag,'N'),
                                       'N',
                                       (prd.req_line_quantity
                                        - po_uom_s.po_uom_convert_p(pol.unit_meas_lookup_code,
                                                                    prl.unit_meas_lookup_code,
                                                                    prl.item_id)
                                        * GREATEST(NVL(pod.quantity_billed,0),
                                                   NVL(pod.quantity_delivered,0)
                                                   )
                                        ),
                                       'Y',
                                       (prd.req_line_quantity
                                        - po_uom_s.po_uom_convert_p(pol.unit_meas_lookup_code,
                                                                    prl.unit_meas_lookup_code,
                                                                    prl.item_id)
                                        * NVL(pod.quantity_delivered,0)
                                        )
                                       )  -- DECODE
                                     ,0) -- GREATEST
                                    ) / base_cur.minimum_accountable_unit)
                                 * base_cur.minimum_accountable_unit),
                             base_cur.precision))) Accounted_Cr,
         prd.ussgl_transaction_code,
         'REQ',
         prl.requisition_header_id,
         prd.distribution_id,
         prh.segment1,
         prl.reference_num,
         SUBSTR(prl.item_description,1,25) || '-Year End Process, Adjust Requisition Encumbrance entry'
        FROM
        fnd_currencies                base_cur,
        gl_sets_of_books              glsob,
        financials_system_parameters  fsp,
        po_requisition_lines          prl,
        po_req_distributions          prd,
        po_requisition_headers        prh,
        po_line_locations             poll,
        po_distributions              pod,
        po_lines                      pol
        WHERE
        NVL(prl.closed_code,'OPEN') NOT IN ('CANCELLED','FINALLY CLOSED')
        AND NVL(prl.cancel_flag,'N') = 'N'
        AND NVL(prd.prevent_encumbrance_flag,'N') = 'N'
        AND prd.requisition_line_id  = prl.requisition_line_id
        AND prl.line_location_id = poll.line_location_id
        AND pod.line_location_id = poll.line_location_id
        AND pod.po_distribution_id  = p_distribution_id_tbl(l_index)
--        AND poll.shipment_type IN ('STANDARD','PLANNED')
        AND NVL(poll.cancel_flag,'N') = 'N'
        AND NVL(poll.closed_code,'OPEN') <> 'FINALLY CLOSED'
        AND base_cur.currency_code = glsob.currency_code
        AND fsp.set_of_books_id = glsob.set_of_books_id
        AND pol.po_line_id = poll.po_line_id
        AND poll.shipment_type IN ('BLANKET')
        AND prh.requisition_header_id = prl.requisition_header_id
        ;

     l_result_code := gl_funds_checker_pkg.glxfck(
                                                  p_sobid              => p_sobid,
                                                  p_packetid           => l_packet_id,
                                                  p_mode               => 'F',
                                                  p_partial_resv_flag  => 'N',
                                                  p_override           => 'N',
                                                  p_conc_flag          => 'Y',
                                                  p_user_id            => g_user_id,
                                                  p_user_resp_id       => g_resp_id,
                                                  p_return_code        => l_return_code
                                                  );
     IF NOT(l_result_code) OR (l_return_code NOT IN ('A','S'))
     THEN
       x_return_code := 2 ;
       RETURN;
     END IF ;


  --Process Scheduled Releases backed by Planned PO's
  ELSIF p_document_type = 'REL' AND p_document_subtype IN ('SCHEDULED')
  THEN
     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => 'Starting PO Adjustments for Releases');
     END IF;
     -- cancel the PO encumbrance in the previous year
     SELECT gl_bc_packets_s.nextval
     INTO l_packet_id
     FROM DUAL;

     FORALL l_index IN p_distribution_id_tbl.FIRST .. p_distribution_id_tbl.LAST
     INSERT INTO gl_bc_packets
        (
         packet_id,
         Ledger_id,
         je_source_name,
         je_category_name,
         code_combination_id,
         actual_flag,
         period_name,
         period_year,
         period_num,
         quarter_num,
         currency_code,
         status_code,
         last_update_date,
         last_updated_by,
         budget_version_id,
         encumbrance_type_id,
         entered_dr,
         entered_cr,
         accounted_dr,
         accounted_cr,
         ussgl_transaction_code,
         reference1,
         reference2,
         reference3,
         reference4,
         reference5,
         je_line_description
         )
        SELECT
         l_packet_id,
         glsob.set_of_books_id,
         'Purchasing',
         'Purchases',
         prd.budget_account_id,
         'E',
         p_prev_year_end_period,
         p_year,
         p_prev_year_end_num,
         p_prev_year_end_quarter,
         glsob.currency_code,
         'P',
         sysdate,
         g_user_id,
         NULL,
         fsp.purch_encumbrance_type_id,
         -1 * (DECODE(base_cur.minimum_accountable_unit,
                       NULL,
                       ROUND((poll.price_override + po_tax_sv.get_tax('PO',pod.po_distribution_id)
                              / pod.quantity_ordered)
                              * NVL(pod.rate,1)
                                 * (
                                    DECODE
                                     (NVL(prll.accrue_on_receipt_flag,'N'),
                                      'N',
                                      (prd.quantity_ordered
                                       - GREATEST(NVL(prd.quantity_billed,0),
                                                  NVL(pod.quantity_delivered,0)
                                                  )
                                       ),
                                      'Y',
                                      (prd.quantity_ordered
                                       - NVL(prd.quantity_delivered,0)
                                       )
                                      )  -- DECODE
                                 ),
                             base_cur.precision),  -- ROUND

                       ROUND(((poll.price_override + po_tax_sv.get_tax('PO',pod.po_distribution_id)
                               / pod.quantity_ordered)
                               * NVL(pod.rate,1)
                                  * ((
                                     DECODE
                                      (NVL(prll.accrue_on_receipt_flag,'N'),
                                       'N',
                                       (prd.quantity_ordered
                                        - GREATEST(NVL(prd.quantity_billed,0),
                                                   NVL(pod.quantity_delivered,0)
                                                   )
                                        ),
                                       'Y',
                                       (prd.quantity_ordered
                                        - NVL(prd.quantity_delivered,0)
                                        )
                                       )  -- DECODE
                                    ) / base_cur.minimum_accountable_unit)
                                 * base_cur.minimum_accountable_unit),
                             base_cur.precision))) Entered_Dr,
         0 Entered_Cr,
         -1 * (DECODE(base_cur.minimum_accountable_unit,
                       NULL,
                       ROUND((poll.price_override + po_tax_sv.get_tax('PO',pod.po_distribution_id)
                              / pod.quantity_ordered)
                              * NVL(pod.rate,1)
                                 * (
                                    DECODE
                                     (NVL(prll.accrue_on_receipt_flag,'N'),
                                      'N',
                                      (prd.quantity_ordered
                                       - GREATEST(NVL(prd.quantity_billed,0),
                                                  NVL(pod.quantity_delivered,0)
                                                  )
                                       ),
                                      'Y',
                                      (prd.quantity_ordered
                                       - NVL(prd.quantity_delivered,0)
                                       )
                                      )  -- DECODE
                                 ),
                             base_cur.precision),  -- ROUND

                       ROUND(((poll.price_override + po_tax_sv.get_tax('PO',pod.po_distribution_id)
                               / pod.quantity_ordered)
                               * NVL(pod.rate,1)
                                  * ((
                                     DECODE
                                      (NVL(prll.accrue_on_receipt_flag,'N'),
                                       'N',
                                       (prd.quantity_ordered
                                        - GREATEST(NVL(prd.quantity_billed,0),
                                                   NVL(pod.quantity_delivered,0)
                                                   )
                                        ),
                                       'Y',
                                       (prd.quantity_ordered
                                        - NVL(prd.quantity_delivered,0)
                                        )
                                       )  -- DECODE
                                    ) / base_cur.minimum_accountable_unit)
                                 * base_cur.minimum_accountable_unit),
                             base_cur.precision))) Accounted_Dr,
         0 Accounted_Cr,
         prd.ussgl_transaction_code,
         'PO',
         poh.po_header_id,
         pod.po_distribution_id,
         poh.segment1,
         NULL,
         SUBSTR(pol.item_description,1,25) || '-Year End Process, Adjust Planned PO Encumbrance entry'
        FROM
        fnd_currencies                base_cur,
        gl_sets_of_books              glsob,
        financials_system_parameters  fsp,
        po_headers                    poh,
        po_line_locations             poll,
        po_line_locations             prll,
        po_distributions              pod,
        po_distributions              prd,
        po_lines                      pol
        WHERE
        NVL(poll.closed_code,'OPEN') <> ('FINALLY CLOSED')
        AND NVL(poll.cancel_flag,'N') = 'N'
        AND poh.po_header_id = poll.po_header_id
        AND poll.line_location_id = pod.line_location_id
        AND pod.po_distribution_id = prd.source_distribution_id
        AND prd.po_distribution_id  = p_distribution_id_tbl(l_index)
        AND NVL(prd.prevent_encumbrance_flag,'N') = 'N'
        AND NVL(prd.encumbered_flag,'N') = 'Y'
        AND NVL(prll.cancel_flag,'N') = 'N'
        AND NVL(prll.closed_code,'OPEN') <> ('FINALLY CLOSED')
        AND prll.shipment_type IN ('SCHEDULED')
        AND prll.line_location_id = prd.line_location_id
        AND base_cur.currency_code = glsob.currency_code
        AND fsp.set_of_books_id = glsob.set_of_books_id
        AND pol.po_line_id = poll.po_line_id
        ;

     l_result_code := gl_funds_checker_pkg.glxfck(
                                                  p_sobid              => p_sobid,
                                                  p_packetid           => l_packet_id,
                                                  p_mode               => 'F',
                                                  p_partial_resv_flag  => 'N',
                                                  p_override           => 'N',
                                                  p_conc_flag          => 'Y',
                                                  p_user_id            => g_user_id,
                                                  p_user_resp_id       => g_resp_id,
                                                  p_return_code        => l_return_code
                                                  );
     IF NOT(l_result_code) OR (l_return_code NOT IN ('A','S'))
     THEN
       x_return_code := 2 ;
       RETURN;
     END IF;
     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => 'Completed prev year adjustment');
     END IF;

     -- Now repeat the above to cancel the requisition encumbrances in the current year
     SELECT gl_bc_packets_s.nextval
     INTO l_packet_id
     FROM DUAL;

     FORALL l_index IN p_distribution_id_tbl.FIRST .. p_distribution_id_tbl.LAST
     INSERT INTO gl_bc_packets
        (
         packet_id,
         Ledger_id,
         je_source_name,
         je_category_name,
         code_combination_id,
         actual_flag,
         period_name,
         period_year,
         period_num,
         quarter_num,
         currency_code,
         status_code,
         last_update_date,
         last_updated_by,
         budget_version_id,
         encumbrance_type_id,
         entered_dr,
         entered_cr,
         accounted_dr,
         accounted_cr,
         ussgl_transaction_code,
         reference1,
         reference2,
         reference3,
         reference4,
         reference5,
         je_line_description
         )
        SELECT
         l_packet_id,
         glsob.set_of_books_id,
         'Purchasing',
         'Purchases',
         prd.budget_account_id,
         'E',
         p_curr_year_start_period,
         p_year + 1,
         p_curr_year_start_num,
         p_curr_year_start_quarter,
         glsob.currency_code,
         'P',
         sysdate,
         g_user_id,
         NULL,
         fsp.purch_encumbrance_type_id,
         0 Entered_Dr,
         -1 * (DECODE(base_cur.minimum_accountable_unit,
                       NULL,
                       ROUND((poll.price_override + po_tax_sv.get_tax('PO',pod.po_distribution_id)
                              / pod.quantity_ordered)
                              * NVL(pod.rate,1)
                                 * (
                                    DECODE
                                     (NVL(prll.accrue_on_receipt_flag,'N'),
                                      'N',
                                      (prd.quantity_ordered
                                       - GREATEST(NVL(prd.quantity_billed,0),
                                                  NVL(pod.quantity_delivered,0)
                                                  )
                                       ),
                                      'Y',
                                      (prd.quantity_ordered
                                       - NVL(prd.quantity_delivered,0)
                                       )
                                      )  -- DECODE
                                 ),
                             base_cur.precision),  -- ROUND

                       ROUND(((poll.price_override + po_tax_sv.get_tax('PO',pod.po_distribution_id)
                               / pod.quantity_ordered)
                               * NVL(pod.rate,1)
                                  * ((
                                     DECODE
                                      (NVL(prll.accrue_on_receipt_flag,'N'),
                                       'N',
                                       (prd.quantity_ordered
                                        - GREATEST(NVL(prd.quantity_billed,0),
                                                   NVL(pod.quantity_delivered,0)
                                                   )
                                        ),
                                       'Y',
                                       (prd.quantity_ordered
                                        - NVL(prd.quantity_delivered,0)
                                        )
                                       )  -- DECODE
                                    ) / base_cur.minimum_accountable_unit)
                                 * base_cur.minimum_accountable_unit),
                             base_cur.precision))) Entered_Cr,
         0 Accounted_Dr,
         -1 * (DECODE(base_cur.minimum_accountable_unit,
                       NULL,
                       ROUND((poll.price_override + po_tax_sv.get_tax('PO',pod.po_distribution_id)
                              / pod.quantity_ordered)
                              * NVL(pod.rate,1)
                                 * (
                                    DECODE
                                     (NVL(prll.accrue_on_receipt_flag,'N'),
                                      'N',
                                      (prd.quantity_ordered
                                       - GREATEST(NVL(prd.quantity_billed,0),
                                                  NVL(pod.quantity_delivered,0)
                                                  )
                                       ),
                                      'Y',
                                      (prd.quantity_ordered
                                       - NVL(prd.quantity_delivered,0)
                                       )
                                      )  -- DECODE
                                 ),
                             base_cur.precision),  -- ROUND

                       ROUND(((poll.price_override + po_tax_sv.get_tax('PO',pod.po_distribution_id)
                               / pod.quantity_ordered)
                               * NVL(pod.rate,1)
                                  * ((
                                     DECODE
                                      (NVL(prll.accrue_on_receipt_flag,'N'),
                                       'N',
                                       (prd.quantity_ordered
                                        - GREATEST(NVL(prd.quantity_billed,0),
                                                   NVL(pod.quantity_delivered,0)
                                                   )
                                        ),
                                       'Y',
                                       (prd.quantity_ordered
                                        - NVL(prd.quantity_delivered,0)
                                        )
                                       )  -- DECODE
                                    ) / base_cur.minimum_accountable_unit)
                                 * base_cur.minimum_accountable_unit),
                             base_cur.precision))) Accounted_Cr,
         prd.ussgl_transaction_code,
         'PO',
         poh.po_header_id,
         pod.po_distribution_id,
         poh.segment1,
         NULL,
         SUBSTR(pol.item_description,1,25) || '-Year End Process, Adjust Planned PO Encumbrance entry'
        FROM
        fnd_currencies                base_cur,
        gl_sets_of_books              glsob,
        financials_system_parameters  fsp,
        po_headers                    poh,
        po_line_locations             poll,
        po_line_locations             prll,
        po_distributions              pod,
        po_distributions              prd,
        po_lines                      pol
        WHERE
        NVL(poll.closed_code,'OPEN') <> ('FINALLY CLOSED')
        AND NVL(poll.cancel_flag,'N') = 'N'
        AND poh.po_header_id = poll.po_header_id
        AND poll.line_location_id = pod.line_location_id
        AND pod.po_distribution_id = prd.source_distribution_id
        AND prd.po_distribution_id  = p_distribution_id_tbl(l_index)
        AND NVL(prd.prevent_encumbrance_flag,'N') = 'N'
        AND NVL(prd.encumbered_flag,'N') = 'Y'
        AND NVL(prll.cancel_flag,'N') = 'N'
        AND NVL(prll.closed_code,'OPEN') <> ('FINALLY CLOSED')
        AND prll.shipment_type IN ('SCHEDULED')
        AND prll.line_location_id = prd.line_location_id
        AND base_cur.currency_code = glsob.currency_code
        AND fsp.set_of_books_id = glsob.set_of_books_id
        AND pol.po_line_id = poll.po_line_id
        ;

     l_result_code := gl_funds_checker_pkg.glxfck(
                                                  p_sobid              => p_sobid,
                                                  p_packetid           => l_packet_id,
                                                  p_mode               => 'F',
                                                  p_partial_resv_flag  => 'N',
                                                  p_override           => 'N',
                                                  p_conc_flag          => 'Y',
                                                  p_user_id            => g_user_id,
                                                  p_user_resp_id       => g_resp_id,
                                                  p_return_code        => l_return_code
                                                  );
     IF NOT(l_result_code) OR (l_return_code NOT IN ('A','S'))
     THEN
       x_return_code := 2 ;
       RETURN;
     END IF ;

  END IF;

  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg (l_full_path,p_debug_msg => 'Completed journal adjustments');
  END IF;
  x_return_code := -99 ;

EXCEPTION
  WHEN OTHERS THEN
     IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Create Journal Adjustment');
     END IF;
     IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
     END IF;
     APP_EXCEPTION.Raise_Exception;
END Create_Journal_Adjustments;



--  Procedure Process_Document
--  ==========================
--
--  This Procedure processes the document when the process has been called in Final Mode.
--  This entails unreserving the encumbrance in the previous year and reserving in the current year.
--  The CBC Acct Date of the document is also updated to the new year, as well as the GL date of any
--  relevant distributions
--
--  IN Parameters
--  -------------
--  p_sob_id                 Set of Books Id
--  p_org_id                 Org Id
--  p_year                   Year being processed
--  p_process_phase          User entered processing phase: F - Final, P - Preliminary
--  p_document_type          Type of document: PO, REQ or REL
--  p_document_subtype       Subtype of document type: BLANKET, SCHEDULED, PLANNED, STANDARD, etc
--  p_document_id            Id of document
--  p_prev_year_end_date     End Date of year being closed
--  p_prev_year_end_period   End period name of year being closed
--  p_prev_year_end_num      End period number of year being closed
--  p_prev_year_end_quarter  End quarter number of year being closed
--  p_curr_year_start_date   Start Date of current year
--  p_curr_year_start_period First period of current year
--  p_curr_year_start_num    Start period number of current year
--  p_curr_year_start_quarter Start quarter number of current year
--
--  OUT Parameters
--  --------------
--  x_return_code            Indicates the return status of the procedure:
--                              0 - Need to terminate processing successfully
--                              1 - Need to terminate processing with warning
--                              2 - Need to terminate processing with error
--                            -99 - Successful, continue processing
--  x_msg_buf                stores any error message encountered
--
--
-- bug 2804025 ssmales 19-Feb-2003 added new params
PROCEDURE Process_Document(p_sobid                   IN NUMBER,
                           p_org_id                  IN NUMBER,
                           p_year                    IN NUMBER,
                           p_process_phase           IN VARCHAR2,
                           p_document_type           IN VARCHAR2,
                           p_document_subtype        IN VARCHAR2,
                           p_document_id             IN NUMBER,
                           p_prev_year_end_date      IN DATE,
                           p_prev_year_end_period    IN VARCHAR2,
                           p_prev_year_end_num       IN NUMBER,
                           p_prev_year_end_quarter   IN NUMBER,
                           p_prev_cbc_acct_date      IN DATE,
                           p_curr_year_start_date    IN DATE,
                           p_curr_year_start_period  IN VARCHAR2,
                           p_curr_year_start_num     IN NUMBER,
                           p_curr_year_start_quarter IN NUMBER,
                           x_return_code             OUT NOCOPY NUMBER,
                           x_msg_buf                 OUT NOCOPY VARCHAR2
                           ) AS

-- need to initialize following tables, values are irrelevant
l_distribution_id_tbl  igc_tbl_number := igc_tbl_number(0);
l_gl_enc_date_tbl      igc_tbl_date   := igc_tbl_date(sysdate);
l_gl_enc_prd_tbl       igc_tbl_varchar30 := igc_tbl_varchar30(null);

TYPE c_prev_val_type IS REF CURSOR ;

c_prev_val  c_prev_val_type ;

l_return_status    VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_msg_count        NUMBER := 0;
l_msg_data         VARCHAR2(2000) := null ;
l_info_request     VARCHAR2(25) := null ;
l_document_status  VARCHAR2(240) := null ;
l_online_report_id NUMBER := 0 ;
l_return_code      VARCHAR2(25) := null ;
l_error_msg        VARCHAR2(2000) := null ;
l_return_value     NUMBER := -99 ;
l_document_type    VARCHAR2(25) := null ;
l_err_code         VARCHAR2(100) := null ;

l_full_path      VARCHAR2(500) := g_path||'Process_Document';
BEGIN
   IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg (l_full_path,p_debug_msg => '**** Process Document ****');
      Put_Debug_Msg (l_full_path,p_debug_msg => 'Document Type    : '||p_document_type);
      Put_Debug_Msg (l_full_path,p_debug_msg => 'Document Subtype : '||p_document_subtype);
      Put_Debug_Msg (l_full_path,p_debug_msg => 'Document ID      : '||p_document_id);
   END IF;

   l_distribution_id_tbl.DELETE;
   l_gl_enc_date_tbl.DELETE;
   l_gl_enc_prd_tbl.DELETE;

-- set cursor select depending upon document type
--  IF p_document_type = 'PO'
  IF p_document_type  IN  ('PO' , 'PA')
  THEN
     OPEN c_prev_val FOR SELECT distribution_id,
                                gl_encumbered_date,
                                gl_encumbered_period_name
                         FROM igc_cbc_po_process_gt
                         WHERE encumbered_flag = 'Y'
                         AND po_header_id = p_document_id ;
  ELSIF p_document_type = 'REL'
  THEN
     OPEN c_prev_val FOR SELECT distribution_id,
                                gl_encumbered_date,
                                gl_encumbered_period_name
                         FROM igc_cbc_po_process_gt
                         WHERE encumbered_flag = 'Y'
                         AND po_release_id = p_document_id ;
  ELSIF p_document_type = 'REQ'
  THEN
     -- Requisitions created from backing BPA will not be encumbered
     -- when they are first created , hence the prevent_encumbrance_flag
     -- will be set to 'Y'. However once they are matched to a PO, subsequent
     -- encumberance actions on the PO resets the flag on the requisition thus
     -- enucmbering the requisition. For this reason, we should also
     -- move the date on the requisition even though there will not be
     -- any outstanding encumbrances per se.
     -- New for PRC.FP.J - 3173178
     OPEN c_prev_val FOR SELECT distribution_id,
                                gl_encumbered_date,
                                gl_encumbered_period_name
                         FROM igc_cbc_po_process_gt
                         WHERE (encumbered_flag = 'Y'
                         OR  (  prevent_encumbrance_flag = 'Y'
                         AND    blanket_po_header_id IS NOT NULL))
                         AND req_header_id = p_document_id ;
  END IF; -- p_document_type = 'PO'

-- retrieve all distributions' date details for this document
  FETCH c_prev_val BULK COLLECT INTO l_distribution_id_tbl,
                                     l_gl_enc_date_tbl,
                                     l_gl_enc_prd_tbl;
  CLOSE c_prev_val;

   IF l_distribution_id_tbl.FIRST IS NULL THEN
      Put_Debug_Msg (l_full_path,p_debug_msg => 'No encumbered distributions to process');
      l_err_code := 'IGC_PO_YEP_NO_ENC_DIST';
      FND_MESSAGE.set_name('IGC',l_err_code);
      l_msg_data := FND_MESSAGE.get;
      Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                              p_exception_code     =>  l_err_code,
                              p_document_type      =>  p_document_type,
                              p_document_id        =>  p_document_id);
      x_return_code := -99;
      RETURN;
   END IF;

   IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg (l_full_path,p_debug_msg => 'completed get previous values');
   END IF;

-- We need to unreserve funds as of the last date of the previous fiscal year, therefore update
-- the CBC acct date to this date
  IGC_CBC_PO_GRP.update_cbc_acct_date(p_document_id       =>  p_document_id,
                                      p_document_type     =>  p_document_type,
                                      p_document_sub_type =>  p_document_subtype,
                                      p_cbc_acct_date     =>  p_prev_year_end_date,
                                      p_api_version       =>  1,
                                      p_init_msg_list     =>  FND_API.G_FALSE,
                                      p_commit            =>  FND_API.G_FALSE,
                                      p_validation_level  =>  FND_API.G_VALID_LEVEL_FULL,
                                      x_return_status     =>  l_return_status,
                                      x_msg_count         =>  l_msg_count,
                                      x_msg_data          =>  l_msg_data
                                      );
   IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg (l_full_path,p_debug_msg => 'Completed Update CBC Acct Date');
   END IF;

-- if update unsuccessful then report errors and terminate processing with errors.
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS
  THEN
    l_msg_data := '';
    For j in 1..NVL(l_msg_count,0) LOOP
       l_msg_data := FND_MSG_PUB.Get(p_msg_index => j,
                                     p_encoded   => 'T');
       Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                               p_exception_code     =>  l_return_status,
                               p_document_type      =>  p_document_type,
                               p_document_id        =>  p_document_id);
       x_return_code := 2 ;
       FND_MESSAGE.set_name('IGC','IGC_PO_YEP_ACCT_DATE_UPD_ERR');
       x_msg_buf := FND_MESSAGE.get ;
       RETURN;
    END LOOP;
  END IF; -- l_return_status <> fnd_api.g_ret_sts_success

 -- set document_type for use in PO funds checker
  IF p_document_type = 'REQ'
  THEN
     l_document_type := 'REQUISITION';
  ELSIF p_document_type = 'PO'
  THEN
     l_document_type := 'PO';
  ELSIF p_document_type = 'REL'
  THEN
     l_document_type := 'RELEASE';
  ELSIF p_document_type = 'PA'
  THEN
     l_document_type := 'PA';
  ELSE
     l_document_type := p_document_type;
  END IF; -- p_document_type = 'REQ'

-- we need to commit, as the PO funds checker is called as an autonomous transaction, so if we
-- do not commit the updated date will not be visible to this process
  COMMIT;

-- Unreserve Funds
  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg (l_full_path,p_debug_msg => 'Calling Unreserve...');
     Put_Debug_Msg (l_full_path,p_debug_msg => 'document type    :'||l_document_type);
     Put_Debug_Msg (l_full_path,p_debug_msg => 'document subtype :'||p_document_subtype);
     Put_Debug_Msg (l_full_path,p_debug_msg => 'document id      :'||p_document_id);
     Put_Debug_Msg (l_full_path,p_debug_msg => 'action_date      :'||p_prev_year_end_date);
  END IF;

  l_return_value :=
     PO_DOCUMENT_ACTIONS_SV.po_request_action(action              =>  'IGC YEAR END UNRESERVE',
                                              document_type       =>  l_document_type,
                                              document_subtype    =>  p_document_subtype,
                                              document_id         =>  p_document_id,
                                              line_id             =>  NULL,
                                              shipment_id         =>  NULL,
                                              distribution_id     =>  NULL,
                                              employee_id         =>  NULL,
                                              new_document_status =>  NULL,
                                              offline_code        =>  NULL,
                                              note                =>  NULL,
                                              approval_path_id    =>  NULL,
                                              forward_to_id       =>  NULL,
                                              action_date         =>  p_prev_year_end_date,
                                              override_funds      =>  NULL,
                                              info_request        =>  l_info_request,
                                              document_status     =>  l_document_status,
                                              online_report_id    =>  l_online_report_id,
                                              return_code         =>  l_return_code,
                                              error_msg           =>  l_error_msg
                                              );

  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg (l_full_path,p_debug_msg => 'completed PO Request Action - Unreserve');
     Put_Debug_Msg (l_full_path,p_debug_msg => 'return value:'||l_return_value          );
     Put_Debug_Msg (l_full_path,p_debug_msg => 'info_request:'||l_info_request          );
     Put_Debug_Msg (l_full_path,p_debug_msg => 'document_status'||l_document_status     );
     Put_Debug_Msg (l_full_path,p_debug_msg => 'online report id:'||l_online_report_id  );
     Put_Debug_Msg (l_full_path,p_debug_msg => 'return code:'||l_return_code            );
     Put_Debug_Msg (l_full_path,p_debug_msg => 'error msg: '||l_error_msg               );
  END IF;

-- report any errors with the unreserve
  IF l_return_value <> 0 OR l_return_code IN ('R','F','T','P') OR length(trim(l_error_msg)) > 0 --l_error_msg IS NOT NULL
  THEN
     FND_MESSAGE.set_name('IGC','IGC_PO_YEP_DOC_FAIL_FC');
     l_msg_data := FND_MESSAGE.get;
     l_msg_data := l_msg_data ||' - '||l_error_msg;
     Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                             p_exception_code     =>  l_return_code,
                             p_document_type      =>  p_document_type,
                             p_document_id        =>  p_document_id);

     -- if the funds check itself has failed we need to revert the cbc acct date back to it's
     -- original value
     IF l_return_code NOT IN ('S','A')
     THEN
        IGC_CBC_PO_GRP.update_cbc_acct_date(p_document_id       =>  p_document_id,
                                            p_document_type     =>  p_document_type,
                                            p_document_sub_type =>  p_document_subtype,
                                            p_cbc_acct_date     =>  p_prev_cbc_acct_date,
                                            p_api_version       =>  1,
                                            p_init_msg_list     =>  FND_API.G_FALSE,
                                            p_commit            =>  FND_API.G_FALSE,
                                            p_validation_level  =>  FND_API.G_VALID_LEVEL_FULL,
                                            x_return_status     =>  l_return_status,
                                            x_msg_count         =>  l_msg_count,
                                            x_msg_data          =>  l_msg_data
                                            );

        IF (g_debug_mode = 'Y') THEN
           Put_Debug_Msg (l_full_path,p_debug_msg => 'completed Update CBC Acct Date - Unreserve failure');
        END IF;
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
           -- if update unsuccessful report errors
           l_msg_data := '';
           For j in 1..NVL(l_msg_count,0) LOOP
              l_msg_data := FND_MSG_PUB.Get(p_msg_index => j,
                                            p_encoded   => 'T');
              Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                                      p_exception_code     =>  l_return_status,
                                      p_document_type      =>  p_document_type,
                                      p_document_id        =>  p_document_id);
           END LOOP;
        END IF; -- l_return_status <> fnd_api.g_ret_sts_success

-- commit updates
        COMMIT ;

     END IF; -- l_return_code NOT in ('S','A')

-- as the unreserve failed, terminate processing with error
     x_return_code := 2;
     FND_MESSAGE.set_name('IGC','IGC_PO_YEP_DOC_FAIL_FC');
     x_msg_buf := FND_MESSAGE.get;
     RETURN;
  END IF; -- l_return_value <> 0 ...

-- Unreserve successful, so continue

-- as the funds check will have released the locks on the document, we need to relock
-- However, as the commit in the funds checker is to be removed in the near future, we will commit
-- here ourselves, so as not to invalidate the following lock.
  COMMIT;
     -- Lock the document and children
  IF Lock_Documents(p_document_type      =>  p_document_type,
                    p_document_id        =>  p_document_id) <> FND_API.G_RET_STS_SUCCESS
  THEN
     -- if unable to relock doc report error and do not process this doc any further
     l_err_code := 'IGC_PO_YEP_RELOCK_DOCUMENT';
     FND_MESSAGE.set_name('IGC',l_err_code);
     l_msg_data := FND_MESSAGE.get;
     Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                             p_document_type      =>  p_document_type,
                             p_document_id        =>  p_document_id);
     -- do not process this doc any further
     x_return_code := -99;
     RETURN;
  END IF; -- Lock_Documents


-- Update the GL date of all distributions related to the document
  IF p_document_type = 'REQ'
  THEN
     BEGIN
        FORALL l_index IN l_distribution_id_tbl.FIRST .. l_distribution_id_tbl.LAST
           UPDATE po_req_distributions  prd
           SET prd.gl_encumbered_date = p_curr_year_start_date,
               prd.gl_encumbered_period_name = p_curr_year_start_period
           WHERE prd.distribution_id = l_distribution_id_tbl(l_index);
     EXCEPTION
        WHEN OTHERS THEN
           Rollback; -- release locks
           IF ( g_unexp_level >= g_debug_level ) THEN
              FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
              FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
              FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
              FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
           END IF;
           -- Terminate processing with error
           IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
             FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Process_Document');
           END IF;
           x_return_code := 2;
           fnd_message.set_name('IGC','IGC_LOGGING_USER_ERROR');
     x_msg_buf := fnd_message.get;
           RETURN;
     END;
     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => 'completed update of po_req_distributions table');
     END IF;
  ELSE
     BEGIN
        FORALL l_index IN l_distribution_id_tbl.FIRST .. l_distribution_id_tbl.LAST
           UPDATE po_distributions  pod
           SET pod.gl_encumbered_date = p_curr_year_start_date,
               pod.gl_encumbered_period_name = p_curr_year_start_period
           WHERE pod.po_distribution_id = l_distribution_id_tbl(l_index);
     EXCEPTION
        WHEN OTHERS THEN
           Rollback; -- release locks
  IF ( g_unexp_level >= g_debug_level ) THEN
            FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
            FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
            FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
            FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
      END IF;
           -- Terminate processing with error
           IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Process_Document');
           END IF;
           x_return_code := 2;
           fnd_message.set_name('IGC','IGC_LOGGING_USER_ERROR');
     x_msg_buf := fnd_message.get;
           RETURN;
     END;
     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => 'completed update of po_distributions table');
     END IF;
  END IF ; -- p_document_type = 'REQ'


-- Update the cbc acct date of the document to the first date of the current year
  IGC_CBC_PO_GRP.update_cbc_acct_date(p_document_id       =>  p_document_id,
                                      p_document_type     =>  p_document_type,
                                      p_document_sub_type =>  p_document_subtype,
                                      p_cbc_acct_date     =>  p_curr_year_start_date,
                                      p_api_version       =>  1,
                                      p_init_msg_list     =>  FND_API.G_FALSE,
                                      p_commit            =>  FND_API.G_FALSE,
                                      p_validation_level  =>  FND_API.G_VALID_LEVEL_FULL,
                                      x_return_status     =>  l_return_status,
                                      x_msg_count         =>  l_msg_count,
                                      x_msg_data          =>  l_msg_data
                                      );
   IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg (l_full_path,p_debug_msg => 'completed Update CBC Acct Date - current year');
   END IF;

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS
  THEN
     -- if update unsuccessful rollback the transaction, report errors and terminate processing with error
     Rollback ;
     l_msg_data := '';
     For j in 1..NVL(l_msg_count,0) LOOP
        l_msg_data := FND_MSG_PUB.Get(p_msg_index => j,
                                      p_encoded   => 'T');
        Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                                p_exception_code     =>  l_return_status,
                                p_document_type      =>  p_document_type,
                                p_document_id        =>  p_document_id);
     END LOOP;
     x_return_code := 2;
     FND_MESSAGE.set_name('IGC','IGC_PO_YEP_ACCT_DATE_UPD_ERR');
     x_msg_buf := FND_MESSAGE.get;
  END IF; -- l_return_status <> fnd_api.g_ret_sts_success



-- we need to commit, as the PO funds checker is called as an autonomous transaction, so if we
-- do not commit the updated date will not be visible to this process
  COMMIT;

-- Reserve Funds
  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg (l_full_path,p_debug_msg => 'Calling Reserve...');
     Put_Debug_Msg (l_full_path,p_debug_msg => 'document type    :'||l_document_type);
     Put_Debug_Msg (l_full_path,p_debug_msg => 'document subtype :'||p_document_subtype);
     Put_Debug_Msg (l_full_path,p_debug_msg => 'document id      :'||p_document_id);
  END IF;

  l_return_value :=
     PO_DOCUMENT_ACTIONS_SV.po_request_action(action              =>  'IGC YEAR END RESERVE',
                                              document_type       =>  l_document_type,
                                              document_subtype    =>  p_document_subtype,
                                              document_id         =>  p_document_id,
                                              line_id             =>  NULL,
                                              shipment_id         =>  NULL,
                                              distribution_id     =>  NULL,
                                              employee_id         =>  NULL,
                                              new_document_status =>  NULL,
                                              offline_code        =>  NULL,
                                              note                =>  NULL,
                                              approval_path_id    =>  NULL,
                                              forward_to_id       =>  NULL,
                                              action_date         =>  NULL,
                                              override_funds      =>  NULL,
                                              info_request        =>  l_info_request,
                                              document_status     =>  l_document_status,
                                              online_report_id    =>  l_online_report_id,
                                              return_code         =>  l_return_code,
                                              error_msg           =>  l_error_msg
                                              );
  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg (l_full_path,p_debug_msg => 'completed PO Request Action - Reserve');
     Put_Debug_Msg (l_full_path,p_debug_msg => 'return value:'||l_return_value          );
     Put_Debug_Msg (l_full_path,p_debug_msg => 'info_request:'||l_info_request          );
     Put_Debug_Msg (l_full_path,p_debug_msg => 'document_status'||l_document_status     );
     Put_Debug_Msg (l_full_path,p_debug_msg => 'online report id:'||l_online_report_id  );
     Put_Debug_Msg (l_full_path,p_debug_msg => 'return code:'||l_return_code            );
     Put_Debug_Msg (l_full_path,p_debug_msg => 'error msg: '||l_error_msg               );
  END IF;

  IF l_return_value <> 0 OR l_return_code IN ('R','F','T','P') OR length(trim(l_error_msg)) > 0  --l_error_msg IS NOT NULL
  THEN
     -- if unsuccessful report errors
     FND_MESSAGE.set_name('IGC','IGC_PO_YEP_DOC_FAIL_FC');
     l_msg_data := FND_MESSAGE.get;
     l_msg_data := l_msg_data ||' - '||l_error_msg;
     Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                             p_exception_code     =>  l_return_code,
                             p_document_type      =>  p_document_type,
                             p_document_id        =>  p_document_id);

     IF l_return_code NOT IN ('S','A')
     THEN

        -- as the funds check will have released the locks on the document, we need to relock
        -- Lock the document and children
        IF Lock_Documents(p_document_type    =>  p_document_type,
                          p_document_id      =>  p_document_id) <> FND_API.G_RET_STS_SUCCESS
        THEN
           -- if unable to relock doc report error and do not process this doc any further
           l_err_code := 'IGC_PO_YEP_RELOCK_DOCUMENT';
           FND_MESSAGE.set_name('IGC',l_err_code);
           l_msg_data := FND_MESSAGE.get;
           Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                                   p_exception_code     =>  l_err_code,
                                   p_document_type      =>  p_document_type,
                                   p_document_id        =>  p_document_id);
           -- terminate processing with error
           x_return_code := 2;
           RETURN;
        END IF; -- Lock_Documents

        -- if funds check itself is unsuccessful then we need to revert the cbc acct date
        -- back to it's original value
        IGC_CBC_PO_GRP.update_cbc_acct_date(p_document_id       =>  p_document_id,
                                            p_document_type     =>  p_document_type,
                                            p_document_sub_type =>  p_document_subtype,
                                            p_cbc_acct_date     =>  p_prev_year_end_date,
                                            p_api_version       =>  1,
                                            p_init_msg_list     =>  FND_API.G_FALSE,
                                            p_commit            =>  FND_API.G_FALSE,
                                            p_validation_level  =>  FND_API.G_VALID_LEVEL_FULL,
                                            x_return_status     =>  l_return_status,
                                            x_msg_count         =>  l_msg_count,
                                            x_msg_data          =>  l_msg_data
                                            );
        IF (g_debug_mode = 'Y') THEN
           Put_Debug_Msg (l_full_path,p_debug_msg => 'completed Update CBC Acct Date - Reserve failure');
        END IF;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
           -- if update unsuccessful then report errors
           l_msg_data := '';
           For j in 1..NVL(l_msg_count,0) LOOP
              l_msg_data := FND_MSG_PUB.Get(p_msg_index => j,
                                            p_encoded   => 'T');
              Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                                      p_exception_code     =>  l_return_status,
                                      p_document_type      =>  p_document_type,
                                      p_document_id        =>  p_document_id);
           END LOOP;
        END IF; -- l_return_status <> fnd_api.g_ret_stst_success

-- As reserve funds has failed, reset the GL dates of all distributions related to the document
        IF p_document_type = 'REQ'
        THEN
           BEGIN
              FORALL l_index IN l_distribution_id_tbl.FIRST .. l_distribution_id_tbl.LAST
                 UPDATE po_req_distributions  prd
                 SET prd.gl_encumbered_date = l_gl_enc_date_tbl(l_index),
                     prd.gl_encumbered_period_name = l_gl_enc_prd_tbl(l_index)
                 WHERE prd.distribution_id = l_distribution_id_tbl(l_index);
           EXCEPTION
              WHEN OTHERS THEN
                 Rollback; -- release locks
        IF ( g_unexp_level >= g_debug_level ) THEN
            FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
            FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
            FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
            FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
          END IF;
                 -- Terminate processing with error
                 IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
                    FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Process_Document');
                 END IF;
                 x_return_code := 2;
            fnd_message.set_name('IGC','IGC_LOGGING_USER_ERROR');
      x_msg_buf := fnd_message.get;
                 RETURN;
           END;
           IF (g_debug_mode = 'Y') THEN
              Put_Debug_Msg (l_full_path,p_debug_msg => 'completed 2nd update of po_req_distributions table');
           END IF;
        ELSE
           BEGIN
              FORALL l_index IN l_distribution_id_tbl.FIRST .. l_distribution_id_tbl.LAST
                 UPDATE po_distributions  pod
                 SET pod.gl_encumbered_date = l_gl_enc_date_tbl(l_index),
                     pod.gl_encumbered_period_name = l_gl_enc_prd_tbl(l_index)
                 WHERE pod.po_distribution_id = l_distribution_id_tbl(l_index);
           EXCEPTION
              WHEN OTHERS THEN
                 Rollback; -- release locks
        IF ( g_unexp_level >= g_debug_level ) THEN
            FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
            FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
            FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
            FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
          END IF;
                 -- Terminate processing with error
                 IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
                    FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Process_Document');
                 END IF;
                 x_return_code := 2;
            fnd_message.set_name('IGC','IGC_LOGGING_USER_ERROR');
      x_msg_buf := fnd_message.get;
                 RETURN;
           END;
           IF (g_debug_mode = 'Y') THEN
              Put_Debug_Msg (l_full_path,p_debug_msg => 'completed 2nd update of po_distributions table');
           END IF;
        END IF ; -- p_document_type = 'REQ'

-- commit update transaction
        COMMIT;


-- terminate processing with error
        x_return_code := 2;
        FND_MESSAGE.set_name('IGC','IGC_PO_YEP_DOC_FAIL_FC');
        x_msg_buf := FND_MESSAGE.get;
        RETURN;

     END IF; -- l_return_code NOT IN ('S','A')

-- if successful commit updates and return success
  ELSE

     -- PO team have made changes to their code so that
     -- they dont encumber backing documents in case of the
     -- year end process. This means the functionality
     -- to create journal adjustments is no longer required
     -- Their change is in POXENC1B.pls 115.12
     -- Bidisha S, 14-Oct-2003.
     --  bug 2804025 ssmales 19-Feb-2003 added call to create_journal_adjustments
     -- Create_Journal_Adjustments(p_sobid                   => p_sobid,
     --                            p_year                    => p_year,
     --                            p_document_type           => p_document_type,
     --                            p_document_subtype        => p_document_subtype,
     --                            p_distribution_id_tbl     => l_distribution_id_tbl,
     --                            p_prev_year_end_period    => p_prev_year_end_period,
     --                            p_prev_year_end_num       => p_prev_year_end_num,
     --                            p_prev_year_end_quarter   => p_prev_year_end_quarter,
     --                            p_curr_year_start_period  => p_curr_year_start_period,
     --                            p_curr_year_start_num     => p_curr_year_start_num,
     --                            p_curr_year_start_quarter => p_curr_year_start_quarter,
     --                            x_return_code             => x_return_code
     --                            ) ;
     -- IF x_return_code = 2
     -- THEN
     --    -- Commit anyway so that the record in gl_bc_packet gets
     --    -- saved and gives us a chance to see why the funds check failed.
     --    COMMIT;
     --    FND_MESSAGE.set_name('IGC','IGC_PO_YEP_DOC_FAIL_FC');
     --    x_msg_buf := FND_MESSAGE.get;
     --    Insert_Exception_Record(p_exception_reason   =>  x_msg_buf,
     --                            p_exception_code     =>  'IGC_PO_YEP_DOC_FAIL_FC',
     --                            p_document_type      =>  p_document_type,
     --                            p_document_id        =>  p_document_id);
     --    RETURN;
     --
     -- END IF;

     COMMIT;
     x_return_code := -99;
  END IF; -- l_return_value <> 0 ...

EXCEPTION
  WHEN OTHERS THEN
     Rollback;
     IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Process_Document');
     END IF;
     IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
     END IF;
     x_return_code := 2;
  fnd_message.set_name('IGC','IGC_LOGGING_USER_ERROR');
     x_msg_buf := fnd_message.get;

END Process_Document;




--  Procedure Validate_and_Process_Doc
--  ==================================
--
--  This procedure carries out validation and processing of a single document for Year End
--  processing.  The Document is initially locked, then validated for correct status and any
--  related documents being in error.  If applicable, a call is made to validate the document's
--  distributions.  Providing all validations have been passed successfully and the processing
--  mode is Final, a call is made to carry out Year End encumbrance processing on the doc.
--
--  IN Parameters
--  -------------
--  p_sob_id                 Set of Books Id
--  p_org_id                 Org Id
--  p_year                   Year being processed
--  p_process_phase          User entered processing phase: F - Final, P - Preliminary
--  p_process_frozen         User entered choice whether to process Frozen documents: Y or N
--  p_batch_size             User entered value used to determine batch size of bulk fetches
--  p_document_type          Type of document: PO, REQ or REL
--  p_po_release_id          Id of document if a Release
--  p_po_header_id           Id of document if a PO
--  p_req_header_id          Id of document if a Requisition
--  p_prev_year_end_date     End Date of year being closed
--  p_curr_year_start_date   Start Date of current year
--  p_curr_year_start_period First period of current year
--  p_conc_request_id        Current Concurrent Request Id
--
--  OUT Parameters
--  --------------
--  x_return_code            Indicates the return status of the procedure:
--                              0 - Need to terminate processing successfully
--                              1 - Need to terminate processing with warning
--                              2 - Need to terminate processing with error
--                            -99 - Successful, continue processing
--  x_msg_buf                stores any error message encountered
--
--
-- bug 2804025 ssmales 19-Feb-2003 added new parameters
PROCEDURE Validate_And_Process_Doc(p_sobid                   IN NUMBER,
                                   p_org_id                  IN NUMBER,
                                   p_year                    IN NUMBER,
                                   p_process_phase           IN VARCHAR2,
                                   p_process_frozen          IN VARCHAR2,
                                   p_batch_size              IN NUMBER,
                                   p_document_type           IN VARCHAR2,
                                   p_po_release_id           IN NUMBER,
                                   p_po_header_id            IN NUMBER,
                                   p_req_header_id           IN NUMBER,
                                   p_prev_year_end_date      IN DATE,
                                   p_prev_year_end_period    IN VARCHAR2,
                                   p_prev_year_end_num       IN NUMBER,
                                   p_prev_year_end_quarter   IN NUMBER,
                                   p_curr_year_start_date    IN DATE,
                                   p_curr_year_start_period  IN VARCHAR2,
                                   p_curr_year_start_num     IN NUMBER,
                                   p_curr_year_start_quarter IN NUMBER,
                                   p_conc_request_id         IN NUMBER,
                                   x_return_code             OUT NOCOPY NUMBER,
                                   x_msg_buf                 OUT NOCOPY VARCHAR2
                                   ) IS

CURSOR c_get_releases(p_release_id NUMBER) IS
SELECT authorization_status auth_status,
       hold_flag,
       release_type         document_subtype,
       frozen_flag,
       cbc_accounting_date
FROM   po_releases
WHERE  po_release_id = p_release_id ;

CURSOR c_get_po_headers(p_header_id NUMBER) IS
SELECT authorization_status auth_status,
       user_hold_flag       hold_flag,
       type_lookup_code     document_subtype,
       frozen_flag,
       cbc_accounting_date
FROM   po_headers
WHERE  po_header_id = p_header_id ;

CURSOR c_get_requisitions(p_req_id NUMBER) IS
SELECT authorization_status auth_status,
       closed_code,
       type_lookup_code     document_subtype,
       cbc_accounting_date
FROM   po_requisition_headers
WHERE  requisition_header_id = p_req_id ;

-- ssmales 7-Feb-03 Added conc_request_id clause to two cursors below - bug 2791502
-- Bug  2803967,
-- Removed the clause "AND ipe.exception_code = 'IGC_PO_YEP_REL_INV_STATE'"
CURSOR c_get_release_errors(p_header_id NUMBER) IS
SELECT 'x'
FROM po_releases por,
     igc_cbc_po_process_excpts_all ipe
WHERE por.po_header_id = p_header_id
AND   ipe.document_type = 'REL'
AND   ipe.document_id = por.po_release_id
AND   ipe.conc_request_id = p_conc_request_id ;

-- Bug 2803967,
-- Removed the clause "AND ipe.exception_code = 'IGC_PO_YEP_PO_INV_STATE'"
CURSOR c_get_po_errors(p_req_id NUMBER) IS
SELECT 'x'
FROM po_line_locations poll,
     po_requisition_lines porl,
     igc_cbc_po_process_excpts_all ipe
WHERE porl.requisition_header_id = p_req_id
AND   porl.line_location_id = poll.line_location_id
AND   ipe.document_id = poll.po_header_id
AND   ipe.conc_request_id = p_conc_request_id ;

CURSOR c_get_po_future(p_req_id NUMBER) IS
SELECT 'x'
FROM po_distributions  pod,
     po_requisition_lines porl,
     po_headers poh
WHERE porl.requisition_header_id = p_req_id
AND   porl.line_location_id = pod.line_location_id
AND   pod.gl_encumbered_date >= p_curr_year_start_date
AND   pod.po_header_id = poh.po_header_id
AND   (
      NVL(poh.authorization_status,'INCOMPLETE') IN
         ('INCOMPLETE','REQUIRES REAPPROVAL','REJECTED','IN PROCESS','PRE-APPROVED')
      OR poh.user_hold_flag = 'Y'
      OR ( poh.frozen_flag = 'Y' AND p_process_frozen = 'N')
      );

CURSOR c_get_release_future(p_header_id NUMBER) IS
SELECT 'x'
FROM po_releases por,
     po_distributions pod
WHERE por.po_header_id = p_header_id
AND   por.po_release_id = pod.po_release_id
AND   pod.gl_encumbered_date >= p_curr_year_start_date
AND   (
      NVL(por.authorization_status,'INCOMPLETE') IN
         ('INCOMPLETE','REQUIRES REAPPROVAL','REJECTED','RETURNED','IN PROCESS','PRE-APPROVED')
      OR por.hold_flag = 'Y'
      OR ( por.frozen_flag = 'Y' AND p_process_frozen = 'N')
      );

-- Added for PRC.FP.J, 3173178
CURSOR c_get_bpa_po_errs (p_bpa_header_id            NUMBER) IS
SELECT 'X'
FROM   igc_cbc_po_process_excpts_all ipe,
       po_lines pol
WHERE  pol.from_header_id  = p_bpa_header_id
AND    pol.po_header_id    =  ipe.document_id
AND    ipe.document_type   = 'PO'
AND    ipe.conc_request_id = p_conc_request_id ;

CURSOR c_get_bpa_req_errs (p_bpa_header_id            NUMBER) IS
SELECT 'X'
FROM   igc_cbc_po_process_excpts_all ipe,
       po_requisition_lines prl
WHERE  prl.blanket_po_header_id    = p_bpa_header_id
AND    prl.requisition_header_id   = ipe.document_id
AND    ipe.document_type           = 'REQ'
AND    ipe.conc_request_id         = p_conc_request_id ;

l_release        c_get_releases%ROWTYPE ;
l_po             c_get_po_headers%ROWTYPE ;
l_requisition    c_get_requisitions%ROWTYPE ;
l_bpa            c_get_po_headers%ROWTYPE ;
l_return_status  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_found_error    VARCHAR2(1) ;
l_found_future   VARCHAR2(1) ;
l_msg_data       VARCHAR2(2000) := null ;
l_err_code       VARCHAR2(100) := null ;
l_return_code    NUMBER := -99 ;
l_msg_buf        VARCHAR2(2000) := null ;


l_full_path      VARCHAR2(500) := g_path||'Validate_and_Process_Doc';
BEGIN
  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg (l_full_path,p_debug_msg => '**** Validate and Process Document **** ');
  END IF;

-- Validate and Process Releases
  IF p_document_type = 'REL'
  THEN
     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => 'Validating Release '||p_po_release_id);
     END IF;

     IF p_process_phase = 'F'
     THEN
        SAVEPOINT savepoint_release ;
        -- Attempt to lock the entire document, i.e. header, shipments, distributions
        IF Lock_Documents(p_document_type   =>  p_document_type,
                          p_document_id     =>  p_po_release_id) <> FND_API.G_RET_STS_SUCCESS
        THEN
           -- if unable to lock doc, then report error and do not process this doc any further
           l_err_code := 'IGC_PO_YEP_LOCK_DOCUMENT';
           FND_MESSAGE.set_name('IGC',l_err_code);
           l_msg_data := FND_MESSAGE.get;
           Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                                   p_document_type      =>  p_document_type,
                                   p_document_id        =>  p_po_release_id);
           x_return_code := -99;
           RETURN ;
        END IF; -- Lock_Documents
     END IF ; -- p_process_phase = 'F'

-- get release details
     OPEN  c_get_releases(p_po_release_id);
     FETCH c_get_releases INTO l_release;
     CLOSE c_get_releases;

     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => 'completed get release');
     END IF;

-- check release status
     IF NVL(l_release.auth_status,'INCOMPLETE') IN ('INCOMPLETE','REJECTED','RETURNED','IN PROCESS',
                                  'PRE-APPROVED','REQUIRES REAPPROVAL')
        OR l_release.hold_flag = 'Y'
     THEN
        -- if not valid then report error and do not process this doc any further
        l_err_code := 'IGC_PO_YEP_REL_INV_STATE';
        FND_MESSAGE.set_name('IGC',l_err_code);
        IF l_release.hold_flag = 'Y' THEN
           FND_MESSAGE.set_token('REL_STATE','ON HOLD');
        ELSE
           FND_MESSAGE.set_token('REL_STATE',NVL(l_release.auth_status,'INCOMPLETE'));
        END IF;
        l_msg_data := FND_MESSAGE.get;
        Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                                p_exception_code     =>  l_err_code,
                                p_document_type      =>  p_document_type,
                                p_document_id        =>  p_po_release_id);
        IF p_process_phase = 'F'
        THEN
           ROLLBACK TO savepoint_release ;
        END IF;
        x_return_code := -99;
        RETURN;
     END IF ; -- auth_status

-- check if release has been frozen
     IF l_release.frozen_flag = 'Y'
        AND p_process_frozen = 'N'
     THEN
        -- if frozen and user requested not to process frozen docs then report error and
        -- do not process this doc any further
        l_err_code := 'IGC_PO_YEP_REL_FROZEN';
        FND_MESSAGE.set_name('IGC',l_err_code);
        l_msg_data := FND_MESSAGE.get;
        Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                                p_exception_code     =>  l_err_code,
                                p_document_type      =>  p_document_type,
                                p_document_id        =>  p_po_release_id);

        IF p_process_phase = 'F'
        THEN
           ROLLBACK TO savepoint_release ;
        END IF;
        x_return_code := -99;
        RETURN;
     END IF;    -- frozen_flag = 'Y'

-- validate the document's distributions
     l_return_status:=
        Validate_Distributions(p_batch_size         =>  p_batch_size,
                               p_document_type      =>  p_document_type,
                               p_document_subtype   =>  l_release.document_subtype,
                               p_document_id        =>  p_po_release_id
                               );

     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => 'completed Validate Distributions');
     END IF;

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS
     THEN
       -- if not valid then do not process this document any further
       IF p_process_phase = 'F'
       THEN
          ROLLBACK TO savepoint_release;
       END IF;
       x_return_code := -99;
       RETURN ;
     END IF; -- l_return_status <> fnd_api.g_ret_sts_success

-- if in Final Mode, process the document
     IF p_process_phase = 'F'
     THEN
-- bug 2804025 ssmales 19-Feb-2003 added new parameters in call below
       Process_Document(p_sobid                   =>  p_sobid,
                        p_org_id                  =>  p_org_id,
                        p_year                    =>  p_year,
                        p_process_phase           =>  p_process_phase,
                        p_document_type           =>  p_document_type,
                        p_document_subtype        =>  l_release.document_subtype,
                        p_document_id             =>  p_po_release_id,
                        p_prev_year_end_date      =>  p_prev_year_end_date,
                        p_prev_year_end_period    =>  p_prev_year_end_period,
                        p_prev_year_end_num       =>  p_prev_year_end_num,
                        p_prev_year_end_quarter   =>  p_prev_year_end_quarter,
                        p_prev_cbc_acct_date      =>  l_release.cbc_accounting_date,
                        p_curr_year_start_date    =>  p_curr_year_start_date,
                        p_curr_year_start_period  =>  p_curr_year_start_period,
                        p_curr_year_start_num     =>  p_curr_year_start_num,
                        p_curr_year_start_quarter =>  p_curr_year_start_quarter,
                        x_return_code             =>  l_return_code,
                        x_msg_buf                 =>  l_msg_buf
                        );

        IF (g_debug_mode = 'Y') THEN
           Put_Debug_Msg (l_full_path,p_debug_msg => 'completed Process Document - Release '||p_po_release_id);
        END IF;

        -- return any errors
        IF l_return_code <> -99
        THEN
           x_return_code := l_return_code;
           x_msg_buf := l_msg_buf;
           RETURN;
        END IF; -- l_return_code <> -99
     END IF;  -- p_process_phase = 'F'

-- Validate and Process PO's
  ELSIF p_document_type = 'PO'
  THEN
     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => 'Validating PO '||p_po_header_id);
     END IF;

     IF p_process_phase = 'F'
     THEN
        SAVEPOINT savepoint_po ;
        --lock document incl child records
        IF Lock_Documents(p_document_type    =>  p_document_type,
                          p_document_id      =>  p_po_header_id) <> FND_API.G_RET_STS_SUCCESS
        THEN
           -- if unable to lock doc then do not process this doc any further
           l_err_code := 'IGC_PO_YEP_LOCK_DOCUMENT';
           FND_MESSAGE.set_name('IGC',l_err_code);
           l_msg_data := FND_MESSAGE.get;
           Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                                   p_exception_code     =>  l_err_code,
                                   p_document_type      =>  p_document_type,
                                   p_document_id        =>  p_po_header_id);
           x_return_code := -99;
           RETURN ;
        END IF; -- Lock Documents
     END IF ; -- process_phase = 'F'

-- get PO document details
     OPEN  c_get_po_headers(p_po_header_id);
     FETCH c_get_po_headers INTO l_po;
     CLOSE c_get_po_headers;

     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => 'completed get po');
     END IF;

-- check document status
     IF NVL(l_po.auth_status,'INCOMPLETE') IN ('INCOMPLETE','REJECTED','IN PROCESS',
                                  'PRE-APPROVED','REQUIRES REAPPROVAL')
        OR l_po.hold_flag = 'Y'
     THEN
        -- if invalid then report error and do not process this doc any further
        l_err_code := 'IGC_PO_YEP_PO_INV_STATE';
        FND_MESSAGE.set_name('IGC',l_err_code);
        IF l_po.hold_flag = 'Y' THEN
           FND_MESSAGE.set_token('PO_STATE','ON HOLD');
        ELSE
           FND_MESSAGE.set_token('PO_STATE',NVL(l_po.auth_status,'INCOMPLETE'));
        END IF;
        l_msg_data := FND_MESSAGE.get;
        Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                                p_exception_code     =>  l_err_code,
                                p_document_type      =>  p_document_type,
                                p_document_id        =>  p_po_header_id);

        IF p_process_phase = 'F'
        THEN
           ROLLBACK TO savepoint_po ;
        END IF;
        x_return_code := -99;
        RETURN;
     END IF ; -- auth_status

-- check if po is frozen
     IF l_po.frozen_flag = 'Y'
        AND p_process_frozen = 'N'
     THEN
        -- if frozen and user requested not to process frozen docs then report error and
        -- do not process this doc any further
        l_err_code := 'IGC_PO_YEP_PO_FROZEN';
        FND_MESSAGE.set_name('IGC',l_err_code);
        l_msg_data := FND_MESSAGE.get;
        Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                                p_exception_code     =>  l_err_code,
                                p_document_type      =>  p_document_type,
                                p_document_id        =>  p_po_header_id);

        IF p_process_phase = 'F'
        THEN
           ROLLBACK TO savepoint_po ;
        END IF;
        x_return_code := -99;
        RETURN;
     END IF;    -- frozen_flag = 'Y'

-- processing for Planned PO's
     IF l_po.document_subtype = 'PLANNED'
     THEN
        -- check for any related releases already being flagged as in error
        OPEN  c_get_release_errors(p_po_header_id);
        FETCH c_get_release_errors INTO l_found_error;
        IF c_get_release_errors%FOUND
        THEN
           -- if any releases in error then report error and do not process this doc any further
           l_err_code := 'IGC_PO_YEP_REL_NOT_APP';
           FND_MESSAGE.set_name('IGC',l_err_code);
           l_msg_data := FND_MESSAGE.get;
           Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                                   p_exception_code     =>  l_err_code,
                                   p_document_type      =>  p_document_type,
                                   p_document_id        =>  p_po_header_id);

           IF p_process_phase = 'F'
           THEN
              ROLLBACK TO savepoint_po ;
           END IF;
           CLOSE c_get_release_errors;
           x_return_code := -99;
           RETURN;
        END IF; -- c_get_release_errors%FOUND
        CLOSE c_get_release_errors;
        IF (g_debug_mode = 'Y') THEN
           Put_Debug_Msg (l_full_path,p_debug_msg => 'completed get release errors');
        END IF;

        -- check for any related releases with gl encumbered dates in future years
        OPEN  c_get_release_future(p_po_header_id);
        FETCH c_get_release_future INTO l_found_future;
        IF c_get_release_future%FOUND
        THEN
           -- if any releases in future then report error and do not process this doc any further
           l_err_code := 'IGC_PO_YEP_PO_REL_FUTURE';
           FND_MESSAGE.set_name('IGC',l_err_code);
           l_msg_data := FND_MESSAGE.get;
           Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                                   p_exception_code     =>  l_err_code,
                                   p_document_type      =>  p_document_type,
                                   p_document_id        =>  p_po_header_id);

           IF p_process_phase = 'F'
           THEN
              ROLLBACK TO savepoint_po ;
           END IF;
           CLOSE c_get_release_future;
           x_return_code := -99;
           RETURN;
        END IF; -- c_get_release_future%FOUND
        CLOSE c_get_release_future;
        IF (g_debug_mode = 'Y') THEN
           Put_Debug_Msg (l_full_path,p_debug_msg => 'completed get release future');
        END IF;
     END IF; -- document_subtype = 'PLANNED'

-- Validate PO's distributions
     l_return_status :=
        Validate_Distributions(p_batch_size        =>  p_batch_size,
                               p_document_type     =>  p_document_type,
                               p_document_subtype  =>  l_po.document_subtype,
                               p_document_id       =>  p_po_header_id
                               );
     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => 'completed Validate Distributions');
     END IF;
     IF l_return_status <> FND_API.G_RET_STS_SUCCESS
     THEN
       -- If distributions invalid report error and do not process this doc any further
       IF p_process_phase = 'F'
       THEN
          ROLLBACK TO savepoint_po ;
       END IF;
       x_return_code := -99;
       RETURN ;
     END IF; -- l_return_status <> fnd_api.g_ret_sts_success

-- IF in Final Mode process the document
     IF p_process_phase = 'F'
     THEN
-- bug 2804025 ssmales 19-Feb-2003 added new parameters in call below
       Process_Document(p_sobid                   =>  p_sobid,
                        p_org_id                  =>  p_org_id,
                        p_year                    =>  p_year,
                        p_process_phase           =>  p_process_phase,
                        p_document_type           =>  p_document_type,
                        p_document_subtype        =>  l_po.document_subtype,
                        p_document_id             =>  p_po_header_id,
                        p_prev_year_end_date      =>  p_prev_year_end_date,
                        p_prev_year_end_period    =>  p_prev_year_end_period,
                        p_prev_year_end_num       =>  p_prev_year_end_num,
                        p_prev_year_end_quarter   =>  p_prev_year_end_quarter,
                        p_prev_cbc_acct_date      =>  l_po.cbc_accounting_date,
                        p_curr_year_start_date    =>  p_curr_year_start_date,
                        p_curr_year_start_period  =>  p_curr_year_start_period,
                        p_curr_year_start_num     =>  p_curr_year_start_num,
                        p_curr_year_start_quarter =>  p_curr_year_start_quarter,
                        x_return_code             =>  l_return_code,
                        x_msg_buf                 =>  l_msg_buf
                        );

        IF (g_debug_mode = 'Y') THEN
           Put_Debug_Msg (l_full_path,p_debug_msg => 'completed Process Document');
        END IF;

        -- return any errors
        IF l_return_code <> -99
        THEN
           x_return_code := l_return_code;
           x_msg_buf := l_msg_buf;
           RETURN;
        END IF;

     END IF;  -- p_process_phase = 'F'

-- Validate and Process Requisitions
  ELSIF p_document_type = 'REQ'
  THEN
     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => 'Validating Requisition '||p_req_header_id);
     END IF;

     IF p_process_phase = 'F'
     THEN
        SAVEPOINT savepoint_requisition ;
        --lock document incl child records
        IF Lock_Documents(p_document_type     =>  p_document_type,
                          p_document_id       =>  p_req_header_id) <> FND_API.G_RET_STS_SUCCESS
        THEN
           -- if unable to lock doc then report error and do not process this doc any further
           l_err_code := 'IGC_PO_YEP_LOCK_DOCUMENT';
           FND_MESSAGE.set_name('IGC',l_err_code);
           l_msg_data := FND_MESSAGE.get;
           Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                                   p_exception_code     =>  l_err_code,
                                   p_document_type      =>  p_document_type,
                                   p_document_id        =>  p_req_header_id);
           -- do not process this doc any further
           x_return_code := -99;
           RETURN ;
        END IF; -- Lock_Documents
     END IF ; -- p_process_phase = 'F'

-- Get requisition details
     OPEN  c_get_requisitions(p_req_header_id);
     FETCH c_get_requisitions INTO l_requisition;
     CLOSE c_get_requisitions;

     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => 'completed get requisitions');
     END IF;

-- Check requisition status
     IF NVL(l_requisition.auth_status,'INCOMPLETE') IN ('INCOMPLETE','REJECTED','RETURNED','IN PROCESS',
                                  'PRE-APPROVED','REQUIRES REAPPROVAL')
        OR l_requisition.closed_code = 'ON HOLD'
     THEN
        -- if invalid status then report error and do not process this doc any further
        l_err_code := 'IGC_PO_YEP_REQ_INV_STATE';
        FND_MESSAGE.set_name('IGC',l_err_code);
        IF l_requisition.closed_code = 'ON HOLD' THEN
           FND_MESSAGE.set_token('REQ_STATE','ON HOLD');
        ELSE
           FND_MESSAGE.set_token('REQ_STATE',NVL(l_requisition.auth_status,'INCOMPLETE'));
        END IF;
        l_msg_data := FND_MESSAGE.get;
        Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                                p_exception_code     =>  l_err_code,
                                p_document_type      =>  p_document_type,
                                p_document_id        =>  p_req_header_id);

        IF p_process_phase = 'F'
        THEN
           ROLLBACK TO savepoint_requisition ;
        END IF;
        x_return_code := -99;
        RETURN;
     END IF ;  -- auth_status

-- Check if related PO's have already been flagged as being in error
     OPEN  c_get_po_errors(p_req_header_id);
     FETCH c_get_po_errors INTO l_found_error;
     IF c_get_po_errors%FOUND
     THEN
        -- If any PO's in error then report and do not process this doc any further
        l_err_code := 'IGC_PO_YEP_REQ_PO_NAPPR';
        FND_MESSAGE.set_name('IGC',l_err_code);
        l_msg_data := FND_MESSAGE.get;
        Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                                p_exception_code     =>  l_err_code,
                                p_document_type      =>  p_document_type,
                                p_document_id        =>  p_req_header_id);

        IF p_process_phase = 'F'
        THEN
           ROLLBACK TO savepoint_requisition ;
        END IF;
        CLOSE c_get_po_errors;
        x_return_code := -99;
        RETURN;
     END IF; -- c_get_po_errors%FOUND
     CLOSE c_get_po_errors;
     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => 'completed get po errors ');
     END IF;

-- Check if there are any related PO's with GL dates after the year being rolled forward
     OPEN  c_get_po_future(p_req_header_id);
     FETCH c_get_po_future INTO l_found_future;
     IF c_get_po_future%FOUND
     THEN
        -- If any related PO's with GL dates in future years, then do not process this doc any further
        l_err_code := 'IGC_PO_YEP_REQ_PO_FUTURE';
        FND_MESSAGE.set_name('IGC',l_err_code);
        l_msg_data := FND_MESSAGE.get;
        Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                                p_exception_code     =>  l_err_code,
                                p_document_type      =>  p_document_type,
                                p_document_id        =>  p_req_header_id);

        IF p_process_phase = 'F'
        THEN
           ROLLBACK TO savepoint_requisition ;
        END IF;
        CLOSE c_get_po_future;
        x_return_code := -99;
        RETURN;
     END IF; -- c_get_po_future%FOUND
     CLOSE c_get_po_future;
     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => 'completed get po future ');
     END IF;

-- Validate Requisition's distributions
     l_return_status :=
        Validate_Distributions(p_batch_size       =>  p_batch_size,
                               p_document_type    =>  p_document_type,
                               p_document_subtype =>  l_requisition.document_subtype,
                               p_document_id      =>  p_req_header_id
                               );
     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => 'completed validate distributions');
     END IF;

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS
     THEN
       -- If distributions invalid then report error and do not process this doc any further
       IF p_process_phase = 'F'
       THEN
          ROLLBACK TO savepoint_requisition ;
       END IF;
       x_return_code := -99;
       RETURN ;
     END IF; -- l_return_status <> fnd_api.g_ret_sts_success


-- if in Final Mode then process the requisition
     IF p_process_phase = 'F'
     THEN
-- bug 2804025 ssmales 19-Feb-2003 added new parameters in call below
       Process_Document(p_sobid                   =>  p_sobid,
                        p_org_id                  =>  p_org_id,
                        p_year                    =>  p_year,
                        p_process_phase           =>  p_process_phase,
                        p_document_type           =>  p_document_type,
                        p_document_subtype        =>  l_requisition.document_subtype,
                        p_document_id             =>  p_req_header_id,
                        p_prev_year_end_date      =>  p_prev_year_end_date,
                        p_prev_year_end_period    =>  p_prev_year_end_period,
                        p_prev_year_end_num       =>  p_prev_year_end_num,
                        p_prev_year_end_quarter   =>  p_prev_year_end_quarter,
                        p_prev_cbc_acct_date      =>  l_requisition.cbc_accounting_date,
                        p_curr_year_start_date    =>  p_curr_year_start_date,
                        p_curr_year_start_period  =>  p_curr_year_start_period,
                        p_curr_year_start_num     =>  p_curr_year_start_num,
                        p_curr_year_start_quarter =>  p_curr_year_start_quarter,
                        x_return_code             =>  l_return_code,
                        x_msg_buf                 =>  l_msg_buf
                        );

        IF (g_debug_mode = 'Y') THEN
           Put_Debug_Msg (l_full_path,p_debug_msg => 'completed Process Document');
        END IF;

        -- return any errors
        IF l_return_code <> -99
        THEN
           x_return_code := l_return_code;
           x_msg_buf := l_msg_buf;
           RETURN;
        END IF;

     END IF;  -- p_process_phase = 'F'

  END IF;  -- p_document_type = 'REQ'

  -- Validate and Process BPAs
  -- Added for 3173178, PRC.FP.J
  IF p_document_type = 'PA'
  THEN
     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => 'Validating Blanket Agreements '||p_po_header_id);
     END IF;

     IF p_process_phase = 'F'
     THEN
        SAVEPOINT savepoint_BPA ;
        --lock document incl child records
        IF Lock_Documents(p_document_type     =>  p_document_type,
                          p_document_id       =>  p_po_header_id) <> FND_API.G_RET_STS_SUCCESS
        THEN
           -- if unable to lock doc then report error and do not process this doc any further
           l_err_code := 'IGC_PO_YEP_LOCK_DOCUMENT';
           FND_MESSAGE.set_name('IGC',l_err_code);
           l_msg_data := FND_MESSAGE.get;
           Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                                   p_exception_code     =>  l_err_code,
                                   p_document_type      =>  p_document_type,
                                   p_document_id        =>  p_po_header_id);
           -- do not process this doc any further
           x_return_code := -99;
           RETURN ;
        END IF; -- Lock_Documents
     END IF ; -- p_process_phase = 'F'

-- Get BPA  details
     OPEN  c_get_po_headers(p_po_header_id);
     FETCH c_get_po_headers INTO l_bpa;
     CLOSE c_get_po_headers;

     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => 'completed get blanket agreements');
     END IF;

-- Check blanket agreements status
     IF NVL(l_bpa.auth_status,'INCOMPLETE') IN ('INCOMPLETE','REJECTED','IN PROCESS',
                                  'PRE-APPROVED','REQUIRES REAPPROVAL')
        OR l_bpa.hold_flag = 'Y'
     THEN
        -- if invalid status then report error and do not process this doc any further
        l_err_code := 'IGC_PO_YEP_BPA_INV_STATE';
        FND_MESSAGE.set_name('IGC',l_err_code);
        IF l_bpa.hold_flag = 'Y'
        THEN
           FND_MESSAGE.set_token('BPA_STATE','ON HOLD');
        ELSE
           FND_MESSAGE.set_token('BPA_STATE',NVL(l_bpa.auth_status,'INCOMPLETE'));
        END IF;
        l_msg_data := FND_MESSAGE.get;
        Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                                p_exception_code     =>  l_err_code,
                                p_document_type      =>  p_document_type,
                                p_document_id        =>  p_po_header_id);

        IF p_process_phase = 'F'
        THEN
           ROLLBACK TO savepoint_bpa ;
        END IF;
        x_return_code := -99;
        RETURN;
     END IF ;  -- auth_status

     -- check if BPA is frozen
     IF l_bpa.frozen_flag = 'Y'
        AND p_process_frozen = 'N'
     THEN
        -- if frozen and user requested not to process frozen docs then report error and
        -- do not process this doc any further
        l_err_code := 'IGC_PO_YEP_PO_FROZEN';
        FND_MESSAGE.set_name('IGC',l_err_code);
        l_msg_data := FND_MESSAGE.get;
        Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                                p_exception_code     =>  l_err_code,
                                p_document_type      =>  p_document_type,
                                p_document_id        =>  p_po_header_id);

        IF p_process_phase = 'F'
        THEN
           ROLLBACK TO savepoint_bpa ;
        END IF;
        x_return_code := -99;
        RETURN;
     END IF;    -- frozen_flag = 'Y'

     -- Check if related PO's have already been flagged as being in error
     OPEN  c_get_bpa_po_errs(p_po_header_id);
     FETCH c_get_bpa_po_errs INTO l_found_error;
     IF c_get_bpa_po_errs%FOUND
     THEN
        -- If any PO's in error then report
        -- and do not process this doc any further
        l_err_code := 'IGC_PO_YEP_BPA_PO_NAPPR';
        FND_MESSAGE.set_name('IGC',l_err_code);
        l_msg_data := FND_MESSAGE.get;
        Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                                p_exception_code     =>  l_err_code,
                                p_document_type      =>  p_document_type,
                                p_document_id        =>  p_po_header_id);

        IF p_process_phase = 'F'
        THEN
           ROLLBACK TO savepoint_bpa ;
        END IF;
        CLOSE c_get_bpa_po_errs;
        x_return_code := -99;
        RETURN;
     END IF; -- c_get_bpa_po_errs%FOUND
     CLOSE c_get_bpa_po_errs;
     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => 'completed get BPA PO errors ');
     END IF;

     -- check for any related Blanket releases already being flagged as in error
     OPEN  c_get_release_errors(p_po_header_id);
     FETCH c_get_release_errors INTO l_found_error;
     IF c_get_release_errors%FOUND
     THEN
        -- if any releases in error then report error and do not process this doc any further
        l_err_code := 'IGC_PO_YEP_REL_NOT_APP';
        FND_MESSAGE.set_name('IGC',l_err_code);
        l_msg_data := FND_MESSAGE.get;
        Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                   p_exception_code     =>  l_err_code,
                   p_document_type      =>  p_document_type,
                       p_document_id        =>  p_po_header_id);

        IF p_process_phase = 'F'
        THEN
           ROLLBACK TO savepoint_bpa ;
        END IF;
        CLOSE c_get_release_errors;
        x_return_code := -99;
        RETURN;
     END IF; -- c_get_release_errors%FOUND

     CLOSE c_get_release_errors;

     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => 'completed get release errors for BPA');
     END IF;

     -- Check if any requisitions sourced from the BPA  have already been
     -- flagged as being in error
     OPEN  c_get_bpa_req_errs(p_po_header_id);
     FETCH c_get_bpa_req_errs INTO l_found_error;
     IF c_get_bpa_req_errs%FOUND
     THEN
        -- If any REQs in error then report
        -- and do not process this doc any further
        l_err_code := 'IGC_PO_YEP_BPA_REQ_NAPPR';
        FND_MESSAGE.set_name('IGC',l_err_code);
        l_msg_data := FND_MESSAGE.get;
        Insert_Exception_Record(p_exception_reason   =>  l_msg_data,
                                p_exception_code     =>  l_err_code,
                                p_document_type      =>  p_document_type,
                                p_document_id        =>  p_po_header_id);

        IF p_process_phase = 'F'
        THEN
           ROLLBACK TO savepoint_bpa ;
        END IF;
        CLOSE c_get_bpa_req_errs;
        x_return_code := -99;
        RETURN;
     END IF; -- c_get_req_errors%FOUND
     CLOSE c_get_bpa_req_errs;
     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => 'completed get BPA REQ errors ');
     END IF;

     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => 'BPA distributions do not need validations');
     END IF;

-- if in Final Mode then process the BPA
     IF p_process_phase = 'F'
     THEN
       Process_Document(p_sobid                   =>  p_sobid,
                        p_org_id                  =>  p_org_id,
                        p_year                    =>  p_year,
                        p_process_phase           =>  p_process_phase,
                        p_document_type           =>  p_document_type,
                        p_document_subtype        =>  l_bpa.document_subtype,
                        p_document_id             =>  p_po_header_id,
                        p_prev_year_end_date      =>  p_prev_year_end_date,
                        p_prev_year_end_period    =>  p_prev_year_end_period,
                        p_prev_year_end_num       =>  p_prev_year_end_num,
                        p_prev_year_end_quarter   =>  p_prev_year_end_quarter,
                        p_prev_cbc_acct_date      =>  l_bpa.cbc_accounting_date,
                        p_curr_year_start_date    =>  p_curr_year_start_date,
                        p_curr_year_start_period  =>  p_curr_year_start_period,
                        p_curr_year_start_num     =>  p_curr_year_start_num,
                        p_curr_year_start_quarter =>  p_curr_year_start_quarter,
                        x_return_code             =>  l_return_code,
                        x_msg_buf                 =>  l_msg_buf
                        );

        IF (g_debug_mode = 'Y') THEN
           Put_Debug_Msg (l_full_path,p_debug_msg => 'completed Process Document for BPA');
        END IF;

        -- return any errors
        IF l_return_code <> -99
        THEN
           x_return_code := l_return_code;
           x_msg_buf := l_msg_buf;
           RETURN;
        END IF;

     END IF;  -- p_process_phase = 'F'

  END IF;  -- p_document_type = 'BPA'
  x_return_code := -99;

EXCEPTION
   WHEN OTHERS THEN
      rollback;
      IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Validate_And_Process_Doc');
      END IF;
     IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
     END IF;
      x_return_code := 2 ;
      fnd_message.set_name('IGC','IGC_LOGGIN_USER_ERROR');
      x_msg_buf := fnd_message.get;

END Validate_And_Process_Doc;




--  Procedure Year_End_Main
--  =======================
--
--  This is the main procedure of the PO/CBC Year End Process.
--  This process, to be run at Year End, carries forward encumbrances to the next fiscal year.
--  Encumbrances are carried forward in both the Standard and Commitment Budgets at a transactional
--  level for Requisitions, whilst encumbrances for PO's are carried forward only in the Standard
--  Budget.  Funds reservation in the Standard Budget is carried out in Forced Mode.
--
--  IN Parameters
--  -------------
--  p_sob_id             Set of Books Id
--  p_org_id             Org Id
--  p_process_phase      User entered processing phase: F - Final, P - Preliminary
--  p_year               User entered Year being closed
--  p_process_frozen     User entered choice whether to process Frozen documents: Y or N
--  p_trunc_exception    User entered choice to truncate the exception table: Y or N
--  p_batch_size         User entered value used to determine batch size of bulk fetches
--
--  OUT Parameters
--  --------------
--  errbuf               Standard Concurrent Processing Error Buffer
--  retcode              Standard Concurrent Processing Return Code
--
--
PROCEDURE  Year_End_Main(errbuf            OUT NOCOPY VARCHAR2,
                         retcode           OUT NOCOPY VARCHAR2,
/* Bug No : 6341012. MOAC uptake. SOB_ID, ORG_ID are no more retrieved from profile values in R12 */
--                         p_sobid           IN NUMBER,
--                         p_org_id          IN NUMBER,
                         p_process_phase   IN VARCHAR2,
                         p_year            IN NUMBER,
                         p_process_frozen  IN VARCHAR2,
                         p_trunc_exception IN VARCHAR2,
                         p_batch_size      IN NUMBER
) IS

-- Bug No : 6341012. MOAC uptake. Local variables for SOB_ID,SOB_NAME,ORG_ID
l_sob_id    NUMBER;
l_sob_name  VARCHAR2(30);
l_org_id    NUMBER;


CURSOR c_get_recs(c_p_doc_type VARCHAR2) IS
SELECT DISTINCT tmp.po_release_id,
       tmp.po_header_id,
       tmp.req_header_id
FROM   igc_cbc_po_process_gt tmp
WHERE  document_type = c_p_doc_type ;

l_document_type           VARCHAR2(3);
l_po_enc_on               BOOLEAN := FALSE;
l_req_enc_on              BOOLEAN := FALSE;
l_prev_year_start_date    DATE;
l_prev_year_end_date      DATE;
l_curr_year_start_date    DATE;
l_curr_year_start_period  gl_periods.period_name%TYPE ;
l_conc_request_id         NUMBER := FND_GLOBAL.conc_request_id ;


-- bug 2804025 ssmales 19-Feb-2003 added following local variables
l_prev_year_end_period    gl_periods.period_name%TYPE ;
l_prev_year_end_num       gl_periods.period_num%TYPE ;
l_prev_year_end_quarter   gl_periods.quarter_num%TYPE ;
l_curr_year_start_num     gl_periods.period_num%TYPE ;
l_curr_year_start_quarter gl_periods.quarter_num%TYPE ;



TYPE document_rec_type IS RECORD
(po_release_id    igc_tbl_number,
 po_header_id     igc_tbl_number,
 req_header_id    igc_tbl_number);

l_document_id_rec   document_rec_type;
l_return_code       NUMBER := -99 ;
l_msg_buf           VARCHAR2(2000) := null ;


l_full_path      VARCHAR2(500) := g_path||'Year_End_Main';
BEGIN
  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg (l_full_path,p_debug_msg => '**** Year End Main ****');
  END IF;

  /* Bug No : 6341012. MOAC Uptake. SOB_ID,ORG_ID values are retrieved
      and in following code p_sobid is changed to l_sob_id  and p_org_id is changed l_org_id */
  l_org_id := MO_GLOBAL.get_current_org_id;
  MO_UTILS.get_ledger_info(l_org_id,l_sob_id,l_sob_name);

--  Validate Budgetary Control Parameters
  Validate_BC_Params(p_sobid             =>  l_sob_id,
                     p_org_id            =>  l_org_id,
                     p_process_phase     =>  p_process_phase,
                     p_year              =>  p_year,
                     p_trunc_exception   =>  p_trunc_exception,
                     x_po_enc_on         =>  l_po_enc_on,
                     x_req_enc_on        =>  l_req_enc_on,
                     x_return_code       =>  l_return_code,
                     x_msg_buf           =>  l_msg_buf
                     );
  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg (l_full_path,p_debug_msg => '**** Year End Main - completed Validate BC Params ****');
  END IF;

-- If not successful return, then terminate processing
  IF l_return_code <> -99
  THEN
     Log_Error(p_sobid            =>  l_sob_id,
               p_org_id           =>  l_org_id,
               p_conc_request_id  =>  l_conc_request_id,
               p_process_phase    =>  p_process_phase) ;

     Execute_Exceptions_Report(p_sobid            =>  l_sob_id,
                               p_org_id           =>  l_org_id,
                               p_conc_request_id  =>  l_conc_request_id,
                               p_process_phase    =>  p_process_phase,
                               p_year             =>  p_year
                               );

     retcode := l_return_code;
     errbuf := l_msg_buf;
     return;
  END IF; -- l_return_code <> -99

-- Validate Period Statuses

-- bug 2804025 added params for prev_year_end_period/num/quarter and curr_year_start_num/quarter
  IF NOT
  Validate_Period_Status(p_sobid                   =>  l_sob_id,
                         p_org_id                  =>  l_org_id,
                         p_process_phase           =>  p_process_phase,
                         p_year                    =>  p_year,
                         x_prev_year_start_date    =>  l_prev_year_start_date,
                         x_prev_year_end_date      =>  l_prev_year_end_date,
                         x_prev_year_end_period    =>  l_prev_year_end_period,
                         x_prev_year_end_num       =>  l_prev_year_end_num,
                         x_prev_year_end_quarter   =>  l_prev_year_end_quarter,
                         x_curr_year_start_date    =>  l_curr_year_start_date,
                         x_curr_year_start_period  =>  l_curr_year_start_period,
                         x_curr_year_start_num     =>  l_curr_year_start_num,
                         x_curr_year_start_quarter =>  l_curr_year_start_quarter
                         )
  THEN
     -- Validation failed so terminate processing
     Log_Error(p_sobid            =>  l_sob_id,
               p_org_id           =>  l_org_id,
               p_conc_request_id  =>  l_conc_request_id,
               p_process_phase    =>  p_process_phase) ;

     Execute_Exceptions_Report(p_sobid            =>  l_sob_id,
                               p_org_id           =>  l_org_id,
                               p_conc_request_id  =>  l_conc_request_id,
                               p_process_phase    =>  p_process_phase,
                               p_year             =>  p_year
                               );
     retcode := 0;
     errbuf := null;
     return;
  END IF; -- NOT Validate_Period_Status

  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg (l_full_path,p_debug_msg => '**** Year End Main - Completed Validate Period Status ****');
  END IF;

-- IF purchasing encumbrance is enabled then get details of PO's and Release to be processed
-- fetching these into a temporary table
  IF l_po_enc_on
  THEN
     Fetch_PO_And_Releases(p_org_id                =>  l_org_id,
                           p_prev_year_start_date  =>  l_prev_year_start_date,
                           p_prev_year_end_date    =>  l_prev_year_end_date
                          );

     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => '**** Year End Main - completed Fetch PO and Releases ****');
     END IF;
  END IF; -- l_po_enc_on

-- process one document type at a time
  -- Modified the for loop to include BPAs as the 4th document type to be
  -- processed. - 3173178
  FOR l_doctype_index IN 1 .. 4
  LOOP
     IF l_doctype_index = 1 AND l_po_enc_on
     THEN
        l_document_type := 'REL' ;
     ELSIF l_doctype_index = 2 AND l_po_enc_on
     THEN
        l_document_type := 'PO' ;
     ELSIF l_doctype_index = 3 AND l_req_enc_on
     THEN
        l_document_type := 'REQ' ;
        -- IF requisition encumbrance is enabled then get details of Requisitions to be processed
        -- fetching these into the temporary table.
        -- The reason req's are fetched at this stage is to reduce the number of rows in the temporary table
        Fetch_Requisitions(p_org_id                =>  l_org_id,
                           p_prev_year_start_date  =>  l_prev_year_start_date,
                           p_prev_year_end_date    =>  l_prev_year_end_date
                           );
     ELSIF l_doctype_index = 4 AND l_req_enc_on
     THEN
        l_document_type := 'PA' ;
        -- IF requisition encumbrance is enabled then get details of BPAs to be processed
        -- fetching these into the temporary table.
        Fetch_BPAs (p_org_id                =>  l_org_id,
                    p_prev_year_start_date  =>  l_prev_year_start_date,
                    p_prev_year_end_date    =>  l_prev_year_end_date
                           );
     END IF ;    -- l_doctype_index = 1 and l_po_enc_on

     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => 'Processing Type: '||NVL(l_document_type,'NONE'));
     END IF;

-- retrieve and process records from temporary table
     OPEN c_get_recs(l_document_type) ;

     LOOP

        -- fetch records in batches determined by user entered parameter
        FETCH c_get_recs BULK COLLECT INTO l_document_id_rec.po_release_id,
                                           l_document_id_rec.po_header_id,
                                           l_document_id_rec.req_header_id
        LIMIT p_batch_size ;

        IF (g_debug_mode = 'Y') THEN
            Put_Debug_Msg (l_full_path,p_debug_msg => 'Fetched latest batch of records');
            Put_Debug_Msg (l_full_path,p_debug_msg => 'total records retrieved '||l_document_id_rec.po_header_id.LAST);
        END IF;

--        EXIT WHEN c_get_recs%NOTFOUND ;   <= removed as found not to work !!!
        EXIT WHEN l_document_id_rec.po_header_id.FIRST IS NULL;

        -- loop through fetched records, processing each in turn
        FOR l_doc_index IN l_document_id_rec.po_release_id.FIRST .. l_document_id_rec.po_release_id.LAST
        LOOP

           IF (g_debug_mode = 'Y') THEN
              Put_Debug_Msg (l_full_path,p_debug_msg => 'loop index:'||l_doc_index  );
              Put_Debug_Msg (l_full_path,p_debug_msg => 'po header:'||l_document_id_rec.po_header_id(l_doc_index)  );
              Put_Debug_Msg (l_full_path,p_debug_msg => 'po_release:'||l_document_id_rec.po_release_id(l_doc_index)  );
              Put_Debug_Msg (l_full_path,p_debug_msg => 'req_header:'||l_document_id_rec.req_header_id(l_doc_index)  );
           END IF;

           Validate_And_Process_Doc(p_sobid                   => l_sob_id,
                                    p_org_id                  => l_org_id,
                                    p_year                    => p_year,
                                    p_process_phase           => p_process_phase,
                                    p_process_frozen          => p_process_frozen,
                                    p_batch_size              => p_batch_size,
                                    p_document_type           => l_document_type,
                                    p_po_release_id           => l_document_id_rec.po_release_id(l_doc_index),
                                    p_po_header_id            => l_document_id_rec.po_header_id(l_doc_index),
                                    p_req_header_id           => l_document_id_rec.req_header_id(l_doc_index),
                                    p_prev_year_end_date      => l_prev_year_end_date,
                                    p_prev_year_end_period    => l_prev_year_end_period,
                                    p_prev_year_end_num       => l_prev_year_end_num,
                                    p_prev_year_end_quarter   => l_prev_year_end_quarter,
                                    p_curr_year_start_date    => l_curr_year_start_date,
                                    p_curr_year_start_period  => l_curr_year_start_period,
                                    p_curr_year_start_num     => l_curr_year_start_num,
                                    p_curr_year_start_quarter => l_curr_year_start_quarter,
                                    p_conc_request_id         => l_conc_request_id,
                                    x_return_code             => l_return_code,
                                    x_msg_buf                 => l_msg_buf) ;

           IF (g_debug_mode = 'Y') THEN
              Put_Debug_Msg (l_full_path,p_debug_msg => '**** Year End Main - completed Validate and Process Doc ****');
           END IF;

           -- if not successful return then terminate processing
           IF l_return_code <> -99
           THEN
              Log_Error(p_sobid            =>  l_sob_id,
                        p_org_id           =>  l_org_id,
                        p_conc_request_id  =>  l_conc_request_id,
                        p_process_phase    =>  p_process_phase) ;

              Execute_Exceptions_Report(p_sobid            =>  l_sob_id,
                                        p_org_id           =>  l_org_id,
                                        p_conc_request_id  =>  l_conc_request_id,
                                        p_process_phase    =>  p_process_phase,
                                        p_year             =>  p_year
                                        );
              retcode := l_return_code;
              errbuf := l_msg_buf ;
              RETURN;
           END IF; -- l_return_code <> -99


        END LOOP ; -- end loop of fetched records for this batch

        IF (g_debug_mode = 'Y') THEN
           Put_Debug_Msg (l_full_path,p_debug_msg => '**** Year End Main - completed processing current batch of records  ***');
        END IF;

        -- log any errors for the batch just processed
        Log_Error(p_sobid            =>  l_sob_id,
                  p_org_id           =>  l_org_id,
                  p_conc_request_id  =>  l_conc_request_id,
                  p_process_phase    =>  p_process_phase) ;

-- ssmales 01-May-2003 bug 2932056 added line below to cater for 8.1.7 database, which does not
--                                 reinitialize array following no records found fetch
        l_document_id_rec.po_header_id.DELETE;

     END LOOP ; -- end loop of fetching and processing records in batches

     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,p_debug_msg => '**** Year End Main - completed processing '
                                     ||l_document_type||' ****');
     END IF;

     CLOSE c_get_recs ;

  END LOOP ; -- end loop of document type
  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg (l_full_path,p_debug_msg => '**** Year End Main - completed all docs ****');
  END IF;


-- terminate processing

  Execute_Exceptions_Report(p_sobid            =>  l_sob_id,
                            p_org_id           =>  l_org_id,
                            p_conc_request_id  =>  l_conc_request_id,
                            p_process_phase    =>  p_process_phase,
                            p_year             =>  p_year
                            );

  retcode := 0;
  errbuf := null;

EXCEPTION
   WHEN OTHERS THEN
     IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Year_End_Main');
     END IF;
     IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
     END IF;
     APP_EXCEPTION.Raise_Exception;
      retcode := 2 ;
      fnd_message.set_name('IGC','IGC_LOGGING_USER_ERROR');
  errbuf := fnd_message.get;


END Year_End_Main ;


END IGC_CBC_PO_YEAR_END_PKG;

/
