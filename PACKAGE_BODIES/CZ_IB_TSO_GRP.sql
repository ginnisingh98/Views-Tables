--------------------------------------------------------
--  DDL for Package Body CZ_IB_TSO_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_IB_TSO_GRP" AS
/*	$Header: czibtsob.pls 120.7 2007/02/09 19:40:26 skudryav ship $		*/

  G_PKG_NAME CONSTANT VARCHAR2(255) := 'CZ_IB_TSO_GRP';

  --
  -- section for a different DEBUG procedures
  --
  PROCEDURE DEBUG(p_str IN VARCHAR2) IS
  BEGIN
    --DBMS_OUTPUT.PUT_LINE(p_str);
    NULL;
  END DEBUG;

  PROCEDURE DEBUG(p_var_name IN VARCHAR2, p_var_value IN VARCHAR2) IS
  BEGIN
    DEBUG(p_var_name || ' = ' || p_var_value);
  END DEBUG;

  PROCEDURE DEBUG(p_var_name IN VARCHAR2, p_var_value IN NUMBER) IS
  BEGIN
    DEBUG(p_var_name || ' = ' || TO_CHAR(p_var_value));
  END DEBUG;

  PROCEDURE DEBUG(p_var_name IN VARCHAR2, p_var_value IN DATE) IS
  BEGIN
    DEBUG(p_var_name || ' = ' ||
          TO_CHAR(p_var_value, 'DD-MM-YYYY HH24:MI:SS'));
  END DEBUG;

  PROCEDURE dump_Error_Stack(p_prefix IN VARCHAR2) IS
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(4000);
    l_msg_index number;
  BEGIN
   DEBUG('------------ Start of '||p_prefix||' ----------------');
   l_msg_index := 1;
   l_msg_count := fnd_msg_pub.COUNT_MSG();
   DEBUG(p_prefix||' '||TO_CHAR(l_msg_count)||' error messages .');
   WHILE l_msg_count > 0 LOOP
      l_msg_data := fnd_msg_pub.GET(l_msg_index,fnd_api.g_false);
      DEBUG(p_prefix||l_msg_data);
      l_msg_index := l_msg_index + 1;
      l_msg_count := l_msg_count - 1;
   END LOOP;
   DEBUG('------------ End  of '||p_prefix||' ----------------');
  END dump_Error_Stack;

--
-- Removes returned config item by marking it with a special flags returned_flag
--

/* #  Removes returned config item by marking it with a special flags returned_flag
* @param p_instance_hdr_id Identifies instance_hdr_id OF returned config item
* @param p_instance_rev_nbr Identifies instance_rev_nbr OF returned config item
* @param p_returned_config_item Identifies config_item_id OF returned config item
* @param p_locked_instance_rev_nbr  Identifies locked revision OF returned config item
*        IF it IS NULL THEN this means that config item was NOT locked ( no pending orders WITH this item )
* @param p_application_id - application Id OF caller ( IF NULL THEN by defualt it's 542(IB))
* @p_config_eff_date - configuration effectivity date ( if NULL then by default it's SYSDATE )
* @param x_validation_status Returns either fnd_api.g_true IF configuration IS valid
* OR fnd_api.g_false IF configuration IS NOT valid
* @param x_return_status Returns one of three values :
* FND_API.G_RET_STS_SUCCESS IF no errors occurred
* FND_API.G_RET_STS_ERROR IF AT LEAST one error occurred
* FND_API.G_RET_STS_UNEXP_ERROR IF AT LEAST one unexpected error occurred
* @param x_msg_count Indicates how many messages exist ON ERROR_HANDLER
* message stack upon completion OF processing.
* @param x_msg_data IF exactly one message EXISTS ON ERROR_HANDLER
* message stack upon completion OF processing, this parameter contains
* that message.
*
* @rep:scope PUBLIC
* @rep:lifecycle active
* @rep:displayname Remove Returned Config Item
*/
PROCEDURE remove_Returned_Config_Item
(
 p_instance_hdr_id           IN  NUMBER,
 p_instance_rev_nbr          IN  NUMBER,
 p_returned_config_item_id   IN  NUMBER,
 p_locked_instance_rev_nbr   IN  NUMBER,
 p_application_id            IN  NUMBER,
 p_config_eff_date           IN  DATE,
 x_validation_status         OUT NOCOPY VARCHAR2,
 x_return_status             OUT NOCOPY VARCHAR2,
 x_msg_count                 OUT NOCOPY NUMBER,
 x_msg_data                  OUT NOCOPY VARCHAR2
 ) IS

 -- procedure sets autonomous transaction
 --
 PRAGMA AUTONOMOUS_TRANSACTION;

 l_config_tbl                CZ_API_PUB.config_tbl_type;
 l_appl_param_rec            CZ_API_PUB.appl_param_rec_type;
 l_config_model_tbl          CZ_API_PUB.config_model_tbl_type;
 l_config_status             CZ_CONFIG_HDRS.config_status%TYPE;

 l_locked_item_returned_flag VARCHAR2(1) := '0';
 l_returned_flag             VARCHAR2(1) := '0';
 l_tangible_item_flag        VARCHAR2(1);
 l_return_status             VARCHAR2(50);
 l_msg_data                  VARCHAR2(4000);
 l_config_hdr_id             NUMBER;
 l_config_rev_nbr            NUMBER;
 l_msg_count                 NUMBER;
 l_ndebug                    NUMBER;
 l_api_name                  VARCHAR2(255) := 'remove_Returned_Config_Item';
 CZ_ITEM_IS_NOT_TANGIBLE     EXCEPTION;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_ndebug := 0;
    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'List of parameters : ',
    fnd_log.LEVEL_PROCEDURE);

    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'p_instance_hdr_id='||TO_CHAR(p_instance_hdr_id),
     fnd_log.LEVEL_PROCEDURE);

    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'p_instance_rev_nbr ='||TO_CHAR(p_instance_rev_nbr ),
     fnd_log.LEVEL_PROCEDURE);

    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'p_returned_config_item_id='||TO_CHAR( p_returned_config_item_id),
     fnd_log.LEVEL_PROCEDURE);

    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'p_locked_instance_rev_nbr='||TO_CHAR(p_locked_instance_rev_nbr),
     fnd_log.LEVEL_PROCEDURE);

    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'p_application_id='||TO_CHAR(p_application_id),
     fnd_log.LEVEL_PROCEDURE);

    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'p_config_eff_date='||TO_CHAR(p_config_eff_date,'DD-MM-YYYY HH24:MI'),
     fnd_log.LEVEL_PROCEDURE);

   END IF;

   --
   -- initialize OUT variables
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_msg_count     := 0;
   x_msg_data      := NULL;

   --
   -- find returned_flag  of returned config item
   -- and validate parameters p_instance_hdr_id/ p_instance_rev_nbr/ p_returned_config_item_id
   --
   BEGIN
     SELECT config_hdr_id,config_rev_nbr,NVL(returned_flag, '0'), NVL(tangible_item_flag,'0')
       INTO l_config_hdr_id,l_config_rev_nbr,l_returned_flag, l_tangible_item_flag
       FROM CZ_CONFIG_ITEMS
      WHERE  instance_hdr_id=p_instance_hdr_id AND
             instance_rev_nbr=p_instance_rev_nbr AND
             config_item_id=p_returned_config_item_id AND
             deleted_flag='0';

     IF l_tangible_item_flag='0' THEN

       fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name, 'Config item instance_hdr_id/instance_rev_nbr/config_item_id = '||
       to_char(p_instance_hdr_id)||'/'||to_char(p_instance_rev_nbr)||'/'||to_char(p_returned_config_item_id)||
       ' is not tangible.');

       x_return_status := FND_API.G_RET_STS_ERROR;
       fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                 p_data  => x_msg_data);

       IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
          'Config item instance_hdr_id/instance_rev_nbr/config_item_id = '||
           to_char(p_instance_hdr_id)||'/'||to_char(p_instance_rev_nbr)||'/'||to_char(p_returned_config_item_id)||
           ' is not tangible.',
          fnd_log.LEVEL_ERROR);
       END IF;

       x_msg_data := 'Config item instance_hdr_id/instance_rev_nbr/config_item_id = '||
       to_char(p_instance_hdr_id)||'/'||to_char(p_instance_rev_nbr)||'/'||to_char(p_returned_config_item_id)||
       ' is not tangible.';

       RETURN;

     END IF;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
          fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name, 'Config item instance_hdr_id/instance_rev_nbr/config_item_id = '||
           to_char(p_instance_hdr_id)||'/'||to_char(p_instance_rev_nbr)||'/'||to_char(p_returned_config_item_id)||
           ' does not exist.');
          x_return_status := FND_API.G_RET_STS_ERROR;
          fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                    p_data  => x_msg_data);

          IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
              'Config item instance_hdr_id/instance_rev_nbr/config_item_id = '||
              to_char(p_instance_hdr_id)||'/'||to_char(p_instance_rev_nbr)||'/'||to_char(p_returned_config_item_id)||
              ' does not exist.',
              fnd_log.LEVEL_ERROR);
          END IF;

          x_msg_data := 'Config item instance_hdr_id/instance_rev_nbr/config_item_id = '||
            to_char(p_instance_hdr_id)||'/'||to_char(p_instance_rev_nbr)||'/'||to_char(p_returned_config_item_id)||
            ' does not exist.';

          RETURN;

   END;

    --
    -- find returned_flag of locked config item
    -- and validate parameters p_instance_hdr_id/ p_locked_instance_rev_nbr/ p_returned_config_item_id
    --
    IF p_locked_instance_rev_nbr IS NOT NULL OR p_locked_instance_rev_nbr<>0 THEN
     BEGIN
       SELECT NVL(returned_flag, '0') INTO l_locked_item_returned_flag FROM CZ_CONFIG_ITEMS
       WHERE  instance_hdr_id=p_instance_hdr_id AND
                       instance_rev_nbr=p_locked_instance_rev_nbr AND
                       config_item_id=p_returned_config_item_id AND
                       deleted_flag='0';
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
          fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name, 'Config item instance_hdr_id/instance_rev_nbr/config_item_id = '||
           to_char(p_instance_hdr_id)||'/'||to_char(p_locked_instance_rev_nbr)||'/'||to_char(p_returned_config_item_id)||
           ' does not exist.');
          x_return_status := FND_API.G_RET_STS_ERROR;
          fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                    p_data  => x_msg_data);

         IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
            'Locked config item instance_hdr_id/instance_rev_nbr/config_item_id = '||
             to_char(p_instance_hdr_id)||'/'||to_char(p_locked_instance_rev_nbr)||'/'||to_char(p_returned_config_item_id)||
             ' does not exist.',
            fnd_log.LEVEL_ERROR);
         END IF;

         x_msg_data := 'Locked config item instance_hdr_id/instance_rev_nbr/config_item_id = '||
           to_char(p_instance_hdr_id)||'/'||to_char(p_locked_instance_rev_nbr)||'/'||to_char(p_returned_config_item_id)||
            ' does not exist.';

         RETURN;

      END;
    END IF;

    -- if item was  not processed before
    -- then process it now
    --
    IF ( l_returned_flag='0' ) THEN
      --
      -- set returned_flag  to 1 for config_item corresponding to the returned tangible item
      --
      UPDATE CZ_CONFIG_ITEMS
         SET returned_flag = '1'
       WHERE instance_hdr_id=p_instance_hdr_id AND
             instance_rev_nbr=p_instance_rev_nbr AND
             config_item_id=p_returned_config_item_id AND
             deleted_flag='0';
    ELSE
      RETURN;
    END IF;

    IF (p_locked_instance_rev_nbr IS NOT NULL AND p_locked_instance_rev_nbr<>0) AND
      l_locked_item_returned_flag='0' THEN
      --
      -- set returned_flag  to 1 for config_item corresponding to the pending order
      --
      UPDATE CZ_CONFIG_ITEMS
         SET returned_flag = '1'
       WHERE instance_hdr_id=p_instance_hdr_id AND
             instance_rev_nbr= p_locked_instance_rev_nbr AND
             config_item_id=p_returned_config_item_id AND
             deleted_flag='0';
    END IF;

    -- do commit for the current autonomous transaction
    -- after that batch validation can see the change
    COMMIT;

    -- Batch Validation starts here --
    BEGIN
      -- populate array of instances which will be used as a parameter in cz_network_api_pub.generate_config_trees
      --
      l_config_tbl(1).config_hdr_id  := p_instance_hdr_id;
      l_config_tbl(1).config_rev_nbr := p_instance_rev_nbr;

      -- populate record structure of applicability parameters which will be used as a parameter in
      -- cz_network_api_pub.generate_config_trees
      --
      IF p_config_eff_date IS NOT NULL THEN
        l_appl_param_rec.config_effective_date      := p_config_eff_date ;
      ELSE
        l_appl_param_rec.config_effective_date      := SYSDATE;   -- pass SYSDATE as default for effective_date of instance
      END IF;

      IF p_application_id IS NOT NULL THEN
        l_appl_param_rec.calling_application_id     := p_application_id;
      ELSE
        l_appl_param_rec.calling_application_id     := 542;   -- caller is IB
      END IF;

      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
        'cz_network_api_pub.generate_config_trees() will be called.',
        fnd_log.LEVEL_PROCEDURE);
      END IF;

      --
      -- generate a new session hdr and
      -- call batch validation for configuration validating.
      -- This batch validate will be a new type of batch validate called VALIDATE_RETURN.
      -- We need this new type because in this mode we want to update the instance status but not save config
      -- item tree at all.  The instance will be marked as valid only if there was no contradiction on removing the
      -- returned item, the configuration is valid and complete and if there are no deltas from installed values
      --
      cz_network_api_pub.generate_config_trees
      (p_api_version           => 1.0,
       p_config_tbl            => l_config_tbl,
       p_tree_copy_mode        => CZ_API_PUB.G_NEW_HEADER_COPY_MODE,
       p_appl_param_rec        => l_appl_param_rec,
       p_validation_context    => CZ_API_PUB.G_INSTALLED,
       p_validation_type       => CZ_API_PUB.VALIDATE_RETURN,
       x_config_model_tbl      => l_config_model_tbl,
       x_return_status         => l_return_status,
       x_msg_count             => l_msg_count,
       x_msg_data              => l_msg_data);

       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
         'cz_network_api_pub.generate_config_trees() called been called return_status='||x_return_status,
         fnd_log.LEVEL_PROCEDURE);
       END IF;

     EXCEPTION
       WHEN OTHERS THEN
         l_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
         fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name, 'Fatal error : cz_network_api_pub.generate_config_trees() : '||SQLERRM);
         fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                   p_data  => x_msg_data);
         IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
           'Fatal error : cz_network_api_pub.generate_config_trees() : '||SQLERRM,
           FND_LOG.LEVEL_ERROR);
         END IF;
   END;

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

     UPDATE CZ_CONFIG_ITEMS
        SET returned_flag = l_returned_flag
      WHERE instance_hdr_id=p_instance_hdr_id AND
            instance_rev_nbr= p_instance_rev_nbr AND
            config_item_id=p_returned_config_item_id AND
            NVL(returned_flag, '0') <> l_returned_flag;

     UPDATE CZ_CONFIG_ITEMS
        SET returned_flag = l_locked_item_returned_flag
      WHERE instance_hdr_id=p_instance_hdr_id AND
            instance_rev_nbr= p_locked_instance_rev_nbr AND
            config_item_id=p_returned_config_item_id AND
            NVL(returned_flag, '0') <> l_locked_item_returned_flag;

     x_validation_status := fnd_api.g_false;

     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count     := x_msg_count + l_msg_count;
     x_msg_data      := l_msg_data;

   ELSE
     -- query for config status
     SELECT config_status INTO l_config_status FROM CZ_CONFIG_HDRS
     WHERE config_hdr_id=l_config_model_tbl(1).config_hdr_id AND
           config_rev_nbr=l_config_model_tbl(1).config_rev_nbr;
     -- convert  config status into fnd_api.g_true/ fnd_api.g_false OUT parameter x_validation_status
     --
     IF l_config_status<>'2' THEN -- '2' means that BATCH validation complete
       x_validation_status := fnd_api.g_false;
     ELSE
       BEGIN
         SELECT 'F' INTO x_validation_status FROM dual
         WHERE EXISTS(SELECT NULL FROM CZ_CONFIG_MESSAGES
                       WHERE config_hdr_id=l_config_model_tbl(1).config_hdr_id AND
                             config_rev_nbr=l_config_model_tbl(1).config_rev_nbr);
         x_validation_status := fnd_api.g_false;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           x_validation_status := fnd_api.g_true;
       END;
     END IF;

   END IF;

   COMMIT;

EXCEPTION
   WHEN OTHERS THEN
     -- raise fatal error (unexpected error ) , add a corresponding FND error message to error stack,
     -- populate x_msg_count and x_msg_data
     x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
     fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name, 'Fatal error : '||SQLERRM);
     fnd_msg_pub.count_and_get(p_count => x_msg_count,
                               p_data  => x_msg_data);
END remove_Returned_Config_Item;

END CZ_IB_TSO_GRP;

/
