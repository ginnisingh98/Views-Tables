--------------------------------------------------------
--  DDL for Package Body IGC_CBC_PA_BC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CBC_PA_BC_PKG" AS
/* $Header: IGCBPBCB.pls 120.8.12000000.4 2007/12/07 10:06:16 mbremkum ship $ */



G_PKG_NAME             CONSTANT VARCHAR2(30) := 'IGC_CBC_PA_BC_PKG';

g_debug		       VARCHAR2(1);
g_prod                 VARCHAR2(3)           := 'IGC';
g_sub_comp             VARCHAR2(3)           := 'CPA';
g_profile_name         VARCHAR2(255)         := 'IGC_DEBUG_LOG_DIRECTORY';
g_mode                 VARCHAR2(1);

--g_debug_mode  VARCHAR2(1) := NVL(FND_PROFILE.VALUE('IGC_DEBUG_ENABLED'),'N');
g_debug_mode        VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

--Variables for ATG Central logging
g_debug_level          NUMBER	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
g_state_level          NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
g_proc_level           NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
g_event_level          NUMBER	:=	FND_LOG.LEVEL_EVENT;
g_excep_level          NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
g_error_level          NUMBER	:=	FND_LOG.LEVEL_ERROR;
g_unexp_level          NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
g_path                 VARCHAR2(255) := 'IGC.PLSQL.IGCBPBCB.IGC_CBC_PA_BC_PKG.';
l_full_path            VARCHAR2(255);

PROCEDURE Put_Debug_Msg (
   p_path      IN VARCHAR2,
   p_debug_msg IN VARCHAR2
);

PROCEDURE message_token(
   tokname         IN VARCHAR2,
   tokval          IN VARCHAR2
);

PROCEDURE add_message(
   appname           IN VARCHAR2,
   msgname           IN VARCHAR2
);


FUNCTION Get_H_Code (
   p_header_id     IN NUMBER  ,
   p_mode          IN VARCHAR2,
   p_actual_flag   IN VARCHAR2,
   p_doc_type      IN VARCHAR2
) RETURN VARCHAR2;

FUNCTION Validate_Interface (
   p_header_id     IN NUMBER  ,
   p_mode          IN VARCHAR2,
   p_actual_flag   IN VARCHAR2,
   p_doc_type      IN VARCHAR2
) RETURN BOOLEAN ;

FUNCTION Check_PA_BC (
   p_project_id IN NUMBER
) RETURN VARCHAR2;

-- ssmales 31/01/02 bug 2201905 - added p_packet_id to function below
FUNCTION Unreserve_PA (
   p_sobid         IN NUMBER,
   p_header_id     IN NUMBER  ,
   p_mode          IN VARCHAR2,
   p_actual_flag   IN VARCHAR2,
   p_doc_type      IN VARCHAR2,
   p_pa_reserved   IN BOOLEAN ,
   p_cbc_reserved  IN BOOLEAN,
   p_packet_id     IN NUMBER

)RETURN VARCHAR2;

FUNCTION Check_PA (
   p_sobid         IN NUMBER,
   p_header_id     IN NUMBER  ,
   p_mode          IN VARCHAR2,
   p_actual_flag   IN VARCHAR2,
   p_doc_type      IN VARCHAR2,
   p_pa_return_code OUT NOCOPY VARCHAR2

)RETURN BOOLEAN;

/*Added for Bug 6672778 - Start*/

FUNCTION Get_Batch_Result_Code (
   p_header_id     IN NUMBER,
   p_mode	   IN VARCHAR2
)RETURN VARCHAR2;

/*Added for Bug 6672778 - End*/

/* ------------------------------------------------------------------------- */
/*                                                                           */
/*  PA Funds Check API for CC                                                */
/*                                                                           */
/*  This routine returns TRUE if successful; otherwise, it returns FALSE     */
/*                                                                           */
/*  In case of failure, this routine will populate the global Message Stack  */
/*  using FND_MESSAGE. The calling routine will retrieve the message from    */
/*  the Stack                                                                */
/*                                                                           */
/*  External Packages which are being invoked include :                      */
/*                                                                           */
/*            FND_*                                                          */
/*                                                                           */
/*  GL Tables which are being used include :                                 */
/*                                                                           */
/*            GL_*                                                           */
/*                                                                           */
/*  AOL Tables which are being used include :                                */
/*                                                                           */
/*            FND_*                                                          */
/*                                                                           */
/*  Return status two characters. First one for CBC, second for SBC          */
/*                'S' Success,                                               */
/*                'A' Advisory,                                              */
/*                'F' Failure                                                */
/*                'T' Fatal                                                  */
/*                'N' No records                                             */
/* ------------------------------------------------------------------------- */


FUNCTION IGCPAFCK(
   p_sobid             IN  NUMBER,
   p_header_id         IN  NUMBER,
   p_mode              IN  VARCHAR2,
   p_actual_flag       IN  VARCHAR2,
   p_doc_type          IN  VARCHAR2,
   p_ret_status        OUT NOCOPY VARCHAR2,
   p_batch_result_code OUT NOCOPY VARCHAR2,
   p_debug             IN  VARCHAR2:=FND_API.G_FALSE,
   p_conc_proc         IN  VARCHAR2:=FND_API.G_FALSE
   /*Commented Packet ID for SLA Uptake*/
--   p_packet_id         IN  NUMBER
) RETURN BOOLEAN IS

   l_api_name            CONSTANT VARCHAR2(30)   := 'IGCPAFCK';
   l_return_status       VARCHAR2(1);
   l_fc_return_status    VARCHAR2(2);
   l_batch_result_code   VARCHAR2(3);
   l_res                 VARCHAR2(2);
   l_pa_bc_required      BOOLEAN := FALSE;
   l_pa_reserved         BOOLEAN := FALSE;
   l_cbc_reserved        BOOLEAN := FALSE;
   l_fc_boolean_status   BOOLEAN := FALSE;
   l_flag                VARCHAR2(1);
   l_pa_return_code      VARCHAR2(1);
   l_pa_overall_code     VARCHAR2(1);
   l_ret_status          VARCHAR2(2);
   p_packet_id		 NUMBER;
   /* Cursor select all projects from CC account lines table */
   CURSOR c_acct_info IS
     SELECT DISTINCT project_id
       FROM igc_cc_acct_lines
      WHERE cc_acct_line_id IN
        (SELECT cc_acct_line_id
           FROM igc_cc_interface_v a
          WHERE cc_header_id     = p_header_id
            AND budget_dest_flag = 'C'
            AND actual_flag      = p_actual_flag
            AND document_type    = p_doc_type )
        AND project_id IS NOT NULL ;

   l_full_path            VARCHAR2(255);

BEGIN

   l_full_path := g_path || 'IGCPAFCK';
   /*Added for SLA Uptake Bug No 6341012 - Temporary*/
   p_packet_id	:= NULL;

   -- Standard Start of API savepoint

   SAVEPOINT     IGCPAFCK;

   -- Initialize message list

   FND_MSG_PUB.initialize;

   --Initialize global variables

--   IGC_MSGS_PKG.g_debug_mode := FND_API.TO_BOOLEAN(p_debug);

   -- debug information

--   IF (NOT IGC_MSGS_PKG.g_debug_mode) OR (upper(fnd_profile.value('IGC_DEBUG_ENABLED')) ='Y')  THEN
--      IGC_MSGS_PKG.g_debug_mode:=TRUE;
--   END IF;
   /*IF (g_debug_mode <> 'Y') AND (p_debug = FND_API.G_TRUE)
   IF(g_debug_mode <> 'Y')
   THEN
      g_debug_mode := 'Y';
   END IF;*/

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, substr('**************************************************************************************************',1,70));
      Put_Debug_Msg(l_full_path, substr('*********Starting PA CBC  Funds Checker '||to_char(sysdate,'DD-MON-YY:MI:SS')||' *********************',1,70));
      Put_Debug_Msg(l_full_path, substr('**************************************************************************************************',1,70));
      Put_Debug_Msg(l_full_path, 'Parameters SOB:' || p_sobid ||' Mode: ' || p_mode || ' HeaderID ' ||p_header_id);
   END IF;

   IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'Getting project info');
   END IF;
   g_debug := p_debug;
   g_mode := p_mode;

   FOR c_acct_info_rec IN c_acct_info LOOP

     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg(l_full_path, 'Checking project setup '||c_acct_info_rec.project_id);
     END IF;

     --Call PA API and check setup
     l_flag := Check_PA_BC(c_acct_info_rec.project_id);

     IF FND_API.TO_BOOLEAN(l_flag) THEN
       IF (g_debug_mode = 'Y') THEN
          Put_Debug_Msg(l_full_path, 'Project Bc enabled');
       END IF;
       l_pa_bc_required:=TRUE;

       UPDATE igc_cc_interface_v v1
          SET v1.pa_flag = 'Y',
              v1.result_code_source = 'P',
              v1.period_name =
              ( SELECT min(per.period_name)
                      FROM gl_period_statuses per
                     WHERE per.application_id   = 101
                           AND per.adjustment_period_flag='N'
                           AND per.set_of_books_id  = p_sobid
                           AND v1.cc_transaction_date
                       BETWEEN per.start_date
                           AND per.end_date
               )
        WHERE cc_header_id     = p_header_id
          AND budget_dest_flag = 'C'
          AND actual_flag      = p_actual_flag
          AND document_type    = p_doc_type
          AND cc_acct_line_id IN
          (SELECT cc_acct_line_id
             FROM igc_cc_acct_lines
            WHERE cc_header_id = p_header_id
              AND project_id = c_acct_info_rec.project_id
              AND project_id IS  NOT NULL);

     ELSE
       IF (g_debug_mode = 'Y') THEN
          Put_Debug_Msg(l_full_path, 'Project Bc disabled');
       END IF;
     END IF;


   END LOOP; --End of interface update

   IF l_pa_bc_required THEN

       IF (g_debug_mode = 'Y') THEN
          Put_Debug_Msg(l_full_path, 'Calling PA FC');
       END IF;

       --Call PA FC

       l_fc_boolean_status := Check_PA (p_sobid             => p_sobid,
                                        p_header_id         => p_header_id,
                                        p_mode              => p_mode,
                                        p_actual_flag       => p_actual_flag,
                                        p_doc_type          => p_doc_type,
                                        p_pa_return_code    => l_pa_return_code );


       IF (g_debug_mode = 'Y') THEN
          Put_Debug_Msg(l_full_path, 'PA FC result is '|| l_pa_return_code);
       END IF;

       l_pa_overall_code := l_pa_return_code;

       IF  l_pa_return_code IN ('A','S')  AND p_mode IN ('F','R','U') THEN

          l_pa_reserved := TRUE;

          IF NOT Validate_Interface(p_header_id,p_mode,p_actual_flag,p_doc_type) THEN

             IF (g_debug_mode = 'Y') THEN
                Put_Debug_Msg(l_full_path, 'Post PA validation failed');
             END IF;

-- ssmales 31/01/02 bug 2201905 - added p_packet_id to call below
             l_res := Unreserve_PA(p_sobid,p_header_id,p_mode,p_actual_flag,p_doc_type,l_pa_reserved,l_cbc_reserved,p_packet_id);

             IF (g_debug_mode = 'Y') THEN
                Put_Debug_Msg(l_full_path, 'Returning '||l_res);
             END IF;

             p_ret_status := l_res;

             RETURN FALSE;

          END IF;


       ELSIF p_mode IN ('F','R','U') AND l_pa_return_code NOT IN ('A','S') THEN

          IF (g_debug_mode = 'Y') THEN
             Put_Debug_Msg(l_full_path, 'Calculatig H-code and returning to the user');
          END IF;

          p_batch_result_code := Get_H_Code(p_header_id  ,
                                            p_mode       ,
                                            p_actual_flag,
                                            p_doc_type);

          p_ret_status       := l_pa_return_code||'N';

          IF(l_pa_return_code ='T') THEN
             RETURN FALSE;
          END IF;

          RETURN TRUE;

       ELSIF p_mode = 'C' AND l_pa_return_code IN ('A','S')  THEN

          IF NOT Validate_Interface(p_header_id,p_mode,p_actual_flag,p_doc_type) THEN

             IF (g_debug_mode = 'Y') THEN
                Put_Debug_Msg(l_full_path, 'Post PA validation failed');
             END IF;

             p_ret_status  := 'TN';

             IF (g_debug_mode = 'Y') THEN
                Put_Debug_Msg(l_full_path, 'Returning '||'TN');
             END IF;

             RETURN FALSE;

          END IF;

       ELSIF l_pa_return_code ='T' OR NOT l_fc_boolean_status  THEN

             IF (g_debug_mode = 'Y') THEN
                Put_Debug_Msg(l_full_path, 'PA returned fatal exception - exiting ');
             END IF;

             p_ret_status  := 'TN';

             IF (g_debug_mode = 'Y') THEN
                Put_Debug_Msg(l_full_path, 'Returning '||'TN');
             END IF;

             RETURN FALSE;

       END IF;

   END IF; --End of PA BC call

   IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'Calling CBC FC');
   END IF;

   l_fc_boolean_status := IGC_CBC_FUNDS_CHECKER.IGCFCK(p_sobid             => p_sobid,
                                                       p_header_id         => p_header_id,
                                                       p_mode              => p_mode,
                                                       p_actual_flag       => p_actual_flag,
                                                       p_doc_type          => p_doc_type,
                                                       p_ret_status        => l_fc_return_status,
                                                       p_batch_result_code => l_batch_result_code,
                                                       p_debug             => p_debug,
                                                       p_conc_proc         => p_conc_proc
--                                                       p_packet_id         => p_packet_id
							);
   IF l_fc_boolean_status
      AND substr(l_fc_return_status,1,1) IN ('S','A','N')
      AND substr(l_fc_return_status,2,1) IN ('S','A','N')
      AND p_mode IN ('F','R','U') THEN

      IF (g_debug_mode = 'Y') THEN
         Put_Debug_Msg(l_full_path, 'Successfull execution');
      END IF;

      l_cbc_reserved := TRUE;

      IF l_pa_reserved  THEN

         IF (g_debug_mode = 'Y') THEN
            Put_Debug_Msg(l_full_path, 'Calling PA confirm reservation');
         END IF;

      -- Do PA confirm reservation
         l_fc_boolean_status := Check_PA (p_sobid             => p_sobid,
                                          p_header_id         => p_header_id,
                                          p_mode              => 'N',
                                          p_actual_flag       => p_actual_flag,
                                          p_doc_type          => p_doc_type,
                                          p_pa_return_code    => l_pa_return_code );

	/*Added for Bug 6672778*/
	l_batch_result_code := Get_Batch_Result_Code (p_header_id, p_mode);

         IF l_pa_return_code <> 'S'  THEN

            IF (g_debug_mode = 'Y') THEN
               Put_Debug_Msg(l_full_path, 'Failure during PA confirm reservation, unreserving..');
            END IF;

            l_pa_reserved := FALSE;

-- ssmales 31/01/02 bug 2201905 - added p_packet_id to call below
            l_res := Unreserve_PA(p_sobid,p_header_id,p_mode,p_actual_flag,p_doc_type,l_pa_reserved,l_cbc_reserved,p_packet_id);

            p_ret_status := l_res;

            p_batch_result_code := NULL;

            RETURN FALSE;

         END IF;
      END IF;

   ELSIF  p_mode IN ('F','R','U')  THEN --FC failed

      IF (g_debug_mode = 'Y') THEN
         Put_Debug_Msg(l_full_path, 'FC failed status: '||l_fc_return_status);
      END IF;

      IF l_pa_reserved THEN

-- ssmales 31/01/02 bug 2201905 - adde p_packet_id to call below
         l_res := Unreserve_PA(p_sobid,p_header_id,p_mode,p_actual_flag,p_doc_type,l_pa_reserved,l_cbc_reserved,p_packet_id);

           IF substr(l_res,1,1) = 'U' THEN

              p_ret_status := 'U'||substr(l_fc_return_status,2,1);

              p_batch_result_code :=NULL;

              RETURN FALSE;

           END IF;

       END IF;

   ELSE  --Mode check - just call confirmation, assign the result code.

-- ssmales 29/01/02 bug 2201905 - not actually part of this bug, but code below was wrong.
--                  should only call Check_PA if l_pa_bc_required is True, so If statement added

      IF l_pa_bc_required THEN
         l_fc_boolean_status := Check_PA (p_sobid          => p_sobid,
                                          p_header_id      => p_header_id,
                                          p_mode           => 'N',
                                          p_actual_flag    => p_actual_flag,
                                          p_doc_type       => p_doc_type,
                                          p_pa_return_code => l_pa_return_code );

	/*Added for Bug 6672778*/
	l_batch_result_code := Get_Batch_Result_Code (p_header_id, p_mode);

      END IF ;

   END IF;

   IF l_pa_overall_code IS NOT NULL THEN

      IF l_pa_overall_code = 'A' AND substr(l_fc_return_status,1,1) = 'S' THEN

        l_ret_status := 'A'||substr(l_fc_return_status,2,1) ;

      ELSIF l_pa_overall_code = 'F' AND substr(l_fc_return_status,1,1) IN ('S','A') THEN

        l_ret_status := 'F'||substr(l_fc_return_status,2,1) ;

      ELSE

         l_ret_status := l_fc_return_status;

      END IF;

   ELSE
      l_ret_status := l_fc_return_status;
   END IF;

   IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'PA status '||l_pa_overall_code);
      Put_Debug_Msg(l_full_path, 'CBC status '||l_fc_return_status);
   END IF;

   p_ret_status :=    l_ret_status;

   IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'Returning result'||l_batch_result_code||' '||l_ret_status);
   END IF;

   p_batch_result_code := l_batch_result_code;

   RETURN TRUE;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg(l_full_path, 'Execution error occured');
     END IF;

-- ssmales 31/01/02 bug 2201905 - added p_packet_id to call below
     l_res := Unreserve_PA(p_sobid,p_header_id,p_mode,p_actual_flag,p_doc_type,l_pa_reserved,l_cbc_reserved,p_packet_id);

     p_ret_status := l_res;

     p_batch_result_code := NULL;

     IF (g_excep_level >=  g_debug_level ) THEN
         FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
     END IF;

     RETURN(FALSE);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg(l_full_path, 'Unexpected error occured');
     END IF;

-- ssmales 31/01/02 bug 2201905 - added p_packet_id to call below
     l_res := Unreserve_PA(p_sobid,p_header_id,p_mode,p_actual_flag,p_doc_type,l_pa_reserved,l_cbc_reserved,p_packet_id);

     p_ret_status := l_res;

     p_batch_result_code := NULL;

     IF (g_excep_level >=  g_debug_level ) THEN
         FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR Exception Raised');
     END IF;

     RETURN(FALSE);

   WHEN OTHERS THEN

     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg(l_full_path, 'Unknown error occured');
      END IF;

     IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
     END IF;

-- ssmales 31/01/02 bug 2201905 - added p_packet_id to call below
     l_res := Unreserve_PA(p_sobid,p_header_id,p_mode,p_actual_flag,p_doc_type,l_pa_reserved,l_cbc_reserved,p_packet_id);

     p_ret_status := l_res;

     p_batch_result_code := NULL;

     IF ( g_unexp_level >= g_debug_level ) THEN
         FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
         FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
         FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
         FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
     END IF;

     RETURN (FALSE);

END IGCPAFCK;

/*Code change for Bug 6672778 - Start*/

FUNCTION Get_Batch_Result_Code (
   p_header_id     IN NUMBER,
   p_mode	   IN VARCHAR2
) RETURN VARCHAR2 IS

l_h_code VARCHAR2(3);
l_sev_rank NUMBER;
l_min_sev_rank NUMBER;
l_full_path VARCHAR2(255);

CURSOR c_result_code IS
SELECT distinct cbc_result_code, cc_header_id
FROM igc_cc_interface
WHERE cc_header_id = p_header_id;

BEGIN

l_min_sev_rank := 9999;
l_full_path := g_path || 'Get_Batch_Result_Code';

IF ( g_unexp_level >= g_debug_level ) THEN
   Put_Debug_Msg(l_full_path, 'Header ID: ' || p_header_id || ' Mode: ' || p_mode);
END IF;

FOR l_result_code IN c_result_code LOOP

	SELECT distinct severity_rank INTO l_sev_rank
	FROM igc_cc_result_code_ranks
	WHERE funds_checker_code = l_result_code.cbc_result_code;

	IF (l_min_sev_rank > l_sev_rank) THEN
		l_min_sev_rank := l_sev_rank;
	END IF;

END LOOP;

IF ( g_unexp_level >= g_debug_level ) THEN
   Put_Debug_Msg(l_full_path, 'Minimum Severity Rank: ' || l_min_sev_rank);
END IF;

SELECT distinct popup_messg_code INTO l_h_code
FROM igc_cc_result_code_ranks
WHERE severity_rank = l_min_sev_rank
AND action = decode(p_mode,'F','R',p_mode);

IF ( g_unexp_level >= g_debug_level ) THEN
   Put_Debug_Msg(l_full_path, 'Pop Up Message Code: ' || l_h_code);
END IF;

RETURN l_h_code;

END Get_Batch_Result_Code;

/*Code change for Bug 6672778 - End*/

PROCEDURE Put_Debug_Msg (
   p_path      IN VARCHAR2,
   p_debug_msg IN VARCHAR2
) IS

-- Constants :

   /*l_Return_Status    VARCHAR2(1);*/
   l_api_name         CONSTANT VARCHAR2(30) := 'Put_Debug_Msg';

BEGIN

   IF(g_state_level >= g_debug_level) THEN
        FND_LOG.STRING(g_state_level, p_path, p_debug_msg);
   END IF;

   RETURN;

-- --------------------------------------------------------------------
-- Exception handler section for the Put_Debug_Msg procedure.
-- --------------------------------------------------------------------
EXCEPTION

   /*WHEN FND_API.G_EXC_ERROR THEN
       RETURN;*/

   WHEN OTHERS THEN
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       NULL;
       RETURN;
END Put_Debug_Msg;

/****************************************************************************/

-- Add Token and Value to the Message Token array

PROCEDURE message_token(
   tokname IN VARCHAR2,
   tokval  IN VARCHAR2
) IS

BEGIN

  IGC_MSGS_PKG.message_token (p_tokname => tokname,
                              p_tokval  => tokval);

END message_token;


/****************************************************************************/

-- Sets the Message Stack

PROCEDURE add_message(
   appname IN VARCHAR2,
   msgname IN VARCHAR2
) IS

i  BINARY_INTEGER;

BEGIN

   IGC_MSGS_PKG.add_message (p_appname => appname,
                             p_msgname => msgname);

END add_message;

/* Procedure unreserves PA and CBC
   returns two caracters one for CBC(PA) and the second for SBC
   T if successfully unreserved and U if not */

-- ssmales 31/01/02 bug 2201905 added p_packet_id to function below
FUNCTION Unreserve_PA (
   p_sobid         IN NUMBER,
   p_header_id     IN NUMBER  ,
   p_mode          IN VARCHAR2,
   p_actual_flag   IN VARCHAR2,
   p_doc_type      IN VARCHAR2,
   p_pa_reserved   IN BOOLEAN ,
   p_cbc_reserved  IN BOOLEAN,
   p_packet_id     IN NUMBER

)
 RETURN VARCHAR2 IS

   l_fc_return_status    VARCHAR2(2);
   l_cbc_return_status   VARCHAR2(2);
   l_batch_result_code   VARCHAR2(3);
   l_pa_return_status    VARCHAR2(2);
   l_fc_boolean_status   BOOLEAN;
   l_return_code         VARCHAR2(1);
   l_full_path            VARCHAR2(255);
BEGIN

  l_full_path := g_path || 'Unreserve_PA';

  l_fc_return_status := 'TN';

  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg(l_full_path, 'Unreservation module called');
  END IF;

  l_pa_return_status := 'T';

  IF p_pa_reserved THEN

  IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'PA unreservation reqired');
  END IF;

      l_return_code := 'F';

      PA_FUNDS_CONTROL_PKG.PA_GL_CBC_CONFIRMATION(
        P_calling_module => 'CBC' ,
        P_packet_id => NULL,
        P_mode => p_mode,
        P_reference1 => 'CC',
        P_reference2 => p_header_id,
        P_gl_cbc_return_code => l_return_code,
        x_return_status  => l_pa_return_status);

     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg(l_full_path, 'Return status is:'||l_pa_return_status);
     END IF;

     IF l_pa_return_status <> 'T' THEN
        IF (g_debug_mode = 'Y') THEN
           Put_Debug_Msg(l_full_path, 'Successfully unreserved, status'||l_pa_return_status);
        END IF;
        l_pa_return_status := 'T';
     ELSE
        --Unreservation failed - return U.
        IF (g_debug_mode = 'Y') THEN
           Put_Debug_Msg(l_full_path, 'Failed status'||l_pa_return_status);
        END IF;
        l_pa_return_status := 'U';
        l_fc_return_status := 'UN';
     END IF;
  END IF;


  IF p_cbc_reserved THEN

    IF (g_debug_mode = 'Y') THEN
       Put_Debug_Msg(l_full_path, 'CBC unreservation reqired');
    END IF;

    l_fc_boolean_status := IGC_CBC_FUNDS_CHECKER.IGCFCK(p_sobid             => p_sobid,
                                                        p_header_id         => p_header_id,
                                                        p_mode              => 'U',
                                                        p_actual_flag       => p_actual_flag,
                                                        p_doc_type          => p_doc_type,
                                                        p_ret_status        => l_fc_return_status,
                                                        p_batch_result_code => l_batch_result_code,
                                                        p_debug             => g_debug,
                                                        p_conc_proc         => 'F'
--                                                        p_packet_id         => p_packet_id
							);



     IF substr(l_fc_return_status,2,1) = 'S' THEN  --Need to convert S SBC message to T

       l_fc_return_status := substr(l_fc_return_status,1,1)||'T';

     END IF;

     IF l_fc_boolean_status THEN

        IF (g_debug_mode = 'Y') THEN
           Put_Debug_Msg(l_full_path, 'Successfully unreserved, CBC FC return status '||l_fc_return_status);
        END IF;

        l_fc_return_status := l_pa_return_status||substr(l_fc_return_status,2,1);

     ELSE
        --Unreservation failed - return U.
        IF (g_debug_mode = 'Y') THEN
           Put_Debug_Msg(l_full_path, 'Failed CBC FC return status '||l_fc_return_status);
        END IF;

        IF l_pa_return_status = 'U' THEN  --Asssign U as CBC result anyway

           l_fc_return_status := 'U'||substr(l_fc_return_status,2,1);

        END IF;

     END IF;

  END IF;

  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg(l_full_path, 'Overall unreservation status '||l_fc_return_status);
  END IF;

  RETURN l_fc_return_status;

END Unreserve_PA;


/* This functon calculates the H-code based on PA provided result codes */
FUNCTION Get_H_Code  (
   p_header_id     IN NUMBER  ,
   p_mode          IN VARCHAR2,
   p_actual_flag   IN VARCHAR2,
   p_doc_type      IN VARCHAR2
)RETURN VARCHAR2 IS

  l_h_code  VARCHAR2(3);
  l_rank    NUMBER;
  l_full_path            VARCHAR2(255);
BEGIN

   l_full_path := g_path || 'Get_H_Code';

   IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'Caclulating H-code');
   END IF;

   SELECT min(IGC_CBC_FUNDS_CHECKER.Get_Rank(cbc_result_code))
     INTO l_rank
     FROM igc_cc_interface_v
    WHERE cc_header_id     = p_header_id
      AND budget_dest_flag = 'C'
      AND actual_flag      = p_actual_flag
      AND document_type    = p_doc_type
      AND cbc_result_code IS NOT NULL;

   l_h_code :=   IGC_CBC_FUNDS_CHECKER.Get_Batch_Result_Code(p_mode,l_rank);

   IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'H-code found: '||l_h_code );
   END IF;

   RETURN l_h_code;
EXCEPTION
   WHEN NO_DATA_FOUND THEN --No result codes in the table after PA.Probably Unexpected error raised

   IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'No records with result code, H-code is null');
   END IF;

   IF ( g_unexp_level >= g_debug_level ) THEN
      FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
      FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
      FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
      FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
   END IF;

   RETURN '';

END Get_H_Code;


/* This procedure validates Interface table and checks the following information to be correct:
   The PA -related lines have a result code. The lines cretaed by PA for budget
   liquidation have the same CCID as the target lines    */
FUNCTION Validate_Interface  (
   p_header_id     IN NUMBER  ,
   p_mode          IN VARCHAR2,
   p_actual_flag   IN VARCHAR2,
   p_doc_type      IN VARCHAR2
)
RETURN BOOLEAN IS

--This cursor returns lines which have the same cc_acct_line_id but different code combinations from CC and PA.
   CURSOR c_int IS
     SELECT count(DISTINCT CODE_COMBINATION_ID)
       FROM igc_cc_interface_v  a
      WHERE cc_header_id         = p_header_id
            AND budget_dest_flag = 'C'
            AND actual_flag      = p_actual_flag
            AND document_type    = p_doc_type
            AND pa_flag ='Y'
     HAVING count(DISTINCT CODE_COMBINATION_ID)  > 1
     GROUP BY cc_acct_line_id;

   l_result_count  NUMBER := 0;
   l_full_path            VARCHAR2(255);

BEGIN

    l_full_path := g_path || 'Validate_Interface';

    OPEN c_int;
    FETCH c_int
    INTO l_result_count;


   IF c_int%FOUND THEN
      CLOSE c_int;
      add_message ('IGC', 'IGC_CBC_CCID_NOT_MATCH'); -- There are records with not matched CCID
      RETURN FALSE;
   END IF;

   CLOSE c_int;

   RETURN TRUE;

END Validate_Interface;


FUNCTION Check_PA_BC (
   p_project_id IN NUMBER
) RETURN VARCHAR2 IS
   l_full_path            VARCHAR2(255);
BEGIN

  l_full_path := g_path || 'Check_PA_BC';

  IF PA_BUDGET_FUND_PKG.Is_bdgt_intg_enabled (p_project_id =>  p_project_id,
                                               p_mode       => 'C' )
  THEN
     RETURN FND_API.G_TRUE;
  END IF;

  RETURN FND_API.G_FALSE;

END Check_PA_BC;

FUNCTION Check_PA (
   p_sobid         IN NUMBER,
   p_header_id     IN NUMBER  ,
   p_mode          IN VARCHAR2,
   p_actual_flag   IN VARCHAR2,
   p_doc_type      IN VARCHAR2,
   p_pa_return_code OUT NOCOPY VARCHAR2

)RETURN BOOLEAN IS
l_pa_return_code  VARCHAR2(1) := 'S';
l_cbc_return_code VARCHAR2(1) := 'S';
l_return_status   VARCHAR2(1);
l_return_code     VARCHAR2(1);
l_stage           VARCHAR2(2000);
l_err_msg         VARCHAR2(2000);
l_err_count       NUMBER(10);
l_full_path            VARCHAR2(255);
BEGIN

   l_full_path := g_path || 'Check_PA';

   IF p_mode ='N' THEN
      IF (g_debug_mode = 'Y') THEN
         Put_Debug_Msg(l_full_path, 'Calling PA FC in confirmation mode');
      END IF;

      l_return_code := 'S';

      PA_FUNDS_CONTROL_PKG.PA_GL_CBC_CONFIRMATION(
        P_calling_module => 'CBC' ,
        P_packet_id => NULL,
        P_mode => g_mode,
        P_reference1 => 'CC',
        P_reference2 => p_header_id,
        p_gl_cbc_return_code => l_return_code,
        x_return_status => l_return_status);

        IF (g_debug_mode = 'Y') THEN
           Put_Debug_Msg(l_full_path, 'Return status is:'||l_return_status);
        END IF;

        p_pa_return_code := l_return_status;

    IF (l_return_status <> 'S' ) THEN
       RETURN FALSE;
    ELSE
       RETURN TRUE;
    END IF;

   ELSE
     --Mode not confirmation
     -- bug 2689651 : Added call in force mode: Start
     IF p_mode = 'F' THEN

        PA_FUNDS_CONTROL_PKG.PA_GL_CBC_CONFIRMATION(
           P_calling_module => 'CBC' ,
           P_packet_id => NULL,
           P_mode => p_mode,
           P_reference1 => 'CC',
           P_reference2 => p_header_id,
           p_gl_cbc_return_code => l_return_code,
           x_return_status => l_return_status);

         p_pa_return_code := l_return_status;

         IF (l_return_status <> 'S' ) THEN
           RETURN FALSE;
         END IF;
       END IF;
     -- bug 2689651 : Added call in force mode: end

       IF PA_FUNDS_CONTROL_PKG.PA_FUNDS_CHECK(
         P_calling_module => 'CBC' ,
         P_set_of_book_id => p_sobid ,
         P_packet_id => NULL,
         P_mode => p_mode,
         P_partial_flag => 'N' ,
         P_reference1 => 'CC',
         P_reference2 => p_header_id,
         X_return_status => l_pa_return_code ,
         X_error_msg    =>l_err_msg ,
         X_error_stage => l_stage )
        THEN

       p_pa_return_code := l_pa_return_code;

       IF (g_debug_mode = 'Y') THEN
          Put_Debug_Msg(l_full_path, 'PA return status is:'||l_pa_return_code||' message '||l_err_msg||' stage '||l_stage);
       END IF;

       ELSE
         IF (g_debug_mode = 'Y') THEN
            Put_Debug_Msg(l_full_path, 'PA FC returned FALSE, return status is:'||l_pa_return_code||' message '||l_err_msg||' stage '||l_stage);
         END IF;

         p_pa_return_code := 'T';

         RETURN FALSE;
       END IF;

  END IF;

   RETURN TRUE;

END;

END IGC_CBC_PA_BC_PKG;


/
