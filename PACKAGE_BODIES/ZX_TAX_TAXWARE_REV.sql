--------------------------------------------------------
--  DDL for Package Body ZX_TAX_TAXWARE_REV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TAX_TAXWARE_REV" AS
/* $Header: zxtxtrevb.pls 120.4 2006/08/07 21:24:27 svaze ship $ */

/* ======================================================================*
 | Global Structure Data Types                                           |
 * ======================================================================*/

G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'ZX_TAX_TAXWARE_REV';
G_CURRENT_RUNTIME_LEVEL     CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED          CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR               CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION           CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT               CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE           CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT           CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME               CONSTANT VARCHAR2(80) := 'ZX.PLSQL.ZX_TAX_TAXWARE_REV.';
g_string varchar2(200);

/*------------------------
 | Forward declarations  |
 ------------------------*/

pg_release_number  VARCHAR2(50) := NULL;

-- pg_compatible_release_number VARCHAR2(50) := '3.5';
pg_comp_rel_num_major CONSTANT  BINARY_INTEGER := 3;
pg_comp_rel_num_minor_low CONSTANT  BINARY_INTEGER := 1;
pg_comp_rel_num_minor_high CONSTANT  BINARY_INTEGER := 5;
pg_compatible_release BOOLEAN := FALSE;

PROCEDURE ERROR_EXCEPTION_HANDLE(str  varchar2);

/*----------------------------------------------------------------------------*
 | PUBLIC FUNCTION                                                            |
 |    Get_Release                                                             |
 |                                                                            |
 | DESCRIPTION                                                                |
 |                                                                            |
 |    The function will return ARP_TAX.TAX_SUCCESS on successful completion   |
 |    and on error return with ARP_TAX.TAX_RC_OERR                            |
 |                                                                            |
 +----------------------------------------------------------------------------*/
FUNCTION Get_Release RETURN VARCHAR2 IS
BEGIN

   IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                'ZX.PL/SQL.ZX_TAX_TAXWARE_REV.GET_RELEASE',
                'ZX_TAX_TAXWARE_REV.GET_RELEASE(+)');
   END IF;

   IF ( g_level_statement >= g_current_runtime_level) THEN
         FND_LOG.STRING(g_level_statement,'ZX_TAX_TAXWARE_REV.GET_RELEASE',
         'Checking Current release=='||pg_release_number);

	 FND_LOG.STRING(g_level_statement,'ZX_TAX_TAXWARE_REV.GET_RELEASE',
         'Major.Minor=='||pg_comp_rel_num_major||'.'||pg_comp_rel_num_minor_high);
   END IF;


  /******************************************************
   * Check the release number for Taxware               *
   ******************************************************/

   if not pg_compatible_release then
        if pg_release_number is null then
          BEGIN
            pg_release_number := rtrim(ltrim(ZX_TAX_TAXWARE_010.TAXFN_release_number));
          EXCEPTION
	    WHEN OTHERS THEN

	    IF ( g_level_exception  >= g_current_runtime_level) THEN
               FND_LOG.STRING(g_level_exception,'ZX_TAX_TAXWARE_REV.GET_RELEASE',
               'Version Error: '||to_char(SQLCODE)||SQLERRM);
            END IF;
	    --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    g_string :='Not compaitable to TAXWARE Release';
	    error_exception_handle(g_string);
	    RETURN ('9');
	  END;
	end if;

   IF ( g_level_statement >= g_current_runtime_level) THEN
         FND_LOG.STRING(g_level_statement,'ZX_TAX_TAXWARE_REV.GET_RELEASE',
         'major: '||substrb(pg_release_number, 1,instrb(pg_release_number, '.')-1));

	 FND_LOG.STRING(g_level_statement,'ZX_TAX_TAXWARE_REV.GET_RELEASE',
         'minor: '||substrb(pg_release_number, instrb(pg_release_number,'.')+1,1));
   END IF;


      IF to_number(substrb(pg_release_number, 1,
           instrb(pg_release_number, '.')-1)) <> pg_comp_rel_num_major THEN

            pg_compatible_release := FALSE;
	    IF ( g_level_exception  >= g_current_runtime_level) THEN
               FND_LOG.STRING(g_level_exception,'ZX_TAX_TAXWARE_REV.GET_RELEASE',
               'Version Error: '||to_char(SQLCODE)||SQLERRM);
            END IF;
	    --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    g_string :='Release number of Taxware SALES/USE TAX SYSTEM is '||
                      pg_release_number||' on this system. '||
		      'Oracle Application supports only '||pg_comp_rel_num_major||'.'||
                       pg_comp_rel_num_minor_low ||' through  '||pg_comp_rel_num_major||'.'||
                       pg_comp_rel_num_minor_high ||'.'||' Please contact Taxware representatives.';
	    error_exception_handle(g_string);
	    RETURN ('9');

       ELSE
          --  major release = 3, check for minor release
          IF to_number(substrb(pg_release_number,
                  instrb(pg_release_number,'.')+1,1)) > pg_comp_rel_num_minor_high
          or
             to_number(substrb(pg_release_number,
                  instrb(pg_release_number,'.')+1,1)) < pg_comp_rel_num_minor_low
          THEN
             pg_compatible_release := FALSE;

	     IF ( g_level_exception  >= g_current_runtime_level) THEN
               FND_LOG.STRING(g_level_exception,'ZX_TAX_TAXWARE_REV.GET_RELEASE',
               'Version Error: '||to_char(SQLCODE)||SQLERRM);
            END IF;
	    --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    g_string :='Release number of Taxware SALES/USE TAX SYSTEM is '||
                      pg_release_number||' on this system. '||
		      'Oracle Application supports only '||pg_comp_rel_num_major||'.'||
                       pg_comp_rel_num_minor_low ||' through  '||pg_comp_rel_num_major||'.'||
                       pg_comp_rel_num_minor_high ||'.'||' Please contact Taxware representatives.';
	    error_exception_handle(g_string);
	    RETURN ('9');

          ELSE
            pg_compatible_release := TRUE;
          END IF;

      END IF;

   else
      pg_compatible_release := TRUE;
   end if;

   return('0');

    IF ( g_level_statement >= g_current_runtime_level) THEN
         FND_LOG.STRING(g_level_statement,'ZX_TAX_TAXWARE_REV.GET_RELEASE',
         'ZX_TAX_TAXWARE_REV.GET_RELEASE(TRUE)-');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF ( g_level_exception  >= g_current_runtime_level) THEN
               FND_LOG.STRING(g_level_exception,'ZX_TAX_TAXWARE_REV.GET_RELEASE',
               'TAXWARE is not installed.');

	       FND_LOG.STRING(g_level_exception,'ZX_TAX_TAXWARE_REV.GET_RELEASE',
               'SQLERRM: '||SQLERRM);

	       FND_LOG.STRING(g_level_exception,'ZX_TAX_TAXWARE_REV.GET_RELEASE',
               'ARP_TAX_TAXWARE_REV.GET_RELEASE(FALSE)-');
            END IF;

	    --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


END Get_Release;

PROCEDURE ERROR_EXCEPTION_HANDLE(str  varchar2) is

cursor error_exception_cursor is
select	EVNT_CLS_MAPPING_ID,
	TRX_ID,
	TAX_REGIME_CODE
from ZX_TRX_PRE_PROC_OPTIONS_GT;

l_docment_type_id number;
l_trasaction_id   number;
l_tax_regime_code varchar2(80);

Begin
open error_exception_cursor;
fetch error_exception_cursor into l_docment_type_id,l_trasaction_id,l_tax_regime_code;

ZX_TAXWARE_TAX_SERVICE_PKG.G_MESSAGES_TBL.DOCUMENT_TYPE_ID(zx_taxware_TAX_SERVICE_PKG.err_count)	:= l_docment_type_id;
zx_taxware_TAX_SERVICE_PKG.G_MESSAGES_TBL.TRANSACTION_ID(zx_taxware_TAX_SERVICE_PKG.err_count)		:= l_trasaction_id;
zx_taxware_TAX_SERVICE_PKG.G_MESSAGES_TBL.COUNTRY_CODE(zx_taxware_TAX_SERVICE_PKG.err_count)		:= l_tax_regime_code;
zx_taxware_TAX_SERVICE_PKG.G_MESSAGES_TBL.ERROR_MESSAGE_TYPE(zx_taxware_TAX_SERVICE_PKG.err_count)	:= 'ERROR';
zx_taxware_TAX_SERVICE_PKG.G_MESSAGES_TBL.ERROR_MESSAGE_STRING(zx_taxware_TAX_SERVICE_PKG.err_count)	:= str;

zx_taxware_TAX_SERVICE_PKG.err_count :=zx_taxware_TAX_SERVICE_PKG.err_count+1;

close error_exception_cursor;

End ERROR_EXCEPTION_HANDLE;

END ZX_TAX_TAXWARE_REV;

/
