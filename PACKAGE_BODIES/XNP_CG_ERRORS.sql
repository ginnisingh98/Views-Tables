--------------------------------------------------------
--  DDL for Package Body XNP_CG$ERRORS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_CG$ERRORS" AS
/* $Header: XNPCDSAB.pls 120.2 2006/02/13 07:41:41 dputhiye ship $ */

   cg$err_msg      cg$err_msg_t;
   cg$err_error    cg$err_error_t;
   cg$err_msg_type cg$err_msg_type_t;
   cg$err_msgid    cg$err_msgid_t;
   cg$err_loc      cg$err_loc_t;

   -----------------------------------------------------------------------------
   -- Name:        get_errors
   -- Description: Pops all messages off the stack and returns them in the order
   --              in which they were raised.
   -- Parameters:  none
   -- Returns:     The messages
   -----------------------------------------------------------------------------
   FUNCTION GetErrors
         return varchar2  is
      I_ERROR_MESS  varchar2(2000):='';
      I_NEXT_MESS   varchar2(240):='';
   BEGIN
     while XNP_cg$errors.pop(I_NEXT_MESS) loop
       if I_ERROR_MESS is null then
          I_ERROR_MESS := I_NEXT_MESS;
       else
          I_ERROR_MESS := I_NEXT_MESS || '
   ' || I_ERROR_MESS;
       end if;
     end loop;
     return (I_ERROR_MESS);
   END;

   --------------------------------------------------------------------------------
   -- Name:        raise_failure
   --
   -- Description: To raise the XNP_cg$error failure exception handler
   --------------------------------------------------------------------------------
   PROCEDURE raise_failure IS
   BEGIN

       raise XNP_cg$errors.cg$error;

   END raise_failure;

   --------------------------------------------------------------------------------
   -- Name:        parse_constraint
   -- Description: Isolate constraint name from an Oracle error message
   -- Parameters:  msg     The actual Oracle error message
   --              type    type of constraint to find
   --                      (ERR_FOREIGN_KEY     Foreign key,
   --                       ERR_CHECK_CON       Check,
   --                       ERR_UNIQUE_KEY      Unique key,
   --                       ERR_DELETE_RESTRICT Restricted delete)
   -- Returns:     con_name Constraint found (NULL if none found)
   --------------------------------------------------------------------------------
   FUNCTION parse_constraint(msg   IN VARCHAR2
                            ,type  IN INTEGER)
           RETURN VARCHAR2 IS
   con_name    VARCHAR2(100) := '';
   BEGIN

       IF (type = ERR_FOREIGN_KEY	OR
           type = ERR_CHECK_CON	OR
           type = ERR_UNIQUE_KEY	OR
           type = ERR_DELETE_RESTRICT) THEN
           con_name := substr(msg, instr(msg, '.') + 1, instr(msg, ')') - instr(msg, '.') - 1);
       END IF;

       return con_name;
   END;

   --------------------------------------------------------------------------------
   -- Name:        push
   --
   -- Description: Put a message on stack with full info
   --
   -- Parameters:  msg      Text message
   --              error    ERRor or WARNing
   --              msg_type ORA, API or user TLA
   --              msg_id   Id of message
   --              loc      Location where error occured
   --------------------------------------------------------------------------------
   PROCEDURE push(msg      IN VARCHAR2
                 ,error    IN VARCHAR2  DEFAULT 'E'
                 ,msg_type IN VARCHAR2  DEFAULT ''
                 ,msgid    IN INTEGER   DEFAULT 0
                 ,loc      IN VARCHAR2  DEFAULT '') IS
   BEGIN

       cg$err_msg(cg$err_tab_i)        := msg;
       cg$err_error(cg$err_tab_i)      := error;
       cg$err_msg_type(cg$err_tab_i)   := msg_type;
       cg$err_msgid(cg$err_tab_i)      := msgid;
       cg$err_loc(cg$err_tab_i)        := loc;
       cg$err_tab_i                    := cg$err_tab_i + 1;

   END push;

   --------------------------------------------------------------------------------
   -- Name:        pop
   -- Description: Take a message off stack
   -- Parameters:  msg     Text message
   -- Returns:     TRUE    Message popped successfully
   --              FALSE   Stack was empty
   --------------------------------------------------------------------------------
   FUNCTION pop(msg OUT NOCOPY VARCHAR2)
       RETURN BOOLEAN IS
   BEGIN

       IF (cg$err_tab_i > 1 AND cg$err_msg(cg$err_tab_i - 1) IS NOT NULL) THEN
           cg$err_tab_i := cg$err_tab_i - 1;
           msg          := cg$err_msg(cg$err_tab_i);
           cg$err_msg(cg$err_tab_i) := '';
           return TRUE;
       ELSE
           return FALSE;
       END IF;

   END pop;

   --------------------------------------------------------------------------------
   -- Name:        pop (overload)
   -- Description: Take a message off stack with full info
   -- Parameters:  msg      Ttext message
   --              error    ERRor or WARNing
   --              msg_type ORA, API or user TLA
   --              msg_id   Id of message
   --              loc      Location where error occured
   -- Returns:     TRUE     Message popped successfully
   --              FALSE    Stack was empty
   --------------------------------------------------------------------------------
   FUNCTION pop(msg        OUT NOCOPY VARCHAR2
               ,error      OUT NOCOPY VARCHAR2
               ,msg_type   OUT NOCOPY VARCHAR2
               ,msgid      OUT NOCOPY INTEGER
               ,loc        OUT NOCOPY VARCHAR2)
           RETURN BOOLEAN IS
   BEGIN

       IF (cg$err_tab_i > 1 AND cg$err_msg(cg$err_tab_i - 1) IS NOT NULL) THEN
           cg$err_tab_i := cg$err_tab_i - 1;
           msg          := cg$err_msg(cg$err_tab_i);
           cg$err_msg(cg$err_tab_i) := '';
           error        := cg$err_error(cg$err_tab_i);
           msg_type     := cg$err_msg_type(cg$err_tab_i);
           msgid        := cg$err_msgid(cg$err_tab_i);
           loc          := cg$err_loc(cg$err_tab_i);
           return TRUE;
       ELSE
           return FALSE;
       END IF;

   END pop;

   --------------------------------------------------------------------------------
   -- Name:        clear
   -- Description: Clears the stack
   -- Parameters:  none
   --------------------------------------------------------------------------------
   PROCEDURE clear IS
   BEGIN

       cg$err_tab_i := 1;

   END clear;

   --------------------------------------------------------------------------------
   -- Name:        MsgGetText
   -- Description: Provides a mechanism for text translation.
   -- Parameters:  p_MsgNo    The Id of the message
   --              p_DfltText The Default Text
   --              p_Subst1 (to 4) Substitution strings
   --              p_LangId   The Language ID
   -- Returns:		Translated message
   --------------------------------------------------------------------------------
   FUNCTION MsgGetText(p_MsgNo in number
                      ,p_DfltText in varchar2
                      ,p_Subst1 in varchar2
                      ,p_Subst2 in varchar2
                      ,p_Subst3 in varchar2
                      ,p_Subst4 in varchar2
                      ,p_LangId in number)
            RETURN varchar2 IS
      l_temp varchar2(10000) := p_DfltText;
   BEGIN

      l_temp := replace(l_temp, '<p>',  p_Subst1);
      l_temp := replace(l_temp, '<p1>', p_Subst1);
      l_temp := replace(l_temp, '<p2>', p_Subst2);
      l_temp := replace(l_temp, '<p3>', p_Subst3);
      l_temp := replace(l_temp, '<p4>', p_Subst4);

      return l_temp;

   END MsgGetText;

END XNP_cg$errors;

/
