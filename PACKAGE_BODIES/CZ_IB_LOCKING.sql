--------------------------------------------------------
--  DDL for Package Body CZ_IB_LOCKING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_IB_LOCKING" AS
/*	$Header: cziblckb.pls 120.3 2006/08/01 15:46:41 skudryav ship $*/

------------------------------------------------------------------------------------------

G_PKG_NAME   VARCHAR2(50) := 'CZ_IB_LOCKING';

FUNCTION is_Valid_Data
(
 p_config_session_hdr_id  IN  NUMBER,
 p_config_session_rev_nbr IN  NUMBER,
 p_config_session_item_id IN  NUMBER
) RETURN BOOLEAN IS

BEGIN
  IF p_config_session_item_id IS NULL THEN
    -- if p_config_session_item_id is not specified then
    -- check CZ_CONFIG_HDRS
    FOR i IN(SELECT 'x' FROM CZ_CONFIG_HDRS
              WHERE config_hdr_id=p_config_session_hdr_id AND
                    config_rev_nbr=p_config_session_rev_nbr AND
                    component_instance_type='R' AND
                    deleted_flag='0')
    LOOP
      RETURN TRUE;
    END LOOP;

  ELSE
    -- if p_config_session_item_id is specified then
    -- check CZ_CONFIG_DETAILS_V
    FOR i IN(SELECT 'x' FROM CZ_CONFIG_DETAILS_V
              WHERE config_hdr_id=p_config_session_hdr_id AND
                    config_rev_nbr=p_config_session_rev_nbr AND
                    config_item_id=p_config_session_item_id AND
                    component_instance_type='I' AND
                    ib_trackable='1')
    LOOP
      RETURN TRUE;
    END LOOP;

  END IF;

  RETURN FALSE;
END is_Valid_Data;

--
-- this procedure calls procedure CSI_CZ_INT.lock_item_instance()
-- for each instance with configuration specified by parameters
-- p_config_session_hdr_id, p_config_session_rev_nbr and p_config_session_item_id
-- others parameters are passed to CSI_CZ_INT.lock_item_instance() directly
--
PROCEDURE lock_Config
(
  p_api_version            IN  NUMBER,
  p_config_session_hdr_id  IN  NUMBER,
  p_config_session_rev_nbr IN  NUMBER,
  p_config_session_item_id IN  NUMBER,
  p_source_application_id  IN  NUMBER,
  p_source_header_ref      IN  VARCHAR2,
  p_source_line_ref1       IN  VARCHAR2,
  p_source_line_ref2       IN  VARCHAR2,
  p_source_line_ref3       IN  VARCHAR2,
  p_commit                 IN  VARCHAR2,
  p_init_msg_list          IN  VARCHAR2,
  p_validation_level       IN  NUMBER,
  x_locking_key            OUT NOCOPY NUMBER,
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2
) IS

  l_api_version  CONSTANT NUMBER := 1.0;
  l_api_name     CONSTANT VARCHAR2(30) := 'lock_Config';
  l_ndebug       NUMBER := 0;
BEGIN

  IF (NOT FND_API.compatible_api_call(l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,G_PKG_NAME
                                     )) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (p_init_msg_list = FND_API.G_TRUE) THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count     := 0;
  x_msg_data      := NULL;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'List of parameters : ',
    fnd_log.LEVEL_PROCEDURE);

    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'p_config_session_hdr_id='||TO_CHAR(p_config_session_hdr_id),
     fnd_log.LEVEL_PROCEDURE);

    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'p_config_session_rev_nbr='||TO_CHAR(p_config_session_rev_nbr),
     fnd_log.LEVEL_PROCEDURE);

    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'p_config_session_item_id='||TO_CHAR(p_config_session_item_id),
     fnd_log.LEVEL_PROCEDURE);

    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'p_source_application_id='||TO_CHAR(p_source_application_id),
     fnd_log.LEVEL_PROCEDURE);

    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'p_source_header_ref='||p_source_header_ref,
     fnd_log.LEVEL_PROCEDURE);

    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'p_source_line_ref1='||p_source_line_ref1,
     fnd_log.LEVEL_PROCEDURE);

    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'p_source_line_ref2='||p_source_line_ref2,
     fnd_log.LEVEL_PROCEDURE);

    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'p_source_line_ref3='||p_source_line_ref3,
     fnd_log.LEVEL_PROCEDURE);

    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'p_commit='||p_commit,
     fnd_log.LEVEL_PROCEDURE);

    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'p_init_msg_list='||p_init_msg_list,
     fnd_log.LEVEL_PROCEDURE);

    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'p_validation_level='||TO_CHAR(p_validation_level),
     fnd_log.LEVEL_PROCEDURE);

  END IF;

  --
  -- validate p_config_session_hdr_id,p_config_session_rev_nbr,p_config_session_item_id
  -- and if they are not valid then log error message and exit
  --
  IF NOT(is_Valid_Data (p_config_session_hdr_id,p_config_session_rev_nbr,p_config_session_item_id)) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name, 'Error : Invalid Data : '||
      'p_config_session_hdr_id/p_config_session_rev_nbr/p_config_session_item_id='||
       TO_CHAR(p_config_session_hdr_id)||'/'||TO_CHAR(p_config_session_rev_nbr)||'/'||TO_CHAR(p_config_session_item_id));
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
    x_msg_data :=  fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
       'Error : Invalid Data : p_config_session_hdr_id/p_config_session_rev_nbr/p_config_session_item_id='||
       TO_CHAR(p_config_session_hdr_id)||'/'||TO_CHAR(p_config_session_rev_nbr)||'/'||TO_CHAR(p_config_session_item_id),
       fnd_log.LEVEL_PROCEDURE);
    END IF;
    -- it's fatal error => exit
    RETURN;
  END IF;

  EXECUTE IMMEDIATE
 ' DECLARE ' ||
 '   TYPE number_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER; ' ||
 '   l_config_tbl         csi_cz_int.config_tbl; ' ||
 '   l_rec_counter        NUMBER := 0; ' ||
 '   l_ndebug             NUMBER := 0; ' ||
 ' BEGIN ' ||
 '   FOR i IN(SELECT instance_hdr_id,instance_rev_nbr, config_item_id FROM CZ_CONFIG_DETAILS_V  ' ||
 '            WHERE config_hdr_id=:1 AND ' ||
 '                  config_rev_nbr=:2 AND ' ||
 '                  config_item_id=NVL(:3, config_item_id) AND ' ||
 '                  component_instance_type=''I'' AND ' ||
 '                  ib_trackable=''1'') ' ||
 '   LOOP ' ||
 '     l_rec_counter := l_rec_counter + 1; ' ||
 '     l_config_tbl(l_rec_counter).source_application_id := :4; ' ||
 '     l_config_tbl(l_rec_counter).source_txn_header_ref := :5; ' ||
 '     l_config_tbl(l_rec_counter).source_txn_line_ref1  := :6; ' ||
 '     l_config_tbl(l_rec_counter).source_txn_line_ref2  := :7; ' ||
 '     l_config_tbl(l_rec_counter).source_txn_line_ref3  := :8; ' ||
 '     l_config_tbl(l_rec_counter).config_inst_hdr_id    := i.instance_hdr_id;  ' ||
 '     l_config_tbl(l_rec_counter).config_inst_item_id   := i.config_item_id; ' ||
 '     l_config_tbl(l_rec_counter).config_inst_rev_num   := i.instance_rev_nbr; ' ||
 '     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN ' ||
 '       cz_utils.log_report(''CZ_IB_LOCKING'', ''lock_Config'', l_ndebug, ' ||
 '       ''CSI_CZ_INT.lock_item_instances() will be called for instance_hdr_id=''||TO_CHAR(i.instance_hdr_id) || ' ||
 '       '' instance_rev_nbr=''||TO_CHAR(i.instance_rev_nbr)||'' config_item_id=''||TO_CHAR(i.config_item_id), ' ||
 '       fnd_log.LEVEL_PROCEDURE); ' ||
 '     END IF;    ' ||
 '   END LOOP; ' ||
 '   IF l_config_tbl.COUNT > 0 THEN '||
 '   CSI_CZ_INT.lock_item_instances(p_api_version       => 1.0 ' ||
 '                                  ,p_commit           => :9 ' ||
 '                                  ,p_init_msg_list    => :10 ' ||
 '                                  ,p_validation_level => :11 ' ||
 '                                  ,px_config_tbl      => l_config_tbl ' ||
 '                                  ,x_return_status    => CZ_IB_LOCKING.m_return_status ' ||
 '                                  ,x_msg_count        => CZ_IB_LOCKING.m_msg_count ' ||
 '                                  ,x_msg_data         => CZ_IB_LOCKING.m_msg_data); ' ||
 '   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN ' ||
 '       cz_utils.log_report(''CZ_IB_LOCKING'', ''lock_Config'', l_ndebug, ' ||
 '       ''CSI_CZ_INT.lock_item_instances() has been called : x_return_status=''||CZ_IB_LOCKING.m_return_status|| ' ||
 '       ''x_msg_count=''||to_char(CZ_IB_LOCKING.m_msg_count)||''x_msg_data=''||CZ_IB_LOCKING.m_msg_data, ' ||
 '       fnd_log.LEVEL_PROCEDURE); ' ||
 '   END IF;    ' ||
 '   END IF; '||
 ' END;' USING
        p_config_session_hdr_id,p_config_session_rev_nbr,p_config_session_item_id,
        p_source_application_id,p_source_header_ref,p_source_line_ref1,p_source_line_ref2,
        p_source_line_ref3,p_commit,p_init_msg_list,p_validation_level;

  IF CZ_IB_LOCKING.m_return_status IS NOT NULL THEN
    x_return_status   := CZ_IB_LOCKING.m_return_status;
    x_msg_count       := CZ_IB_LOCKING.m_msg_count;
    x_msg_data        := CZ_IB_LOCKING.m_msg_data;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);

    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
       'Unexpected error : '||fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE),
       fnd_log.LEVEL_ERROR);
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name, 'Fatal error : '||SQLERRM);
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
       'Fatal error : '||SQLERRM,
       fnd_log.LEVEL_ERROR);
    END IF;
END lock_Config;

--
-- this procedure calls procedure CSI_CZ_INT.unlock_item_instance()
-- for each instance with configuration specified by parameters
-- p_config_session_hdr_id, p_config_session_rev_nbr and p_config_session_item_id
-- others parameters are passed to CSI_CZ_INT.lock_item_instance() directly
--
PROCEDURE unlock_Config
  (
  p_api_version            IN  NUMBER,
  p_config_session_hdr_id  IN  NUMBER,
  p_config_session_rev_nbr IN  NUMBER,
  p_config_session_item_id IN  NUMBER,
  p_locking_key            IN  NUMBER,
  p_source_application_id  IN  NUMBER,
  p_source_header_ref      IN  VARCHAR2,
  p_source_line_ref1       IN  VARCHAR2,
  p_source_line_ref2       IN  VARCHAR2,
  p_source_line_ref3       IN  VARCHAR2,
  p_commit                 IN  VARCHAR2,
  p_init_msg_list          IN  VARCHAR2,
  p_validation_level       IN  NUMBER,
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2
  ) IS

  l_api_version  CONSTANT NUMBER := 1.0;
  l_api_name     CONSTANT VARCHAR2(30) := 'unlock_Config';
  l_ndebug       NUMBER := 1;
BEGIN

  IF (NOT FND_API.compatible_api_call(l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,G_PKG_NAME
                                     )) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (p_init_msg_list = FND_API.G_TRUE) THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count     := 0;
  x_msg_data      := NULL;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'List of parameters : ',
    fnd_log.LEVEL_PROCEDURE);

    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'p_config_session_hdr_id='||TO_CHAR(p_config_session_hdr_id),
     fnd_log.LEVEL_PROCEDURE);

    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'p_config_session_rev_nbr='||TO_CHAR(p_config_session_rev_nbr),
     fnd_log.LEVEL_PROCEDURE);

    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'p_config_session_item_id='||TO_CHAR(p_config_session_item_id),
     fnd_log.LEVEL_PROCEDURE);

    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'p_locking_key='||TO_CHAR(p_locking_key),
     fnd_log.LEVEL_PROCEDURE);

    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'p_source_application_id='||TO_CHAR(p_source_application_id),
     fnd_log.LEVEL_PROCEDURE);

    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'p_source_header_ref='||p_source_header_ref,
     fnd_log.LEVEL_PROCEDURE);

    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'p_source_line_ref1='||p_source_line_ref1,
     fnd_log.LEVEL_PROCEDURE);

    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'p_source_line_ref2='||p_source_line_ref2,
     fnd_log.LEVEL_PROCEDURE);

    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'p_source_line_ref3='||p_source_line_ref3,
     fnd_log.LEVEL_PROCEDURE);

    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'p_commit='||p_commit,
     fnd_log.LEVEL_PROCEDURE);

    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'p_init_msg_list='||p_init_msg_list,
     fnd_log.LEVEL_PROCEDURE);

    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'p_validation_level='||TO_CHAR(p_validation_level),
     fnd_log.LEVEL_PROCEDURE);

  END IF;

  --
  -- validate p_config_session_hdr_id,p_config_session_rev_nbr,p_config_session_item_id
  -- and if they are not valid then log error message and exit
  --
  IF NOT(is_Valid_Data (p_config_session_hdr_id,p_config_session_rev_nbr,p_config_session_item_id)) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name, 'Error : Invalid Data : '||
      'p_config_session_hdr_id/p_config_session_rev_nbr/p_config_session_item_id='||
       TO_CHAR(p_config_session_hdr_id)||'/'||TO_CHAR(p_config_session_rev_nbr)||'/'||TO_CHAR(p_config_session_item_id));
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
    x_msg_data :=  fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
       'Error : Invalid Data : p_config_session_hdr_id/p_config_session_rev_nbr/p_config_session_item_id='||
       TO_CHAR(p_config_session_hdr_id)||'/'||TO_CHAR(p_config_session_rev_nbr)||'/'||TO_CHAR(p_config_session_item_id),
       fnd_log.LEVEL_PROCEDURE);
    END IF;
    -- it's fatal error => exit
    RETURN;
  END IF;

  EXECUTE IMMEDIATE
'  DECLARE ' ||
'    TYPE number_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER; ' ||
'    l_config_tbl         csi_cz_int.config_tbl; ' ||
'    l_rec_counter        NUMBER := 0; ' ||
'    l_ndebug             NUMBER := 1; ' ||
'  BEGIN ' ||
'    FOR i IN(SELECT instance_hdr_id,instance_rev_nbr, config_item_id FROM CZ_CONFIG_DETAILS_V ' ||
'             WHERE config_hdr_id=:1 AND ' ||
'                   config_rev_nbr=:2 AND ' ||
'                   config_item_id=NVL(:3, config_item_id) AND ' ||
'                   component_instance_type=''I'' AND ' ||
'                   ib_trackable=''1'') ' ||
'    LOOP ' ||
'      l_rec_counter := l_rec_counter + 1; ' ||
'      l_config_tbl(l_rec_counter).source_application_id := :4;   ' ||
'      l_config_tbl(l_rec_counter).source_txn_header_ref := :5; ' ||
'      l_config_tbl(l_rec_counter).source_txn_line_ref1  := :6;    ' ||
'      l_config_tbl(l_rec_counter).source_txn_line_ref2  := :7;   ' ||
'      l_config_tbl(l_rec_counter).source_txn_line_ref3  := :8;   ' ||
'      l_config_tbl(l_rec_counter).lock_id	              := :9; ' ||
'      l_config_tbl(l_rec_counter).config_inst_hdr_id    := i.instance_hdr_id;     ' ||
'      l_config_tbl(l_rec_counter).config_inst_item_id   := i.config_item_id;    ' ||
'      l_config_tbl(l_rec_counter).config_inst_rev_num   := i.instance_rev_nbr;    ' ||
'      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN ' ||
'        cz_utils.log_report(''CZ_IB_LOCKING'', ''unlock_Config'', l_ndebug, ' ||
'        ''CSI_CZ_INT.unlock_item_instances() will be called for instance_hdr_id=''||TO_CHAR(i.instance_hdr_id)|| ' ||
'        '' instance_rev_nbr=''||TO_CHAR(i.instance_rev_nbr)||'' config_item_id=''||TO_CHAR(i.config_item_id), ' ||
'        fnd_log.LEVEL_PROCEDURE); ' ||
'      END IF; ' ||
'    END LOOP; ' ||
'    IF l_config_tbl.COUNT > 0 THEN '||
'    CSI_CZ_INT.unlock_item_instances(p_api_version       => 1.0 ' ||
'                                     ,p_commit           => :10 ' ||
'                                     ,p_init_msg_list    => :11 ' ||
'                                     ,p_validation_level => :12 ' ||
'                                     ,p_config_tbl       => l_config_tbl ' ||
'                                     ,x_return_status    => CZ_IB_LOCKING.m_return_status ' ||
'                                     ,x_msg_count        => CZ_IB_LOCKING.m_msg_count ' ||
'                                     ,x_msg_data         => CZ_IB_LOCKING.m_msg_data); ' ||
'    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN ' ||
'        cz_utils.log_report(''CZ_IB_LOCKING'', ''unlock_Config'', l_ndebug, ' ||
'        ''CSI_CZ_INT.unlock_item_instances() has been called : x_return_status=''||CZ_IB_LOCKING.m_return_status|| ' ||
'        ''x_msg_count=''||to_char(CZ_IB_LOCKING.m_msg_count)||''x_msg_data=''||CZ_IB_LOCKING.m_msg_data, ' ||
'        fnd_log.LEVEL_PROCEDURE); ' ||
'    END IF;    ' ||
'    END IF; '||
'  END;' USING
        p_config_session_hdr_id,p_config_session_rev_nbr,p_config_session_item_id,
        p_source_application_id,p_source_header_ref,p_source_line_ref1,p_source_line_ref2,
        p_source_line_ref3,p_locking_key,p_commit,p_init_msg_list,p_validation_level;

  IF CZ_IB_LOCKING.m_return_status IS NOT NULL THEN
    x_return_status   := CZ_IB_LOCKING.m_return_status;
    x_msg_count       := CZ_IB_LOCKING.m_msg_count;
    x_msg_data        := CZ_IB_LOCKING.m_msg_data;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
       'Unexpected error : '||fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE),
       fnd_log.LEVEL_ERROR);
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name, 'Fatal error : '||SQLERRM);
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
       'Fatal error : '||SQLERRM,
       fnd_log.LEVEL_ERROR);
    END IF;
END unlock_Config;

END;

/
