--------------------------------------------------------
--  DDL for Package Body WSM_LOG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSM_LOG_PVT" AS
/* $Header: WSMVLOGB.pls 120.4 2006/09/08 00:52:05 nlal noship $ */

g_log_level_procedure   NUMBER := FND_LOG.LEVEL_PROCEDURE;
g_log_level_unexpected  NUMBER := FND_LOG.LEVEL_UNEXPECTED;

G_MSG_LVL_UNEXP_ERROR   NUMBER := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR     ;
G_MSG_LVL_ERROR         NUMBER := FND_MSG_PUB.G_MSG_LVL_ERROR           ;
G_MSG_LVL_SUCCESS       NUMBER := FND_MSG_PUB.G_MSG_LVL_SUCCESS         ;
G_MSG_LVL_DEBUG_HIGH    NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH      ;
G_MSG_LVL_DEBUG_MEDIUM  NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM    ;
G_MSG_LVL_DEBUG_LOW     NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW       ;

-- Log the parameters...
PROCEDURE LogProcParams ( p_module_name       IN     varchar2  ,
                          p_param_tbl         IN     WSM_log_PVT.param_tbl_type,
                          p_fnd_log_level     IN     number
                        )

IS

BEGIN
        -- ( This code is correct : Unforutnately due to
        -- inefficient GSCC warning/error check, forced to refer to the package public variable
        --IF (g_log_level_procedure >= p_fnd_log_level) and fnd_log.test(g_log_level_procedure , p_module_name) then
        IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE and fnd_log.test(g_log_level_procedure , p_module_name)
        THEN
                FND_LOG.String(LOG_LEVEL   =>  FND_LOG.LEVEL_PROCEDURE,
                                MESSAGE     =>   'Parameters for [--> ' || p_module_name || ' <---]',
                               MODULE      =>  p_module_name);

                for i in 1..p_param_tbl.count loop
                       --IF  p_fnd_log_level <= FND_LOG.LEVEL_PROCEDURE
                       -- ( This code is correct : Unforutnately due to
                       -- inefficient GSCC warning/error check, forced to refer to the package public variable

                       IF  FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE  then
                           FND_LOG.String(
                                       LOG_LEVEL   =>   FND_LOG.LEVEL_PROCEDURE,
                                       MESSAGE     =>  '[ ' || p_param_tbl(i).paramName || ' ] : ' || p_param_tbl(i).paramValue,
                                       MODULE      =>  p_module_name);
                       END IF;
                end loop;
        ELSE
                -- Procedure logging not enabled.. return
                return;
        END IF;
END LogProcParams;

-- Log a message..
PROCEDURE LogMessage  ( p_module_name       IN     varchar2                         ,
                        p_msg_name          IN     varchar2             DEFAULT NULL,
                        p_msg_appl_name     IN     VARCHAR2             DEFAULT NULL,
                        p_msg_text          IN     varchar2             DEFAULT NULL,
                        p_stmt_num          IN     NUMBER               DEFAULT NULL,
                        p_msg_tokens        IN     token_rec_tbl        ,
                        -- pass 1 to p_wsm_warning if the message is a a warning message
                        p_wsm_warning       IN     NUMBER               DEFAULT NULL,
                        -- p_fnd_msg_level has default NULL b'cos we dont do statement level logging into FND_MSG_PUB
                        p_fnd_msg_level     IN     NUMBER               DEFAULT NULL,
                        p_fnd_log_level     IN     NUMBER                           ,
                        p_run_log_level     IN     NUMBER
                       )

IS
        l_index         NUMBER;
        l_message       VARCHAR2(2000);
        l_msg_type      NUMBER;
BEGIN
        -- If p_msg_text is NOT NULL then it is a statement level logging message which will be logged into
        -- FND_LOG_MESSAGES alone...

        IF (p_msg_text IS NOT NULL) AND
	   (p_fnd_log_level < FND_LOG.LEVEL_EXCEPTION)
	   -- ST : Added this clause as we need the error messages from the old procedures that don't follow
	   -- Logging framework also have their error statements logged similar to the error messages from the
	   -- new procedures...
	THEN

                -- ( This code is correct : Unforutnately due to
                -- inefficient GSCC warning/error check, forced to refer to the package public variable
                --IF (p_fnd_log_level >= p_run_log_level) and fnd_log.test(p_fnd_log_level , p_module_name) then
                IF  FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT  and fnd_log.test(p_fnd_log_level , p_module_name)
                THEN

                        FND_LOG.String(
                                       LOG_LEVEL   =>  FND_LOG.LEVEL_STATEMENT,
                                       MESSAGE     =>  '[ ' || to_char(sysdate,'DD-MON-YYYY HH24:MI:SS') || ' ] : '
                                                        || p_module_name || ' : ' || p_stmt_num
                                                        || ' : ' || p_msg_text,
                                       MODULE      =>  p_module_name);
                END IF;
                RETURN;
        END IF;


        IF (p_msg_name IS NOT NULL OR (p_msg_text IS NOT NULL AND p_fnd_log_level >= FND_LOG.LEVEL_EXCEPTION))
	   -- ST : Added the above check on p_msg_text for bug 5233265 as the older procedures will return a error_message to a
	   -- newer API that invokes it rather than a msg_count and msg_txt combination...
	   -- Hence those error messages also have to be logged..
	   AND
           (FND_MSG_PUB.Check_Msg_Level(p_fnd_msg_level) OR
            (p_fnd_log_level >= p_run_log_level and FND_LOG.TEST(p_run_log_level,p_module_name))
           )
        THEN
		-- ST : Added the IF clause for bug 5233265 --
                IF p_msg_name IS NOT NULL THEN
			-- This to log the message in WIE...
			FND_MESSAGE.SET_NAME(p_msg_appl_name,p_msg_name);
			IF p_msg_tokens.count > 0  THEN
				for l_cnt in p_msg_tokens.first..p_msg_tokens.last loop
					FND_MESSAGE.SET_TOKEN(p_msg_tokens(l_cnt).TokenName,p_msg_tokens(l_cnt).TokenValue);
				end loop;
			END IF;
			l_message := FND_MESSAGE.GET;
		ELSE
			-- The messages is already present...
			l_message := p_msg_text;
		END IF;

                -- Indicates that this is a translated message...
                -- The below is not required as no autologging...
                -- FND_MESSAGE.SET_MODULE(p_module_name);

                IF FND_MSG_PUB.Check_Msg_Level(p_fnd_msg_level) THEN

                        IF (p_wsm_warning IS NULL OR p_wsm_warning<>1) THEN /* Bugfix 5491121 don't put warnings on msg stack */

				IF p_msg_name IS NOT NULL THEN
					FND_MESSAGE.SET_NAME(p_msg_appl_name,p_msg_name);
					IF p_msg_tokens.count > 0  THEN
						for l_cnt in p_msg_tokens.first..p_msg_tokens.last loop
							FND_MESSAGE.SET_TOKEN(p_msg_tokens(l_cnt).TokenName,p_msg_tokens(l_cnt).TokenValue);
						end loop;
					END IF;
					-- add to FND_MSG_PUB
				ELSE
					-- Added for bug 5233265
					fnd_message.set_name('WSM','WSM_ERROR_TEXT');
					fnd_message.set_token('ERROR_TEXT',l_message);
				END IF;
				-- ST : Fix for bug 5233265 end --

                        	FND_MSG_PUB.add;

                        END IF;

			IF (g_write_to_WIE = 1) THEN

                            IF p_wsm_warning IS NOT NULL THEN
                                l_msg_type := 2; --warning
                            ELSE
                                l_msg_type := 1; --error
                            END IF;

                            l_index := g_error_msg_tbl.count + 1;

                            g_error_msg_tbl(l_index).TRANSACTION_ID             := g_txn_id;
                            g_error_msg_tbl(l_index).MESSAGE                    := l_MESSAGE;
                            g_error_msg_tbl(l_index).LAST_UPDATE_DATE           := sysdate;
                            g_error_msg_tbl(l_index).LAST_UPDATED_BY            := fnd_global.user_id;
                            g_error_msg_tbl(l_index).CREATION_DATE              := sysdate;
                            g_error_msg_tbl(l_index).CREATED_BY                 := fnd_global.user_id;
                            g_error_msg_tbl(l_index).LAST_UPDATE_LOGIN          := fnd_global.login_id;
                            g_error_msg_tbl(l_index).HEADER_ID                  := g_header_id;
                            g_error_msg_tbl(l_index).REQUEST_ID                 := fnd_global.conc_request_id;
                            g_error_msg_tbl(l_index).PROGRAM_ID                 := fnd_global.conc_program_id;
                            g_error_msg_tbl(l_index).PROGRAM_APPLICATION_ID     := fnd_global.prog_appl_id;
                            g_error_msg_tbl(l_index).MESSAGE_TYPE               := l_msg_type;

                        END IF;
                END IF;

                -- ( This code is correct : Unforutnately due to
                -- inefficient GSCC warning/error check, forced to refer to the package public variable
                --IF (p_fnd_log_level >= p_run_log_level and FND_LOG.TEST(p_fnd_log_level,p_module_name))
                IF  FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT and FND_LOG.TEST(p_fnd_log_level,p_module_name)
                THEN
                        -- To log into fnd_log_messages ...
                        fnd_log.string(log_level        => FND_LOG.LEVEL_STATEMENT,
                                       module           => p_module_name,
                                       message          => '[ ' || to_char(sysdate,'DD-MON-YYYY HH24:MI:SS') || ' ] : '
                                                           || p_module_name || ' : ' || p_stmt_num
                                                           || ' : ' || l_message);
                END IF;

        END IF;

END LogMessage;

PROCEDURE  handle_others ( p_module_name            IN varchar2,
                           p_stmt_num               IN NUMBER,
                           p_fnd_log_level          IN NUMBER,
                           p_run_log_level          IN NUMBER
                         )

IS
l_msg_tokens    token_rec_tbl;
BEGIN
        IF (G_LOG_LEVEL_UNEXPECTED >= p_fnd_log_level) THEN

                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (p_module_name       => p_module_name    ,
                                        p_msg_text          => SUBSTRB('Unexpected Error : SQLCODE '|| SQLCODE  ||' : SQLERRM : '|| SQLERRM, 1, 2000),
                                        p_stmt_num          => p_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens             ,
                                        p_fnd_log_level     => G_LOG_LEVEL_UNEXPECTED   ,
                                        p_run_log_level     => p_fnd_log_level
                                        );

        END IF;

        IF G_LOG_LEVEL_UNEXPECTED >= p_fnd_log_level OR
                FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR)
        THEN
                -- <construct tokens record>
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage(p_module_name        => p_module_name                    ,
                                      p_msg_name            => 'WSM_GENERIC_ERROR'      ,
                                      p_msg_appl_name       => 'WSM'                    ,
                                      p_msg_tokens          => l_msg_tokens             ,
                                      p_fnd_msg_level       => G_MSG_LVL_UNEXP_ERROR    ,
                                      p_fnd_log_level       => G_LOG_LEVEL_UNEXPECTED   ,
                                      p_run_log_level       => p_fnd_log_level
                                     );
        END IF;
END handle_others;

-- will write the message in the PL/SQL table to the database table...
PROCEDURE WriteToWIE

IS

BEGIN
        IF g_error_msg_tbl.count > 0 then
                forall l_index in g_error_msg_tbl.first..g_error_msg_tbl.last
                     insert into wsm_interface_errors values g_error_msg_tbl(l_index);
        END IF;

        -- reset once done...
        g_header_id    := null;
        g_txn_id       := null;
        g_write_to_WIE := 0;

        -- clean up the data...
        g_error_msg_tbl.delete;

END WriteToWIE;

-- This procedure will be used to update the g_error_tbl with
-- error messages returned from the other product API's
Procedure update_errtbl (p_start_index IN NUMBER,
                         p_end_index   IN NUMBER
                        )
IS

        l_index         NUMBER;
        l_err_msg       VARCHAR2(2000);
BEGIN

        IF (g_write_to_WIE <> 1) THEN
                return;
        END IF;

        FOR i IN p_start_index..p_end_index LOOP

             l_err_msg := fnd_msg_pub.get;
             l_index := g_error_msg_tbl.count + 1;

             g_error_msg_tbl(l_index).TRANSACTION_ID            := g_txn_id;
             g_error_msg_tbl(l_index).MESSAGE                   := l_err_msg;
             g_error_msg_tbl(l_index).LAST_UPDATE_DATE          := sysdate;
             g_error_msg_tbl(l_index).LAST_UPDATED_BY           := fnd_global.user_id;
             g_error_msg_tbl(l_index).CREATION_DATE             := sysdate;
             g_error_msg_tbl(l_index).CREATED_BY                := fnd_global.user_id;
             g_error_msg_tbl(l_index).LAST_UPDATE_LOGIN         := fnd_global.login_id;
             g_error_msg_tbl(l_index).HEADER_ID                 := g_header_id;
             -- Is it always ERROR..?
             g_error_msg_tbl(l_index).REQUEST_ID                := fnd_global.conc_request_id;
             g_error_msg_tbl(l_index).PROGRAM_ID                := fnd_global.conc_program_id;
             g_error_msg_tbl(l_index).PROGRAM_APPLICATION_ID    := fnd_global.prog_appl_id;

             g_error_msg_tbl(l_index).MESSAGE_TYPE              := G_MSG_LVL_UNEXP_ERROR;
       END LOOP;


END update_errtbl;

-- Populate Interface information...
--
Procedure PopulateIntfInfo ( p_header_id IN     NUMBER,
                             p_txn_id    IN     NUMBER
                           )

IS

BEGIN
        g_header_id    := p_header_id;
        g_txn_id       := p_txn_id;
        g_write_to_WIE := 1;
END PopulateIntfInfo;


END WSM_log_PVT;

/
