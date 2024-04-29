--------------------------------------------------------
--  DDL for Package Body ZX_API_PRVDR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_API_PRVDR_PUB" AS
/* $Header: zxifprvdrsrvpubb.pls 120.11 2006/09/21 09:30:07 vchallur ship $ */
/* ======================================================================*
 | Global Data Types                                                     |
 * ======================================================================*/

G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'ZX_API_PRVDR_PUB';
G_CURRENT_RUNTIME_LEVEL     CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED          CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR               CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION           CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT               CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE           CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT           CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME               CONSTANT VARCHAR2(30) := 'ZX.PLSQL.ZX_API_PRVDR_PUB.';

G_SRVC_CATEGORY             CONSTANT VARCHAR2(30) := 'PTNR_SRVC_INTGRTN';

PROCEDURE check_input_parameters (
  p_srvc_prvdr_name IN  VARCHAR2,
  p_srvc_type_code  IN  VARCHAR2,
  p_country_code    IN  VARCHAR2,
  p_business_flow   IN  VARCHAR2,
  p_error_msg_tbl   IN  OUT NOCOPY error_messages_tbl,
  p_error_counter   IN  OUT NOCOPY NUMBER,
  x_srvc_type_id    OUT NOCOPY NUMBER,
  x_api_owner_id    OUT NOCOPY NUMBER,
  x_return_status   OUT NOCOPY VARCHAR2
 )  IS
  l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_SRVC_REGISTRATION';
  l_exists            NUMBER;
  l_combination_found BOOLEAN;
  l_struct_num        NUMBER;
  l_delimiter         VARCHAR2(1);
  l_api_segments      fnd_flex_key_api.segment_list;

 BEGIN
   /*Validate Service Provider name*/
   BEGIN
     IF p_srvc_prvdr_name is not null THEN
        SELECT ptp.party_tax_profile_id
         INTO  x_api_owner_id
         FROM HZ_PARTIES pty,
              ZX_PARTY_TAX_PROFILE ptp
        WHERE pty.party_name = p_srvc_prvdr_name
          AND pty.party_id = ptp.party_id
          AND ptp.provider_type_code in ('BOTH', 'SERVICE')
          AND (ptp.party_tax_profile_id =1
            OR ptp.party_tax_profile_id=2);
     ELSE
       fnd_message.set_name('ZX', 'ZX_SRVC_PROVIDER_REQUIRED');
       p_error_msg_tbl(p_error_counter) := fnd_message.get;
       x_return_status := FND_API.G_RET_STS_ERROR;
       p_error_counter := p_error_counter+1;
	 END IF;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       fnd_message.set_name('ZX', 'ZX_SRVC_PROVIDER_REQUIRED');
       p_error_msg_tbl(p_error_counter) := fnd_message.get;
       x_return_status := FND_API.G_RET_STS_ERROR;
       p_error_counter := p_error_counter+1;
   END;

   /*Validate Service type code*/
     IF p_srvc_type_code is null THEN
       fnd_message.set_name('ZX', 'ZX_SRVC_TYPE_CODE_REQD');
       p_error_msg_tbl(p_error_counter) := fnd_message.get;
       x_return_status := FND_API.G_RET_STS_ERROR;
       p_error_counter := p_error_counter+1;
     ELSIF p_srvc_type_code NOT IN ('CALCULATE_TAX','DOCUMENT_LEVEL_CHANGES','SYNCHRONIZE_FOR_TAX','COMMIT_FOR_TAX','IMPORT_EXEMPTIONS') THEN
       fnd_message.set_name('ZX', 'ZX_SRVC_TYPE_CODE_REQD');
       p_error_msg_tbl(p_error_counter) := fnd_message.get;
       x_return_status := FND_API.G_RET_STS_ERROR;
       p_error_counter := p_error_counter+1;
     Else
       select service_type_id
	into x_srvc_type_id
	from zx_service_types
	where SERVICE_TYPE_CODE = p_srvc_type_code
	  and SERVICE_CATEGORY_CODE = G_SRVC_CATEGORY;
     END IF;

     /*Validate the country code*/
     IF p_country_code is null THEN
       fnd_message.set_name('ZX', 'ZX_COUNTRY_CODE_REQD');
       p_error_msg_tbl(p_error_counter) := fnd_message.get;
       x_return_status := FND_API.G_RET_STS_ERROR;
       p_error_counter := p_error_counter+1;
     ELSE
       BEGIN
         SELECT 1
           INTO l_exists
  		   FROM ZX_REGIMES_B
  		  WHERE tax_regime_code = p_country_code;

  		 EXCEPTION
		   WHEN NO_DATA_FOUND THEN
           fnd_message.set_name('ZX', 'ZX_COUNTRY_CODE_REQD');
           p_error_msg_tbl(p_error_counter) := fnd_message.get;
           x_return_status := FND_API.G_RET_STS_ERROR;
           p_error_counter := p_error_counter+1;
        END ;
     END IF;

     /*Validate Business flow*/
     IF p_business_flow is null THEN
       fnd_message.set_name('ZX', 'ZX_BUSINESS_FLOW_REQUIRED');
       p_error_msg_tbl(p_error_counter) := fnd_message.get;
       x_return_status := FND_API.G_RET_STS_ERROR;
       p_error_counter := p_error_counter+1;
     ELSIF p_businesS_flow not in ('O2C', 'P2P') THEN
       fnd_message.set_name('ZX', 'ZX_BUSINESS_FLOW_REQUIRED');
       p_error_msg_tbl(p_error_counter) := fnd_message.get;
       x_return_status := FND_API.G_RET_STS_ERROR;
       p_error_counter := p_error_counter+1;
	 END IF;

END check_input_parameters;
/*
This API is used to maintain the tax partner service registration, for the given tax interface and business flow.
*/

PROCEDURE create_srvc_registration (
  p_api_version	    IN NUMBER,
  x_error_msg_tbl   OUT NOCOPY error_messages_tbl,
  x_return_status   OUT NOCOPY VARCHAR2,
  p_srvc_prvdr_name IN VARCHAR2,
  p_srvc_type_code  IN VARCHAR2,
  p_country_code    IN VARCHAR2,
  p_business_flow   IN VARCHAR2,
  p_package_name    IN VARCHAR2,
  p_procedure_name  IN VARCHAR2
 )  IS
  l_api_name                   CONSTANT VARCHAR2(30) := 'CREATE_SRVC_REGISTRATION';
  l_exists                     NUMBER;
  l_combination_found          BOOLEAN;
  l_context_flex_structure     NUMBER;
  l_delimiter                  VARCHAR2(1);
  l_segments                   FND_FLEX_EXT.SegmentArray ;
  l_dummy                      BOOLEAN;
  l_flexfield                  VARCHAR2(2000);
  l_error_counter              NUMBER;
  l_code_combination_id        NUMBER;
  l_api_owner_id               NUMBER;
  l_api_status                 VARCHAR2(30);
  l_return_status              VARCHAR2(30);
  l_srvc_type_id               NUMBER;

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

    /*--------------------------------------------------+
    |   Standard start of API savepoint                 |
    +--------------------------------------------------*/
    SAVEPOINT create_srvc_registration_pvt;

   /*Set the return status to Success */
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_error_counter := 1;
   l_combination_found := TRUE;

   /*Validate the input parameters*/
   check_input_parameters(p_srvc_prvdr_name  => p_srvc_prvdr_name,
                          p_srvc_type_code   => p_srvc_type_code,
                          p_country_code     => p_country_code,
                          p_business_flow    => p_business_flow,
                          p_error_msg_tbl    => x_error_msg_tbl,
                          p_error_counter    => l_error_counter,
                          x_srvc_type_id     => l_srvc_type_id,
                          x_api_owner_id     => l_api_owner_id,
                          x_return_status    => l_return_status
                         );

   /*Validate package name*/
   IF p_package_name is null THEN
       fnd_message.set_name('ZX', 'ZX_PACKAGE_REQUIRED');
       x_error_msg_tbl(l_error_counter) := fnd_message.get;
       x_return_status := FND_API.G_RET_STS_ERROR;
       l_error_counter := l_error_counter+1;
   END IF;

   /*Validate procedure name*/
   IF p_procedure_name is null THEN
       fnd_message.set_name('ZX', 'ZX_PROCEDURE_REQUIRED');
       x_error_msg_tbl(l_error_counter) := fnd_message.get;
       x_return_status := FND_API.G_RET_STS_ERROR;
       l_error_counter := l_error_counter+1;
   END IF;

   /*Check if combination of business group and regime exists in zx_api_combinations*/
   BEGIN
       SELECT code_combination_id
         INTO l_code_combination_id
         FROM zx_api_code_combinations
        WHERE segment_attribute1 = p_country_code
          AND segment_attribute2 = p_business_flow;

        EXCEPTION
	      WHEN NO_DATA_FOUND THEN
		    l_combination_found := FALSE;
    END;

    /*Check if service already registerd */
    IF x_error_msg_tbl.COUNT = 0 THEN
      IF l_combination_found THEN
        BEGIN
          SELECT 1
	      INTO l_exists
	      FROM zx_api_registrations reg,
		       zx_service_types srvc
         WHERE reg.api_owner_id = l_api_owner_id
   	       AND srvc.service_type_id = reg.service_type_id
	       AND srvc.service_type_code = p_srvc_type_code
		   AND context_ccid = l_code_combination_id;

	       IF l_exists = 1 THEN
             fnd_message.set_name('ZX', 'ZX_SERVICE_RECORD_EXISTS');
             x_error_msg_tbl(l_error_counter) := fnd_message.get;
             x_return_status := FND_API.G_RET_STS_ERROR;
             l_error_counter := l_error_counter+1;
           END IF;

	       EXCEPTION
	         WHEN NO_DATA_FOUND THEN
	         null;
  	     END;
      ELSE /*create the combination*/
        SELECT context_flex_structure_id
          INTO l_context_flex_structure
          FROM ZX_SERVICE_TYPES
         WHERE service_type_code = p_srvc_type_code
           AND service_category_code = G_SRVC_CATEGORY;

         -- need to create ccid for the new tax_regime_code
         ------------------------------------------------------------------
         --  Find or generate the CCID for the new combination           --
         ------------------------------------------------------------------
         /*For the 2 segments*/
        l_segments(1) := p_country_code;
        l_segments(2) := p_business_flow;

        IF NOT (fnd_flex_ext.get_combination_id (application_short_name =>  'ZX',
                                                 key_flex_code          =>  'ZX#',
                                                 structure_number       =>  l_context_flex_structure,
                                                 validation_date        =>  sysdate,
                                                 n_segments             =>  2,
                                                 segments               =>  l_segments,
                                                 combination_id         =>  l_code_combination_id
                                                 )) THEN

          fnd_message.set_name ('ZX', 'ZX_PTNR_SRVC_CCID_NOT_FOUND');  -- Bug 5216009
          x_error_msg_tbl(l_error_counter) := fnd_message.get;
          x_return_status := FND_API.G_RET_STS_ERROR;
          l_error_counter := l_error_counter+1;
        END IF;
      END IF; --create code combination

      /*Create data in registrations*/
      INSERT INTO ZX_API_REGISTRATIONS
              (API_REGISTRATION_ID,
               API_OWNER_ID,
               PACKAGE_NAME,
               PROCEDURE_NAME,
               SERVICE_TYPE_ID,
               CONTEXT_CCID,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN,
	       OBJECT_VERSION_NUMBER,
	       RECORD_TYPE_CODE)
          VALUES
               (ZX_API_REGISTRATIONS_S.nextval,
                l_api_owner_id,
                p_package_name,
                p_procedure_name,
                l_srvc_type_id,
                l_code_combination_id,
                sysdate,
                FND_GLOBAL.user_id,
                sysdate,
                FND_GLOBAL.user_id,
                FND_GLOBAL.user_id,
		1,
		'EBTAX_CREATED');

    -- Check the status of the API owner.
      BEGIN
        SELECT status_code
          INTO l_api_status
          FROM ZX_API_OWNER_STATUSES
         WHERE api_owner_id         =  l_api_owner_id
          AND service_category_code = G_SRVC_CATEGORY;
      EXCEPTION
        WHEN no_data_found then
          -- No entry found in the zx_api_owner_stratuses
          -- Insert a record into zx_api_owner_statuses table.
          l_api_status := 'NEW';
          INSERT INTO ZX_API_OWNER_STATUSES
                     (api_owner_id
                    , service_category_code
                    , status_code
                    , creation_date
                    , created_by
                    , last_update_date
                    , last_updated_by
                    , last_update_login)
               VALUES(l_api_owner_id
                    , G_SRVC_CATEGORY
                    , 'NEW'
                    , sysdate
                    , fnd_global.user_id
                    , sysdate
                    , fnd_global.user_id
                    , fnd_global.user_id);
      END;

      /*Status record exists- update them*/
      IF l_api_status = 'DELETED' THEN
         UPDATE ZX_API_OWNER_STATUSES
           SET status_code = 'NEW'
         WHERE api_owner_id   =  l_api_owner_id
           AND service_category_code = G_SRVC_CATEGORY;
      ELSIF l_api_status = 'GENERATED' THEN
         UPDATE ZX_API_OWNER_STATUSES
           SET status_code = 'MODIFIED'
         WHERE api_owner_id   =  l_api_owner_id
           AND service_category_code = G_SRVC_CATEGORY;
      END IF;
    END IF; --no errors in errors table

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
    END IF;

    EXCEPTION
       WHEN OTHERS THEN
         ROLLBACK TO create_srvc_registration_pvt;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MESSAGE.set_name('ZX','ZX_UNEXPECTED_ERROR');
         x_error_msg_tbl(l_error_counter) := fnd_message.get;
         l_error_counter := l_error_counter+1;
         IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
         END IF;
 END create_srvc_registration;


 PROCEDURE delete_srvc_registration (
  p_api_version	    IN NUMBER,
  x_error_msg_tbl   OUT NOCOPY error_messages_tbl,
  x_return_status   OUT NOCOPY VARCHAR2,
  p_srvc_prvdr_name IN VARCHAR2,
  p_srvc_type_code  IN VARCHAR2,
  p_country_code    IN VARCHAR2,
  p_business_flow   IN VARCHAR2
 )  IS
  l_api_name        CONSTANT VARCHAR2(30) := 'DELETE_SRVC_REGISTRATION';
  l_api_owner_id    NUMBER;
  l_error_counter   NUMBER;
  l_api_status      VARCHAR2(30);
  l_return_status   VARCHAR2(30);
  l_count           NUMBER;
  l_srvc_type_id    NUMBER;
 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

    /*--------------------------------------------------+
    |   Standard start of API savepoint                 |
    +--------------------------------------------------*/
    SAVEPOINT delete_srvc_registration_pvt;

   /*Set the return status to Success */
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_error_counter := 1;

   check_input_parameters(p_srvc_prvdr_name  => p_srvc_prvdr_name,
                          p_srvc_type_code   => p_srvc_type_code,
                          p_country_code     => p_country_code,
                          p_business_flow    => p_business_flow,
                          p_error_msg_tbl    => x_error_msg_tbl,
                          p_error_counter    => l_error_counter,
                          x_srvc_type_id     => l_srvc_type_id,
                          x_api_owner_id     => l_api_owner_id,
                          x_return_status    => l_return_status
                         );
    /*Determine number of records to decide the status in zx_api_owner_statues*/
    BEGIN
      SELECT count(*)
        INTO l_count
        FROM ZX_API_REGISTRATIONS
       WHERE api_owner_id = l_api_owner_id
         AND service_type_id = l_srvc_type_id;

    EXCEPTION
      WHEN NO_DATA_FOUND  THEN
      fnd_message.set_name('ZX', 'ZX_SRVC_RECORD_NOT_EXISTS');
      x_error_msg_tbl(l_error_counter) := fnd_message.get;
      x_return_status := FND_API.G_RET_STS_ERROR;
      l_error_counter := l_error_counter+1;
    END;

	DELETE from ZX_API_REGISTRATIONS
	  WHERE EXISTS (SELECT *
	                  FROM zx_api_registrations reg,
					       zx_api_code_combinations cmbn,
						   zx_service_types srvc
					  WHERE reg.api_owner_id = l_api_owner_id
	                    AND srvc.service_type_id = reg.service_type_id
	                    AND srvc.service_type_code = p_srvc_type_code
	                    AND cmbn.segment_attribute1 = p_country_code
	                    AND cmbn.segment_attribute2 = p_business_flow
	                    AND reg.context_ccid = cmbn.code_combination_id
                    );

    /*Update the status back to zx_api_statuses table*/
    IF x_error_msg_tbl.COUNT = 0 THEN
      BEGIN
        SELECT status_code
          INTO l_api_status
          FROM ZX_API_OWNER_STATUSES
         WHERE api_owner_id         =  l_api_owner_id
           AND service_category_code = G_SRVC_CATEGORY;

         EXCEPTION
           WHEN no_data_found then
             null;
      END;

      IF l_count = 1 THEN
        IF l_api_status in ('NEW','GENERATED','MODIFIED') THEN
           UPDATE ZX_API_OWNER_STATUSES
              SET status_code = 'DELETED'
            WHERE api_owner_id   =  l_api_owner_id
              AND service_category_code = G_SRVC_CATEGORY;
        END IF;
      ELSE
        IF l_api_status = 'GENERATED' THEN
           UPDATE ZX_API_OWNER_STATUSES
              SET status_code = 'MODIFIED'
            WHERE api_owner_id   =  l_api_owner_id
              AND service_category_code = G_SRVC_CATEGORY;
        END IF;
      END IF;
    END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
   END IF;

    EXCEPTION
       WHEN OTHERS THEN
         ROLLBACK TO insert_row_Pvt;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MESSAGE.set_name('ZX','ZX_UNEXPECTED_ERROR');
         x_error_msg_tbl(l_error_counter) := fnd_message.get;
         l_error_counter := l_error_counter+1;
         IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
         END IF;
 END DELETE_SRVC_REGISTRATION;


PROCEDURE execute_srvc_plugin (
  p_api_version	    IN  NUMBER,
  x_error_msg_tbl   OUT NOCOPY error_messages_tbl,
  x_return_status   OUT NOCOPY VARCHAR2,
  p_srvc_prvdr_name IN VARCHAR2
 )  IS
  l_api_name        CONSTANT VARCHAR2(30) := 'EXECUTE_SRVC_PLUGIN';
  l_api_owner_id    NUMBER;
  l_error_counter   NUMBER;
  l_request_id      NUMBER;

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

    /*--------------------------------------------------+
    |   Standard start of API savepoint                 |
    +--------------------------------------------------*/
    SAVEPOINT execute_srvc_plugin_pvt;

   /*Set the return status to Success */
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   /*Validate Service Provider Name*/
   BEGIN
     IF p_srvc_prvdr_name is not null THEN
       SELECT ptp.party_tax_profile_id
        INTO  l_api_owner_id
         FROM HZ_PARTIES pty,
              ZX_PARTY_TAX_PROFILE ptp
         WHERE pty.party_name = p_srvc_prvdr_name
           AND pty.party_id = ptp.party_id
           AND ptp.provider_type_code in ('BOTH', 'SERVICE')
           AND (ptp.party_tax_profile_id =1
             OR ptp.party_tax_profile_id=2);
     ELSE
       fnd_message.set_name('ZX', 'ZX_SRVC_PROVIDER_REQUIRED');
       x_error_msg_tbl(l_error_counter) := fnd_message.get;
       x_return_status := FND_API.G_RET_STS_ERROR;
       l_error_counter := l_error_counter+1;
	 END IF;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       fnd_message.set_name('ZX', 'ZX_SRVC_PROVIDER_REQUIRED');
       x_error_msg_tbl(l_error_counter) := fnd_message.get;
       x_return_status := FND_API.G_RET_STS_ERROR;
       l_error_counter := l_error_counter+1;
   END;

   IF x_error_msg_tbl.COUNT = 0 THEN
     l_request_id  := fnd_request.submit_request
                       (
                         application      => 'ZX',
                         program          => 'ZXPTNRSRVCPLUGIN',
                         sub_request      => false,
                         argument1        => G_SRVC_CATEGORY,
                         argument2        => l_api_owner_id);
      commit;
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
   END IF;

   EXCEPTION
       WHEN OTHERS THEN
         ROLLBACK TO execute_srvc_plugin_pvt;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         fnd_message.set_name('ZX', 'ZX_UNEXPECTED_ERROR');
         x_error_msg_tbl(l_error_counter) := fnd_message.get;
         l_error_counter := l_error_counter+1;
         IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
         END IF;

  END  execute_srvc_plugin;
END ZX_API_PRVDR_PUB;

/
