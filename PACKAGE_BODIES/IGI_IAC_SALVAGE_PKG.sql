--------------------------------------------------------
--  DDL for Package Body IGI_IAC_SALVAGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_SALVAGE_PKG" AS
-- $Header: igiiascb.pls 120.3.12010000.2 2010/06/24 17:38:40 schakkin ship $

   --===========================FND_LOG.START=====================================

   g_state_level NUMBER	        :=	FND_LOG.LEVEL_STATEMENT;
   g_proc_level  NUMBER	        :=	FND_LOG.LEVEL_PROCEDURE;
   g_event_level NUMBER	        :=	FND_LOG.LEVEL_EVENT;
   g_excep_level NUMBER	        :=	FND_LOG.LEVEL_EXCEPTION;
   g_error_level NUMBER	        :=	FND_LOG.LEVEL_ERROR;
   g_unexp_level NUMBER	        :=	FND_LOG.LEVEL_UNEXPECTED;
   g_path        VARCHAR2(100)  :=      'IGI.PLSQL.igiiascb.igi_iac_salvage_pkg.';

   --===========================FND_LOG.END=====================================

   PROCEDURE do_round ( p_amount in out NOCOPY number, p_book_type_code in varchar2) is
      l_path varchar2(150) := g_path||'do_round(p_amount,p_book_type_code)';
      l_amount number     := p_amount;
      l_amount_old number := p_amount;
      --l_path varchar2(150) := g_path||'do_round';
    begin
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'--- Inside Round() ---');
       IF IGI_IAC_COMMON_UTILS.Iac_Round(X_Amount => l_amount, X_Book => p_book_type_code)
       THEN
          p_amount := l_amount;
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'IGI_IAC_COMMON_UTILS.Iac_Round is TRUE');
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_amount = '||p_amount);
       ELSE
          p_amount := round( l_amount, 2);
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'IGI_IAC_COMMON_UTILS.Iac_Round is FALSE');
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_amount = '||p_amount);
       END IF;
    exception when others then
      p_amount := l_amount_old;
      igi_iac_debug_pkg.debug_unexpected_msg(l_path);
      Raise;
   END;

    FUNCTION Correction
          (P_asset_id        IN igi_iac_asset_balances.asset_id%TYPE,
           P_book_type_code  IN igi_iac_asset_balances.book_type_code%TYPE,
           P_value           IN OUT NOCOPY Number,
           P_cost            IN Fa_books.cost%TYPE,
           P_salvage_value   IN fa_books.salvage_value%TYPE,
           p_calling_program    VARCHAR2)
    RETURN  Boolean IS

    	-- to get latest cost and salvage value for an asset
	    CURSOR C_get_asset_info IS
    	SELECT cost, salvage_value
	    FROM FA_BOOKS
    	WHERE Asset_id=P_Asset_id
	    AND book_type_Code =p_book_type_code
    	AND transaction_header_id_out IS NULL;

        l_cost fa_books.cost%TYPE;
        l_salvage_value fa_books.salvage_value%TYPE;
        err_asset_info    EXCEPTION;
        l_path_name VARCHAR2(150) := g_path||'correction';

   BEGIN
         igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		             p_full_path => l_path_name,
		             p_string => 'Parameter values Asset ID..'||p_asset_id );
         igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		             p_full_path => l_path_name,
		             p_string => 'Parameter values Book Type Code..'||P_book_type_code);
         igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		             p_full_path => l_path_name,
		             p_string => 'Parameter values Cost'||P_cost);
         igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		             p_full_path => l_path_name,
		             p_string => 'Parameter values salavge Value'||P_salvage_value);
         igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		             p_full_path => l_path_name,
		             p_string => 'Parameter values Value to be corrected'||P_value);

        IF P_salvage_value = 0 THEN
            RETURN TRUE;
        ELSIF P_Salvage_Value IS NULL THEN
        	-- Get the latest cost and salvage value
            OPEN c_get_asset_info;
            FETCH c_get_asset_info  INTO l_cost,l_salvage_value;
            IF c_get_asset_info%NOTFOUND THEN
                	 CLOSE c_get_asset_info;
                     RAISE  err_asset_info;
            END IF;
          	 CLOSE c_get_asset_info;

             P_value := p_value + (P_value/(l_cost-l_Salvage_value))*l_salvage_value;
	     do_round(p_value,P_book_type_code);

             RETURN TRUE;

        END IF;


        P_value := p_value + (P_value/(P_cost- P_Salvage_value))*P_salvage_value;
	do_round(p_value,P_book_type_code);

        RETURN TRUE;

    EXCEPTION
        WHEN err_asset_info THEN
            FND_MESSAGE.SET_NAME('IGI', 'IGI_IAC_EXCEPTION');
            FND_MESSAGE.SET_TOKEN('PACKAGE','igi_iac_salvage_pkg');
            FND_MESSAGE.SET_TOKEN('ERROR_MESSAGE','Error in fetching latest cost and salvage value for the asset', TRUE);
            igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		          p_full_path => l_path_name,
		          p_remove_from_stack => FALSE);
            fnd_file.put_line(fnd_file.log, fnd_message.get);
            RETURN FALSE;
        WHEN others THEN
             igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
             RETURN FALSE;

END correction;

END igi_iac_salvage_pkg;



/
