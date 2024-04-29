--------------------------------------------------------
--  DDL for Package Body ZX_TAX_VERTEX_REV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TAX_VERTEX_REV" AS
/* $Header: zxtxvrevb.pls 120.4 2006/03/02 09:13:20 vchallur ship $ */

/*------------------------
 | Forward declarations  |
 ------------------------*/
--PG_DEBUG varchar2(1)  := NVL(FND_PROFILE.value('TAX_DEBUG_FLAG'), 'N');
--3062098
--PG_DEBUG varchar2(1)  := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE ERROR_EXCEPTION_HANDLE(str  varchar2);

/* ======================================================================*
 | Global Structure Data Types                                           |
 * ======================================================================*/

G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'ZX_TAX_VERTEX_REV';
G_CURRENT_RUNTIME_LEVEL     CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED          CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR               CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION           CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT               CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE           CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT           CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME               CONSTANT VARCHAR2(80) := 'ZX.PLSQL.ZX_TAX_VERTEX_REV.';

g_string Varchar2(200);

/*** Version Checking Constants ***/
MAJOR	CONSTANT	BINARY_INTEGER :=3; -- Major Vertex version number
MINOR	CONSTANT	BINARY_INTEGER := 2;-- Minor Vertex version number
pg_version_check	BOOLEAN;

version_rec             ZX_TAX_VERTEX_QSU.tQSUVersionRecord;
context_rec             ZX_TAX_VERTEX_QSU.tQSUContextRecord;
inv_in_rec              ZX_TAX_VERTEX_QSU.tQSUInvoiceRecord;
line_in_tab             ZX_TAX_VERTEX_QSU.tQSULineItemTable;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    GET_RELEASE                                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |	This function returns TRUE when package and package body QSU is      |
 | 	installed.							     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 +===========================================================================*/
PROCEDURE GET_RELEASE  (p_context_rec   OUT NOCOPY ZX_TAX_VERTEX_QSU.tQSUContextRecord,
                        p_version_rec   OUT NOCOPY ZX_TAX_VERTEX_QSU.tQSUVersionRecord,
			x_return_status OUT NOCOPY VARCHAR2) IS

BEGIN

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                'ZX.PL/SQL.ZX_TAX_VERTEX_REV.GET_RELEASE',
                'ZX_TAX_VERTEX_REV.GET_RELEASE(+)');
     END IF;

/*
    ARP_TAX_VERTEX_QSU.QSUInitializeInvoice(context_rec,
					    inv_in_rec,
					    line_in_tab); */


    /*-----------------------------------------------------------
     | Retrieve product version information.		        |
     -----------------------------------------------------------*/
    BEGIN
      IF ( g_level_statement >= g_current_runtime_level) THEN
         FND_LOG.STRING(g_level_statement,'ZX_TAX_VERTEX_REV.GET_RELEASE',
         'Call ZX_TAX_VERTEX_QSU.QSUGetVersionInfo to get version number');
      END IF;

        ZX_TAX_VERTEX_QSU.QSUGetVersionInfo(context_rec,version_rec);
        p_context_rec := context_rec ;
        p_version_rec := version_rec ;

    EXCEPTION
        WHEN OTHERS THEN
	    IF ( g_level_exception  >= g_current_runtime_level) THEN
               FND_LOG.STRING(g_level_exception,'ZX_TAX_VERTEX_REV.GET_RELEASE',
               'Version Error: '||to_char(SQLCODE)||SQLERRM);
            END IF;
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    g_string :='Not compaitable to VERTEX Release';
	    error_exception_handle(g_string);
	    return;

    END;

    IF ( g_level_statement >= g_current_runtime_level) THEN
               FND_LOG.STRING(g_level_statement,'ZX_TAX_VERTEX_REV.GET_RELEASE',
               'Version Number is== '||version_rec.fVersionNumber);

	       FND_LOG.STRING(g_level_statement,'ZX_TAX_VERTEX_REV.GET_RELEASE',
               'Release Date is '||to_char(version_rec.fReleaseDate));

	       FND_LOG.STRING(g_level_statement,'ZX_TAX_VERTEX_REV.GET_RELEASE',
               'MAJOR: '||substrb(version_rec.fVersionNumber, 1,instrb(version_rec.fVersionNumber, '.')-1));

	       FND_LOG.STRING(g_level_statement,'ZX_TAX_VERTEX_REV.GET_RELEASE',
               'MINOR: '||substrb(version_rec.fVersionNumber,
                instrb(version_rec.fVersionNumber,'.')+1,
                instrb(version_rec.fVersionNumber, '.', 1, 2)-
                (instrb(version_rec.fVersionNumber,'.')+1)));
    END IF;

    IF to_number(substrb(version_rec.fVersionNumber, 1,
         instrb(version_rec.fVersionNumber, '.')-1)) >MAJOR THEN

        pg_version_check := FALSE;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	g_string :='Not compaitable to VERTEX Release';
	error_exception_handle(g_string);
	return;
    ELSIF to_number(substrb(version_rec.fVersionNumber, 1,
         instrb(version_rec.fVersionNumber, '.')-1)) =MAJOR THEN
      if to_number(substrb(version_rec.fVersionNumber,
                instrb(version_rec.fVersionNumber,'.')+1,
                instrb(version_rec.fVersionNumber, '.', 1, 2)-
                (instrb(version_rec.fVersionNumber,'.')+1))) > MINOR THEN
        pg_version_check := FALSE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	g_string :='Not compaitable to VERTEX Release';
	error_exception_handle(g_string);
	return;
      else
        pg_version_check := TRUE;
      end if;
    ELSE
      pg_version_check := TRUE;
    END IF;
    IF ( g_level_statement >= g_current_runtime_level) THEN
         FND_LOG.STRING(g_level_statement,'ZX_TAX_VERTEX_REV.GET_RELEASE',
         'ZX_TAX_VERTEX_REV.GET_RELEASE(TRUE)-');
    END IF;

	--return TRUE;

EXCEPTION
    WHEN OTHERS THEN
        IF ( g_level_exception  >= g_current_runtime_level) THEN
               FND_LOG.STRING(g_level_exception,'ZX_TAX_VERTEX_REV.GET_RELEASE',
               'Vertex is not installed.');

	       FND_LOG.STRING(g_level_exception,'ZX_TAX_VERTEX_REV.GET_RELEASE',
               'SQLERRM: '||SQLERRM);

	       FND_LOG.STRING(g_level_exception,'ZX_TAX_VERTEX_REV.GET_RELEASE',
               'ARP_TAX_VERTEX_REV.GET_RELEASE(FALSE)-');
            END IF;

	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	--return FALSE;
END; -- procedure GET_RELEASE

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

ZX_VERTEX_TAX_SERVICE_PKG.G_MESSAGES_TBL.DOCUMENT_TYPE_ID(ZX_VERTEX_TAX_SERVICE_PKG.err_count)		:= l_docment_type_id;
ZX_VERTEX_TAX_SERVICE_PKG.G_MESSAGES_TBL.TRANSACTION_ID(ZX_VERTEX_TAX_SERVICE_PKG.err_count)		:= l_trasaction_id;
ZX_VERTEX_TAX_SERVICE_PKG.G_MESSAGES_TBL.COUNTRY_CODE(ZX_VERTEX_TAX_SERVICE_PKG.err_count)		:= l_tax_regime_code;
ZX_VERTEX_TAX_SERVICE_PKG.G_MESSAGES_TBL.ERROR_MESSAGE_TYPE(ZX_VERTEX_TAX_SERVICE_PKG.err_count)	:= 'ERROR';
ZX_VERTEX_TAX_SERVICE_PKG.G_MESSAGES_TBL.ERROR_MESSAGE_STRING(ZX_VERTEX_TAX_SERVICE_PKG.err_count)	:= str;

ZX_VERTEX_TAX_SERVICE_PKG.err_count :=ZX_VERTEX_TAX_SERVICE_PKG.err_count+1;

close error_exception_cursor;

End ERROR_EXCEPTION_HANDLE;


END ZX_TAX_VERTEX_REV;

/
