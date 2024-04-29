--------------------------------------------------------
--  DDL for Package Body PON_CF_TYPE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_CF_TYPE_GRP" AS
/* $Header: PONGCFTB.pls 120.0 2005/06/01 19:59:28 appldev noship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'PON_CF_TYPE_GRP';

--------------------------------------------------------------------------------
--                 Private procedure/function definitions                     --
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--                  Public procedure/function definition                      --
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
---                get_cost_factor_details                                    --
--------------------------------------------------------------------------------

PROCEDURE get_Cost_Factor_details(
             p_api_version             IN  NUMBER
            ,p_price_element_id        IN  pon_price_element_types.price_element_type_id%TYPE
            ,p_price_element_code      IN  pon_price_element_types.price_element_code%TYPE DEFAULT NULL
     	    ,p_name                    IN  pon_price_element_types_tl.name%TYPE DEFAULT NULL
     	    ,x_cost_factor_rec         OUT NOCOPY pon_price_element_types_vl%ROWTYPE
     	    ,x_return_status           OUT NOCOPY VARCHAR2
	        ,x_msg_data                OUT NOCOPY VARCHAR2
            ,x_msg_count               OUT NOCOPY NUMBER
          ) IS

l_api_name    CONSTANT VARCHAR2(30) := 'GET_COST_FACTOR_DETAILS';
l_api_version CONSTANT NUMBER       := 1.0;
l_stage                VARCHAR2(50);


TYPE cost_factor_type IS REF CURSOR RETURN pon_price_element_types_vl%ROWTYPE;
cost_factor_cur cost_factor_type;

l_query_ind VARCHAR2(1);

BEGIN

 -- Check for API comptability
 l_stage := '10: API check';

 IF  fnd_api.compatible_api_call(
        p_current_version_number => l_api_version
       ,p_caller_version_number  => p_api_version
       ,p_api_name               => l_api_name
       ,p_pkg_name               => g_pkg_name)
 THEN
    NULL;
 ELSE
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

 -- Check for input parameters
 l_stage := '20: input parameter check';
 l_query_ind := 'I'; -- set to query by id
 IF p_price_element_id IS NULL THEN
   l_query_ind := 'C'; -- query by code
   IF p_price_element_code IS NULL THEN
     l_query_ind := 'N'; -- query by name
     IF p_name IS NULL THEN
       -- all input parameters are null, raise error
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   END IF;
 END IF;

 -- decode query indicator and execute query
 l_stage := '30: running query';
 IF l_query_ind = 'I' THEN
   l_stage := '40: running query for ID';
   OPEN  cost_factor_cur
   FOR   SELECT * FROM pon_price_element_types_vl
         WHERE  price_element_type_id = p_price_element_id;
   FETCH cost_factor_cur INTO x_cost_factor_rec;
   IF cost_factor_cur%NOTFOUND THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSE
     CLOSE cost_factor_cur;
   END IF;

 ELSIF l_query_ind = 'C' THEN
   l_stage := '50: running query for CODE';
   OPEN  cost_factor_cur
   FOR   SELECT * FROM pon_price_element_types_vl
         WHERE  price_element_code = p_price_element_code;
   FETCH cost_factor_cur INTO x_cost_factor_rec;
   IF cost_factor_cur%NOTFOUND THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSE
     CLOSE cost_factor_cur;
   END IF;

 ELSIF l_query_ind = 'N' THEN
   l_stage := '40: running query for NAME';
   OPEN  cost_factor_cur
   FOR   SELECT * FROM pon_price_element_types_vl
         WHERE  name = p_name;
   FETCH cost_factor_cur INTO x_cost_factor_rec;
   IF cost_factor_cur%NOTFOUND THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSE
     CLOSE cost_factor_cur;
   END IF;
 END IF;

 x_return_status := fnd_api.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF cost_factor_cur%ISOPEN THEN
        CLOSE cost_factor_cur;
      END IF;
	  IF fnd_msg_pub.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
	     fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name,SQLERRM);
	     IF ( fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
		   fnd_log.string(log_level => fnd_log.level_unexpected
     		  	          ,module   => g_pkg_name ||'.'||l_api_name
                          ,message   => l_stage || ': ' || SQLERRM);
	       fnd_log.string(log_level=>fnd_log.level_unexpected
                          ,module   =>g_pkg_name ||'.'||l_api_name
                          ,message  => 'Input parameter list: ' );
	       fnd_log.string(log_level=>fnd_log.level_unexpected
                          ,module   =>g_pkg_name ||'.'||l_api_name
                          ,message  => 'Price element type id: '||p_price_element_id);
	       fnd_log.string(log_level=>fnd_log.level_unexpected
                          ,module   =>g_pkg_name ||'.'||l_api_name
                          ,message  => 'Price element code: '|| p_price_element_code );
	       fnd_log.string(log_level=>fnd_log.level_unexpected
                          ,module   =>g_pkg_name ||'.'||l_api_name
                          ,message  => 'Price element type name: '||p_name );
	       fnd_log.string(log_level=>fnd_log.level_unexpected
                          ,module   =>g_pkg_name ||'.'||l_api_name
                          ,message  => 'p_api_version: '||p_api_version );
        END IF;
     END IF;
     FND_MSG_PUB.Count_and_Get(p_count => x_msg_count
                              ,p_data  => x_msg_data);
END;

----------------------------------------------------------------------
---                opm_create_update_cost_factor                   ---
----------------------------------------------------------------------


PROCEDURE opm_create_update_cost_factor(
             p_api_version             IN  NUMBER
            ,p_price_element_code      IN  pon_price_element_types.price_element_code%TYPE
	    ,p_pricing_basis           IN  pon_price_element_types.pricing_basis%TYPE
	    ,p_cost_component_class_id IN  pon_price_element_types.cost_component_class_id%TYPE
	    ,p_cost_analysis_code      IN  pon_price_element_types.cost_analysis_code%TYPE
	    ,p_cost_acquisition_code   IN  pon_price_element_types.cost_acquisition_code%TYPE
	    ,p_name                    IN  pon_price_element_types_tl.name%TYPE
	    ,p_description             IN  pon_price_element_types_tl.name%TYPE
	    ,x_insert_update_action    OUT NOCOPY VARCHAR2
            ,x_price_element_type_id   OUT NOCOPY pon_price_element_types.price_element_type_id%TYPE
	    ,x_pricing_basis           OUT NOCOPY pon_price_element_types.pricing_basis%TYPE
	    ,x_return_status           OUT NOCOPY VARCHAR2
	    ,x_msg_data                OUT NOCOPY VARCHAR2
            ,x_msg_count               OUT NOCOPY NUMBER
          ) IS

l_api_name    CONSTANT VARCHAR2(30) := 'CREATE_UPDATE_COST_FACTOR';
l_api_version CONSTANT NUMBER       := 1.0;
l_stage                VARCHAR2(50);
l_temp        VARCHAR2(3);

l_price_element_type_id    pon_price_element_types.price_element_type_id%TYPE;

l_source_language          fnd_languages.language_code%TYPE;

BEGIN

 -- Check for API comptability

 l_stage := '10: API check';

 IF  fnd_api.compatible_api_call(
        p_current_version_number => l_api_version
       ,p_caller_version_number  => p_api_version
       ,p_api_name               => l_api_name
       ,p_pkg_name               => g_pkg_name)
 THEN
    NULL;
 ELSE
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

 l_stage := '20: PE Code check';
-- Check if the code exists.  If it does, we need to update the information
-- otherwise we need to insert the information

BEGIN

 SELECT price_element_type_id
       ,pricing_basis
   INTO l_price_element_type_id
       ,x_pricing_basis
   FROM pon_price_element_types
  WHERE price_element_code = p_price_element_code;

 l_stage := '25: PE Code found';

  x_insert_update_action := 'UPDATE';

EXCEPTION
 WHEN NO_DATA_FOUND
 THEN
   x_insert_update_action  := 'INSERT';
   x_pricing_basis         := p_pricing_basis;
   l_price_element_type_id := NULL;
END;

-- Validate the pricing basis
 l_stage := '30: Cost analysis code check';

BEGIN

  SELECT 'x'
    INTO l_temp
    FROM fnd_lookups lkp
   WHERE lkp.lookup_type = 'PON_PRICING_BASIS'
     AND lkp.lookup_code = p_pricing_basis;

EXCEPTION

 WHEN NO_DATA_FOUND
 THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;

-- Validate the cost analysis code

 l_stage := '40: Cost analysis code check';

 BEGIN

  SELECT 'x'
    INTO l_temp
    FROM CM_ALYS_MST c
   WHERE c.cost_analysis_code = p_cost_analysis_code;

 EXCEPTION
 WHEN NO_DATA_FOUND
 THEN
  -- Raise fatal error for invalid cost analysis code
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END;

-- Validate the cost component class id

 BEGIN

 l_stage := '50: Cost component class check';

  SELECT 'x'
    INTO l_temp
    FROM cm_cmpt_mst_b c
   WHERE c.cost_cmpntcls_id = p_cost_component_class_id;

 EXCEPTION
 WHEN NO_DATA_FOUND
 THEN
   -- raise error for invalid cost component class id
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END;

-- Get the installed language

BEGIN

 l_stage := '60: Get source language';

  SELECT language_code
    INTO l_source_language
    FROM fnd_languages fndlang
   WHERE installed_flag = 'B';

END;


x_price_element_type_id := l_price_element_type_id;

IF x_insert_update_action = 'INSERT'
THEN

 l_stage := '100: Insert cost factor';

   INSERT INTO PON_PRICE_ELEMENT_TYPES
    (
       price_element_type_id
      ,trading_partner_id
      ,price_element_code
      ,pricing_basis
      ,enabled_flag
      ,system_flag
      ,creation_date
      ,created_by
      ,last_update_date
      ,last_updated_by
      ,allocation_basis
      ,invoice_line_type
      ,cost_analysis_code
      ,cost_component_class_id
      ,cost_acquisition_code
    )
    VALUES
    (
       pon_price_element_types_s.NEXTVAL
      ,0                                 -- trading_partner_id
      ,p_price_element_code
      ,p_pricing_basis
      ,'Y'                               -- enabled_flag
      ,'N'                               -- system_flag
      ,SYSDATE                           -- creation_date,
      ,fnd_global.user_id                -- created_by
      ,SYSDATE                           -- last_update_date
      ,fnd_global.user_id                -- last_updated_by
      ,NULL                              -- allocation_basis
      ,NULL                              -- invoice_line_type
      ,p_cost_analysis_code
      ,p_cost_component_class_id
      ,p_cost_acquisition_code
    )
    RETURNING
      price_element_type_id INTO l_price_element_type_id;

    x_price_element_type_id := l_price_element_type_id;

-- If an existing code, then update information
-- Business rule: If an existing code, then the name and description
-- that are passed in are ignored and the _TL table is not updated
-- The id is passed back so that OPM can update their tables

 l_stage := '120: Insert cost factor tl';

   INSERT INTO pon_price_element_types_tl
            ( price_element_type_id
             ,trading_partner_id
             ,name
             ,description
             ,language
             ,source_lang
             ,creation_date
             ,created_by
             ,last_update_date
             ,last_updated_by)
      SELECT
             l_price_element_type_id
            ,0                           -- trading_partner_id
            ,p_name
            ,p_description
            ,fndlang.language_code
            ,l_source_language           -- source_lang
            ,SYSDATE                     -- creation_date
            ,fnd_global.user_id          -- created_by
            ,SYSDATE                     -- last_update_date
            ,fnd_global.user_id          -- last_updated_by
        FROM fnd_languages              fndlang
       WHERE fndlang.installed_flag IN ('I','B');

ELSE  -- if not a new cost factor

-- If the cost factor is existing, then we only update the base table
-- and ignore the passed in name, description - as per discussion with
-- the OPM team

 l_stage := '150: Update cost factor';

   UPDATE pon_price_element_types
      SET
       last_update_date        = SYSDATE
      ,last_updated_by         = fnd_global.user_id
      ,cost_analysis_code      = p_cost_analysis_code
      ,cost_component_class_id = p_cost_component_class_id
      ,cost_acquisition_code   = p_cost_acquisition_code
  WHERE price_element_type_id  = l_price_element_type_id;

 l_stage := '160: Check rows update';

  IF SQL%NOTFOUND
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

END IF;

x_return_status := fnd_api.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  IF fnd_msg_pub.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
	  THEN
	     fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name,SQLERRM);
	     IF ( fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
	     THEN
		 fnd_log.string(log_level => fnd_log.level_unexpected
			        ,module    => g_pkg_name ||'.'||l_api_name
                                ,message   => l_stage || ': ' || SQLERRM);
	         fnd_log.string(log_level=>fnd_log.level_unexpected,
                                module   =>g_pkg_name ||'.'||l_api_name,
                                message  => 'Input parameter list: ' );
		 fnd_log.string(log_level=>fnd_log.level_unexpected,
                                module   =>g_pkg_name ||'.'||l_api_name,
                                message  => 'p_api_version = ' ||  p_api_version);
                 fnd_log.string(log_level=>fnd_log.level_unexpected,
                                module   =>g_pkg_name ||'.'||l_api_name,
                                message  => 'p_price_element_code = ' || p_price_element_code);
                 fnd_log.string(log_level=>fnd_log.level_unexpected,
                                module   =>g_pkg_name ||'.'||l_api_name,
                                message  => 'p_pricing_basis = ' || p_pricing_basis);
                 fnd_log.string(log_level=>fnd_log.level_unexpected,
                                module   =>g_pkg_name ||'.'||l_api_name,
                                message  => 'p_cost_component_class_id = ' || p_cost_component_class_id);
                 fnd_log.string(log_level=>fnd_log.level_unexpected,
                                module   =>g_pkg_name ||'.'||l_api_name,
                                message  => 'p_cost_analysis_code = ' || p_cost_analysis_code);
                 fnd_log.string(log_level=>fnd_log.level_unexpected,
                                module   =>g_pkg_name ||'.'||l_api_name,
                                message  => 'p_cost_acquisition_code = ' || p_cost_acquisition_code);
                 fnd_log.string(log_level=>fnd_log.level_unexpected,
                                module   =>g_pkg_name ||'.'||l_api_name,
                                message  => 'p_name = ' || p_name);
                 fnd_log.string(log_level=>fnd_log.level_unexpected,
                                module   =>g_pkg_name ||'.'||l_api_name,
                                message  => 'p_description = ' || p_description);
	     END IF ;
	  END IF;
          FND_MSG_PUB.Count_and_Get(p_count => x_msg_count
                                   ,p_data  => x_msg_data);


END opm_create_update_cost_factor;

--------------------------------------------------------------------------------
---                OVERLOADED get_cost_factor_details                                    --
--------------------------------------------------------------------------------

FUNCTION get_Cost_Factor_details(
            p_price_element_id        IN  pon_price_element_types.price_element_type_id%TYPE
          )
RETURN pon_price_element_types_vl%ROWTYPE IS

  l_api_name CONSTANT VARCHAR2(30) := 'get_cost_factor_details';
  l_stage             VARCHAR2(30);

  CURSOR cost_factor_cur (p_cf_type_id NUMBER) IS
  SELECT *
  FROM   pon_price_element_types_vl
  WHERE  price_element_type_id = p_cf_type_id;

  l_cost_factor_type_rec cost_factor_cur%ROWTYPE;

BEGIN

  l_stage := '10: Execute curosr for ID';

  IF p_price_element_id IS NOT NULL THEN
    OPEN cost_factor_cur(p_price_element_id);
    FETCH cost_factor_cur INTO l_cost_factor_type_rec;
    CLOSE cost_factor_cur;
  END IF;

  RETURN l_cost_factor_type_rec;

EXCEPTION
     WHEN OTHERS THEN
      IF cost_factor_cur%ISOPEN THEN
        CLOSE cost_factor_cur;
      END IF;
	  IF fnd_msg_pub.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
	     fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name,SQLERRM);
	     IF ( fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
		   fnd_log.string(log_level => fnd_log.level_unexpected
     		  	        ,module   => g_pkg_name ||'.'||l_api_name
                          ,message   => l_stage || ': ' || SQLERRM);
	       fnd_log.string(log_level=>fnd_log.level_unexpected
                          ,module   =>g_pkg_name ||'.'||l_api_name
                          ,message  => 'Input parameter: ' );
	       fnd_log.string(log_level=>fnd_log.level_unexpected
                          ,module   =>g_pkg_name ||'.'||l_api_name
                          ,message  => 'Price element type id: '||p_price_element_id);
         END IF;
       END IF;
       RETURN l_cost_factor_type_rec;
END;

--------------------------------------------------------------------------------
---                OVERLOADED get_cost_factor_details                                    --
--------------------------------------------------------------------------------

FUNCTION get_Cost_Factor_details(
            p_price_element_code        IN  pon_price_element_types.price_element_code%TYPE
          )
RETURN pon_price_element_types_vl%ROWTYPE IS

  l_api_name CONSTANT VARCHAR2(30) := 'get_cost_factor_details';
  l_stage             VARCHAR2(30);

  CURSOR cost_factor_cur (p_cf_code VARCHAR2) IS
  SELECT *
  FROM   pon_price_element_types_vl
  WHERE  price_element_code = p_cf_code;

  l_cost_factor_type_rec cost_factor_cur%ROWTYPE;

BEGIN

  l_stage := '10: Execute cursor for Code';

  IF p_price_element_code IS NOT NULL THEN
    OPEN cost_factor_cur(p_price_element_code);
    FETCH cost_factor_cur INTO l_cost_factor_type_rec;
    CLOSE cost_factor_cur;
  END IF;
  RETURN l_cost_factor_type_rec;

EXCEPTION
     WHEN OTHERS THEN
      IF cost_factor_cur%ISOPEN THEN
        CLOSE cost_factor_cur;
      END IF;
	  IF fnd_msg_pub.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
	     fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name,SQLERRM);
	     IF ( fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
		   fnd_log.string(log_level => fnd_log.level_unexpected
     		  	        ,module   => g_pkg_name ||'.'||l_api_name
                          ,message   => l_stage || ': ' || SQLERRM);
	       fnd_log.string(log_level=>fnd_log.level_unexpected
                          ,module   =>g_pkg_name ||'.'||l_api_name
                          ,message  => 'Input parameter: ' );
	       fnd_log.string(log_level=>fnd_log.level_unexpected
                          ,module   =>g_pkg_name ||'.'||l_api_name
                          ,message  => 'Price element code: '||p_price_element_code);
         END IF;
       END IF;
       RETURN l_cost_factor_type_rec;
END;

END PON_CF_TYPE_GRP;

/
