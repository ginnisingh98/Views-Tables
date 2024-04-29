--------------------------------------------------------
--  DDL for Package Body ZX_TAX_VERTEX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TAX_VERTEX_PKG" as
/* $Header: zxvertexpkgb.pls 120.2 2006/06/24 01:25:21 svaze ship $ */

/* ======================================================================*
 | FND Logging infrastructure                                           |
 * ======================================================================*/
G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'ZX_TAX_VERTEX_PKG';
G_CURRENT_RUNTIME_LEVEL     CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED          CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR               CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION           CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT               CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE           CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT           CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME               CONSTANT VARCHAR2(80) := 'ZX.PLSQL.ZX_TAX_VERTEX_PKG.';



FUNCTION IS_GEOCODE_VALID(p_geocode IN VARCHAR2) return BOOLEAN is
l_api_name             CONSTANT VARCHAR2(30) := 'IS_GEOCODE_VALID';

BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   IF (p_geocode between '000000000' and '999999999') THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Gecode is Valid.');
      END IF;
      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME || ': ' ||l_api_name||'(-)');
      END IF;
      return TRUE;
   ELSE
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Gecode is invalid.');
      END IF;
      FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','The GEOCODE for VERTEX must be between ''000000000'' and ''999999999''');
      FND_MSG_PUB.ADD();      -- Bug 5331410
      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME || ': ' ||l_api_name||'(-)');
      END IF;
      return FALSE;
   END IF;
END;

FUNCTION IS_CITY_LIMIT_VALID(p_city_limit IN VARCHAR2)return BOOLEAN is
l_api_name             CONSTANT VARCHAR2(30) := 'IS_CITY_LIMIT_VALID';
BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

  IF (p_city_limit = '1' or p_city_limit = '0') THEN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'City limit is valid.');
     END IF;
     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME || ': ' ||l_api_name||'(-)');
     END IF;
     return TRUE;
  ELSE
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'City limit is invalid.');
     END IF;
     FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
     FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','The City Limit should be either ''0'' or ''1''');
     FND_MSG_PUB.ADD();      -- Bug 5331410
     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME || ': ' ||l_api_name||'(-)');
     END IF;
     return FALSE;
  END IF;
END;

/* Bug 5139634: This function checks if Vertex has been installed in the customer instance
                and accordingly return the existence of Vertex to api (TAX_VENDOR_EXTENSION).
*/
FUNCTION INSTALLED return BOOLEAN is
l_return_status               VARCHAR2(1);
version_rec                   ZX_TAX_VERTEX_QSU.tQSUVersionRecord;
context_rec                   ZX_TAX_VERTEX_QSU.tQSUContextRecord;
l_api_name                    CONSTANT VARCHAR2(30) := 'INSTALLED';


BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   ZX_TAX_VERTEX_REV.GET_RELEASE(context_rec,version_rec,l_return_status);

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Vertex is not installed.');
      END IF;
      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME || ': ' ||l_api_name||'(-)');
      END IF;
      return FALSE;
   END IF;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Vertex is installed.');
   END IF;
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME || ': ' ||l_api_name||'(-)');
   END IF;
   return TRUE;

END;   -- Function INSTALLED

End zx_tax_vertex_pkg;

/
