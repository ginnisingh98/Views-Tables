--------------------------------------------------------
--  DDL for Package Body CN_IMP_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_IMP_RULE_PVT" AS
-- $Header: cnvimrlb.pls 120.3 2005/08/07 23:04:16 vensrini noship $


G_PKG_NAME             CONSTANT VARCHAR2(30) := 'CN_IMP_RULE_PVT';
G_FILE_NAME            CONSTANT VARCHAR2(12) := 'cnvimrlb.pls';
G_INVALID_IMP_LINE_ID  CONSTANT NUMBER       := -99999;

-- Start of comments
--    API name        : Rules_Import
--    Type            : Private.
--    Function        : program to transfer data from staging table into
--                      cn_rulesets, cn_rules, cn_attributes, cn_rules_hierarchy
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_imp_header_id           IN    NUMBER  Required
--    OUT             : errbuf                    OUT VARCHAR2  Required
--                      retcode                   OUT VARCHAR2  Optional
--    Version :         Current version       1.0
--
--    Notes           : Note text
--
-- End of comments
PROCEDURE Rules_Import
 ( errbuf                     OUT NOCOPY   VARCHAR2,
   retcode                    OUT NOCOPY   VARCHAR2,
   p_imp_header_id            IN    NUMBER,
   p_org_id                   IN NUMBER
 ) IS
      l_api_name             CONSTANT VARCHAR2(30) := 'Rules_Import';

      l_stage_status         cn_imp_lines.status_code%TYPE := 'STAGE';
      l_imp_header           cn_imp_headers_pvt.imp_headers_rec_type	:= cn_imp_headers_pvt.G_MISS_IMP_HEADERS_REC;
      l_processed_row        NUMBER := 0;
      l_failed_row           NUMBER := 0;
      l_message              VARCHAR2(4000);
      l_error_code           VARCHAR2(30);
      err_num                NUMBER;
      l_return_status        VARCHAR2(50);
      l_msg_count            NUMBER := 0;
      l_loading_status       VARCHAR2(30);
      x_loading_status       VARCHAR2(30);
      l_process_audit_id     cn_process_audits.process_audit_id%TYPE;
      l_current_ruleset_id   NUMBER;
      l_current_imp_line_id  NUMBER;
      l_temp_count           NUMBER := 0;
      l_ruleset_rec          CN_Ruleset_PVT.ruleset_rec_type;
      l_err_imp_line_id      NUMBER;
      l_org_id NUMBER;

    -- Cursor to check if the ruleset is present in the system
    CURSOR c_is_ruleset_present_csr (l_name cn_rulesets.name%TYPE, l_start_date cn_rulesets.start_date%TYPE, l_end_date cn_rulesets.end_date%TYPE, l_module_type cn_rulesets.module_type%TYPE) IS
     SELECT ruleset_id
      FROM cn_rulesets
      WHERE name = l_name
       AND start_date = l_start_date
       AND end_date = l_end_date
       AND module_type = l_module_type
       AND org_id=p_org_id;

    -- Cursor to get start date, end_date, ruleset type for the specified ruleset name
     CURSOR c_ruleset_details_csr IS
	SELECT ruleset_name, start_date, end_date, ruleset_type
	  FROM CN_RULES_IMP_V
	  WHERE imp_header_id = p_imp_header_id
	  AND status_code = l_stage_status
	  GROUP BY ruleset_name, start_date, end_date, ruleset_type
	  ORDER BY start_date;

    detail_rec c_ruleset_details_csr%ROWTYPE;

BEGIN
   --  Initialize API return status to success
   l_return_status  := FND_API.G_RET_STS_SUCCESS;
   retcode := 0;
   l_org_id:=p_org_id;

   -- Get imp_header info
   SELECT imp_header_id, name, status_code,server_flag,imp_map_id, source_column_num, import_type_code
     INTO l_imp_header.imp_header_id,l_imp_header.name ,l_imp_header.status_code, l_imp_header.server_flag,
     l_imp_header.imp_map_id, l_imp_header.source_column_num,l_imp_header.import_type_code
     FROM cn_imp_headers
     WHERE imp_header_id = p_imp_header_id;

   -- open process audit batch
   cn_message_pkg.begin_batch
     ( x_process_type	       => l_imp_header.import_type_code,
     x_parent_proc_audit_id  => l_imp_header.imp_header_id,
     x_process_audit_id      =>  l_process_audit_id,
     x_request_id	           => null,
     p_org_id =>l_org_id);

   cn_message_pkg.write
     (p_message_text => 'RULES: Start Transfer Data. imp_header_id = ' || To_char(p_imp_header_id),
      p_message_type => 'MILESTONE');

   -- get the details for the ruleset
   FOR  detail_rec IN c_ruleset_details_csr LOOP
      cn_message_pkg.debug('Rules_Import: #### START OF ruleset for loop');

      -- check for the required fields
      IF (detail_rec.ruleset_name IS NULL) OR (detail_rec.start_date IS NULL) OR (detail_rec.end_date IS NULL) OR
	(detail_rec.ruleset_type IS NULL) OR (detail_rec.ruleset_type <>'REVCLS' AND detail_rec.ruleset_type <> 'ACCGEN') THEN
	 cn_message_pkg.debug('Rules_Import: Failed Test : All the required fields have not been entered');
	 cn_message_pkg.debug('Rules_Import: detail_rec.ruleset_name: ' || detail_rec.ruleset_name);
	 cn_message_pkg.debug('Rules_Import: detail_rec.start_date: ' || detail_rec.start_date);
	 cn_message_pkg.debug('Rules_Import: detail_rec.end_date: ' || detail_rec.end_date);
	 cn_message_pkg.debug('Rules_Import: detail_rec.ruleset_type: ' || detail_rec.ruleset_type);

	 update_imp_lines
	   (p_status        => 'FAIL',
	    p_imp_line_id   => G_INVALID_IMP_LINE_ID,
	    p_ruleset_name  => detail_rec.ruleset_name,
	    p_start_date    => detail_rec.start_date,
	    p_end_date      => detail_rec.end_date,
	    p_ruleset_type  => detail_rec.ruleset_type,
	    p_head_id       => l_imp_header.imp_header_id,
	    p_error_code    => 'CN_IMP_MISS_REQUIRED',
	    p_error_mssg    => fnd_message.get_string('CN','CN_IMP_MISS_REQUIRED'),
	    x_failed_row    => l_failed_row,
	    x_processed_row => l_processed_row);
	 GOTO end_of_ruleset_loop;
      END IF;

      -- the length is as specified in the JSP
      IF LENGTH(detail_rec.ruleset_name) > 60 THEN
	 cn_message_pkg.debug('ERROR: Ruleset Name too long');

	 update_imp_lines
	   (p_status        => 'FAIL',
	    p_imp_line_id   => G_INVALID_IMP_LINE_ID,
	    p_ruleset_name  => detail_rec.ruleset_name,
	    p_start_date    => detail_rec.start_date,
	    p_end_date      => detail_rec.end_date,
	    p_ruleset_type  => detail_rec.ruleset_type,
	    p_head_id       => l_imp_header.imp_header_id,
	    p_error_code    => 'CN_RULESET_NAME_TOO_LONG',
	    p_error_mssg    => fnd_message.get_string('CN','CN_RULESET_NAME_TOO_LONG'),
	    x_failed_row    => l_failed_row,
	    x_processed_row => l_processed_row);
	 GOTO end_of_ruleset_loop;
      END IF;

      l_ruleset_rec.ruleset_name := detail_rec.ruleset_name;
      l_ruleset_rec.org_id:=p_org_id;
      BEGIN
	 l_ruleset_rec.start_date   := TO_DATE (detail_rec.start_date,'DD/MM/YYYY');
	 l_ruleset_rec.end_date     := TO_DATE (detail_rec.end_date,'DD/MM/YYYY');
      EXCEPTION
	 WHEN OTHERS THEN
	    cn_message_pkg.debug('### IMP ### EXCEPTION : error parsing date');

	    update_imp_lines
	      (p_status        => 'FAIL',
	       p_imp_line_id   => G_INVALID_IMP_LINE_ID,
	       p_ruleset_name  => detail_rec.ruleset_name,
	       p_start_date    => detail_rec.start_date,
	       p_end_date      => detail_rec.end_date,
	       p_ruleset_type  => detail_rec.ruleset_type,
	       p_head_id       => l_imp_header.imp_header_id,
	       p_error_code    => 'CN_IMP_INVLD_RULESET_DATE',
	       p_error_mssg    => fnd_message.get_string('CN','CN_IMP_INVLD_RULESET_DATE'),
	       x_failed_row    => l_failed_row,
	       x_processed_row => l_processed_row);
            GOTO end_of_ruleset_loop;
      END;
      l_ruleset_rec.module_type  := detail_rec.ruleset_type;

      -- this is to check if the ruleset is present. If yes then it is assumed that the ruleset is
      -- being updated, i.e rules are being added.
      -- Ref: BUG: 2403038
      OPEN c_is_ruleset_present_csr (l_ruleset_rec.ruleset_name, l_ruleset_rec.start_date, l_ruleset_rec.end_date, l_ruleset_rec.module_type);
      FETCH c_is_ruleset_present_csr INTO l_current_ruleset_id;
      IF c_is_ruleset_present_csr%NOTFOUND THEN
	 l_current_ruleset_id := 0;
      END IF;
      CLOSE c_is_ruleset_present_csr;

      cn_message_pkg.debug('value of l_current_ruleset_id:' || l_current_ruleset_id);

      IF l_current_ruleset_id = 0 THEN
	 l_return_status := FND_API.G_RET_STS_SUCCESS;
	 cn_message_pkg.debug('Rules_Import: Before calling CN_RULESET_PVT.create_ruleset, ruleset name: ' || detail_rec.ruleset_name);

	 CN_RULESET_PVT.create_ruleset
	   ( p_api_version      => 1.0,
	     p_init_msg_list	=> fnd_api.g_true,
	     p_commit	    	=> FND_API.G_FALSE,
	     p_validation_level => FND_API.G_VALID_LEVEL_FULL,
	     x_return_status    => l_return_status,
	     x_msg_count        => l_msg_count,
	     x_msg_data	        => l_message,
	     x_loading_status   => l_loading_status,
	     x_ruleset_id       => l_current_ruleset_id,
	     p_ruleset_rec      => l_ruleset_rec);

	 cn_message_pkg.debug('Rules_Import: After CN_RULESET_PVT.create_ruleset call, return status: ' || l_return_status);
	 cn_message_pkg.debug('After CN_RULESET_PVT.create_ruleset call, l_message: ' || l_message);

	 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	    cn_message_pkg.debug('Rules_Import: Error after returning from CN_RULESET_PVT.create_ruleset');
	    retcode := 2;
	    errbuf:= l_message;
	    -- update all the rows related to the ruleset with a general message
	    update_imp_lines
	      (p_status        => 'FAIL',
	       p_imp_line_id   => G_INVALID_IMP_LINE_ID,
	       p_ruleset_name  => detail_rec.ruleset_name,
	       p_start_date    => detail_rec.start_date,
	       p_end_date      => detail_rec.end_date,
	       p_ruleset_type  => detail_rec.ruleset_type,
	       p_head_id       => l_imp_header.imp_header_id,
	       p_error_code    => 'CN_IMP_INVLD_RULESET',
	       p_error_mssg    => l_message || ' ' || fnd_message.get_string('CN','CN_IMP_INVLD_RULESET'),
	       x_failed_row    => l_failed_row,
	       x_processed_row => l_processed_row);

	    GOTO end_of_ruleset_loop;
	    cn_message_pkg.write
	      (p_message_text => 'Completed creating a ruleset, name: ' || detail_rec.ruleset_name,
	       p_message_type => 'MILESTONE');
	 END IF;
       ELSE
         cn_message_pkg.debug('Ruleset exists in the Database');
      END IF; -- end IF l_current_ruleset_id = 0 THEN

      l_err_imp_line_id := NULL;

      cn_message_pkg.debug('Rules_Import: Before call to load_rules, ruleset: ' || detail_rec.ruleset_name);
      -- now process the rules for this ruleset
      load_rules
	(p_ruleset_id         => l_current_ruleset_id,
	 p_ruleset_name       => detail_rec.ruleset_name,
	 p_ruleset_start_date => detail_rec.start_date,
	 p_ruleset_end_date   => detail_rec.end_date,
	 p_ruleset_type       => detail_rec.ruleset_type,
	 p_imp_header         => l_imp_header,
	 x_err_mssg           => errbuf,
	 x_retcode            => retcode,
	 x_imp_line_id        => l_err_imp_line_id,
	 x_failed_row    => l_failed_row,
	 x_processed_row => l_processed_row,
	 p_org_id        => l_org_id);

      cn_message_pkg.debug('Rules_Import: After loading rules, x_retcode: ' || retcode);

      IF retcode = 2 THEN
         cn_message_pkg.debug('Error loading rules, ruleset: ' || detail_rec.ruleset_name);
	 GOTO end_of_ruleset_loop;
      END IF;

      cn_message_pkg.debug('Rules_Import: After call to load_rules, ruleset :' || detail_rec.ruleset_name);
      cn_message_pkg.debug ('Rules_Import: Before synchronize, l_current_ruleset_id  :' || l_current_ruleset_id);

      IF CN_Ruleset_PVT.check_sync_allowed
           ( detail_rec.ruleset_name,
             l_current_ruleset_id,
	     l_org_id,
             x_loading_status,
             x_loading_status ) = fnd_api.g_true
           THEN
             cn_message_pkg.debug ('Rules_Import: Error synchronizing the ruleset  :' || detail_rec.ruleset_name);
	     GOTO end_of_ruleset_loop;

      END IF;
      -- synchronize the package
      cn_rulesets_pkg.Sync_ruleset
        (x_ruleset_id_in     => l_current_ruleset_id,
         x_ruleset_status_in => l_return_status,
	 x_org_id => l_org_id);

      cn_message_pkg.debug ('Rules_Import: Completed synchronize, l_return_status  :' || l_return_status);
      IF l_return_status = 'UNSYNC' THEN
	 cn_message_pkg.debug ('Rules_Import: Error synchronizing the ruleset  :' || detail_rec.ruleset_name);
	 GOTO end_of_ruleset_loop;
      END IF;

      cn_message_pkg.debug ('Rules_Import: Classify the l_current_ruleset_id: ' || l_current_ruleset_id);
      cn_classification_gen.Classification_Install
	(x_errbuf  => l_message,
	 x_retcode => l_return_status,
	 x_ruleset_id => l_current_ruleset_id,
	 x_org_id => l_org_id);

      cn_message_pkg.debug ('Rules_Import: value returned by cn_classification_gen.Classification_Install: ' || l_return_status);
      IF l_return_status = 1 THEN
	 cn_message_pkg.debug ('Rules_Import: Error classifying the ruleset: ' || detail_rec.ruleset_name);
	 GOTO end_of_ruleset_loop;
       ELSE
	 cn_message_pkg.debug ('Rules_Import: No errors for this ruleset COMMIT: ' || detail_rec.ruleset_name);
	 update_imp_lines
	   (p_status        => 'COMPLETE',
	    p_imp_line_id   => G_INVALID_IMP_LINE_ID,
	    p_ruleset_name  => detail_rec.ruleset_name,
	    p_start_date    => detail_rec.start_date,
	    p_end_date      => detail_rec.end_date,
	    p_ruleset_type  => detail_rec.ruleset_type,
	    p_head_id       => l_imp_header.imp_header_id,
	    p_error_code    => '',
	    p_error_mssg    => '',
	    x_failed_row    => l_failed_row,
	    x_processed_row => l_processed_row);

	 cn_message_pkg.write
           (p_message_text => 'Completed Synchronizing Ruleset name = ' || detail_rec.ruleset_name,
            p_message_type => 'MILESTONE');
      END IF;

      <<end_of_ruleset_loop>>
        NULL;
      -- ruleset complete
      COMMIT;
   END LOOP; -- end of  ruleset cursor

   cn_message_pkg.debug ('Rules_Import: #### OUTSIDE THE LOOP, retcode: ' || retcode);

   IF retcode = 2 THEN
      CN_IMPORT_PVT.update_imp_headers
	(p_imp_header_id => p_imp_header_id,
	 p_status_code => 'IMPORT_FAIL',
	 p_processed_row => l_processed_row,
	 p_failed_row => l_failed_row);
    ELSE
      CN_IMPORT_PVT.update_imp_headers
	(p_imp_header_id => p_imp_header_id,
	 p_status_code => 'COMPLETE',
	 p_processed_row => l_processed_row,
	 p_failed_row => l_failed_row);
   END IF;

   cn_message_pkg.write
     (p_message_text => 'Completed Transfer of data from staging table to destination tables for imp_header_id = ' || To_char(p_imp_header_id),
      p_message_type => 'MILESTONE');

   -- close process batch
   cn_message_pkg.end_batch(l_process_audit_id);

EXCEPTION
   WHEN OTHERS THEN
      cn_message_pkg.debug ('### IMP ### EXCEPTION : ERROR CODE: ' || SQLCODE);
      cn_message_pkg.debug ('ERROR MESSAGE: ' || SQLERRM);
      err_num :=  SQLCODE;
      IF err_num = -6501 THEN
	 retcode := 2;
	 errbuf := SQLERRM;
       ELSE
	 retcode := 2 ;
	 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
	 END IF;
	 FND_MSG_PUB.count_and_get
	   (p_count   =>  l_msg_count,
	    p_data    =>  errbuf,
	    p_encoded => FND_API.G_FALSE);
      END IF;

      CN_IMPORT_PVT.update_imp_headers
	(p_imp_header_id => p_imp_header_id,
	 p_status_code => 'IMPORT_FAIL',
	 p_processed_row => l_processed_row,
	 p_failed_row => l_failed_row);

      cn_message_pkg.set_error(l_api_name,errbuf);
      cn_message_pkg.end_batch(l_process_audit_id);

END Rules_Import;

-- --------------------------------------------------------+
--  seterr_imp_rules
--
--  This procedure will set error in cn_imp_lines(cn_rules_imp_v)
--  with passed in status and error code
-- --------------------------------------------------------+
PROCEDURE seterr_imp_rules
 (p_status        IN VARCHAR2,
  p_ruleset_name  IN VARCHAR2,
  p_ruleset_start_date    IN VARCHAR2,
  p_ruleset_end_date      IN VARCHAR2,
  p_ruleset_type  IN VARCHAR2,
  p_rule_name     IN VARCHAR2 := FND_API.g_miss_char,
  p_parent_rule_name IN VARCHAR2 := FND_API.g_miss_char,
  p_level_num     IN VARCHAR2 := FND_API.g_miss_char,
  p_expense_code    IN VARCHAR2 := FND_API.g_miss_char,
  p_liability_code  IN VARCHAR2 := FND_API.g_miss_char,
  p_revcls_name  IN VARCHAR2 := FND_API.g_miss_char,
  p_head_id       IN NUMBER,
  p_error_code    IN VARCHAR2,
  p_error_mssg    IN VARCHAR2,
  x_failed_row    IN OUT NOCOPY NUMBER,
  x_processed_row IN OUT NOCOPY NUMBER)
  IS PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   UPDATE cn_rules_imp_v
     SET status_code=p_status, error_code=p_error_code, error_msg=p_error_mssg
     WHERE  nvl(ruleset_name,FND_API.g_miss_char) = nvl(p_ruleset_name ,FND_API.g_miss_char)
     AND nvl(start_date ,FND_API.g_miss_char)  = nvl(p_ruleset_start_date, FND_API.g_miss_char)
     AND nvl(end_date,FND_API.g_miss_char)     = nvl(p_ruleset_end_date, FND_API.g_miss_char)
     AND nvl(ruleset_type,FND_API.g_miss_char) = nvl(p_ruleset_type, FND_API.g_miss_char)
     AND Nvl(rule_name,FND_API.g_miss_char)  =
     Decode(p_rule_name,NULL, FND_API.g_miss_char,
	    FND_API.g_miss_char,Nvl(rule_name,FND_API.g_miss_char),
	    p_rule_name)
     AND Nvl(parent_rule_name,FND_API.g_miss_char)  =
     Decode(p_parent_rule_name,NULL, FND_API.g_miss_char,
	    FND_API.g_miss_char,Nvl(parent_rule_name,FND_API.g_miss_char),
	    p_parent_rule_name)
     AND Nvl(level_num,FND_API.g_miss_char)  =
     Decode(p_level_num,NULL, FND_API.g_miss_char,
	    FND_API.g_miss_char,Nvl(level_num,FND_API.g_miss_char),
	    p_level_num)
     AND Nvl(expense_code,FND_API.g_miss_char)  =
     Decode(p_expense_code,NULL, FND_API.g_miss_char,
	    FND_API.g_miss_char,Nvl(expense_code,FND_API.g_miss_char),
	    p_expense_code)
     AND Nvl(liability_code,FND_API.g_miss_char)  =
     Decode(p_liability_code,NULL, FND_API.g_miss_char,
	    FND_API.g_miss_char,Nvl(liability_code,FND_API.g_miss_char),
	    p_liability_code)
     AND Nvl(revenue_class_name,FND_API.g_miss_char)  =
     Decode(p_revcls_name,NULL, FND_API.g_miss_char,
	    FND_API.g_miss_char,Nvl(revenue_class_name,FND_API.g_miss_char),
	    p_revcls_name)
     AND imp_header_id                         = p_head_id
     AND  status_code = 'STAGE'
     ;

   x_failed_row := x_failed_row + SQL%rowcount;
   x_processed_row := x_processed_row + SQL%rowcount;

   IF (SQL%ROWCOUNT=0) THEN
      RAISE NO_DATA_FOUND;
   END IF;
   COMMIT;

   CN_IMPORT_PVT.update_imp_headers
     (p_imp_header_id => p_head_id,
      p_status_code => 'IMPORT_FAIL',
      p_failed_row => x_failed_row,
      p_processed_row => x_processed_row);

END seterr_imp_rules;

--
-- Creat a new entry in the ruleset table
--
PROCEDURE load_rules
( p_ruleset_id   IN NUMBER,
  p_ruleset_name IN VARCHAR2,
  p_ruleset_start_date IN VARCHAR,
  p_ruleset_end_date IN VARCHAR,
  p_ruleset_type IN VARCHAR,
  p_imp_header   IN cn_imp_headers_pvt.imp_headers_rec_type,
  x_err_mssg     OUT NOCOPY VARCHAR2,
  x_retcode      OUT NOCOPY VARCHAR2,
  x_imp_line_id  OUT NOCOPY NUMBER,
  x_failed_row    IN OUT NOCOPY NUMBER,
  x_processed_row IN OUT NOCOPY NUMBER,
  p_org_id IN NUMBER
) IS
   l_api_name            CONSTANT VARCHAR2(30) := 'load_rules';
   l_stage_status        cn_imp_lines.status_code%TYPE := 'STAGE';
   l_loading_status      VARCHAR2(30);
   l_return_status       VARCHAR2(30);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(4000);
   l_rule_rec            cn_rule_pvt.rule_rec_type;
   l_current_rule_id     NUMBER;
   l_error_code          VARCHAR2(30);
   l_current_imp_line_id NUMBER;
   l_temp_count          NUMBER := 0;
   l_value_found         NUMBER;
   l_org_id NUMBER;

   -- cursor to get the number of entries that have no rule name
   CURSOR c_null_rule_name_csr IS
      SELECT count(*)
	FROM CN_RULES_IMP_V
	WHERE imp_header_id = p_imp_header.imp_header_id
	AND status_code     = l_stage_status
	AND ruleset_name    = p_ruleset_name
	AND start_date      = p_ruleset_start_date
	AND end_date        = p_ruleset_end_date
	AND ruleset_type    = p_ruleset_type
	AND rule_name IS NULL;

   CURSOR c_null_level_num_csr IS
      SELECT count(*)
	FROM CN_RULES_IMP_V
	WHERE imp_header_id = p_imp_header.imp_header_id
	AND status_code     = l_stage_status
	AND ruleset_name    = p_ruleset_name
	AND start_date      = p_ruleset_start_date
	AND end_date        = p_ruleset_end_date
	AND ruleset_type    = p_ruleset_type
	AND level_num IS NULL;

	-- Cursor to get rules of the ruleset
	CURSOR c_rule_name_csr IS
	   SELECT distinct(rule_name) rule_name, parent_rule_name, level_num
	     FROM CN_RULES_IMP_V
	     WHERE imp_header_id = p_imp_header.imp_header_id
	     AND status_code     = l_stage_status
	     AND ruleset_name    = p_ruleset_name
	     AND start_date      = p_ruleset_start_date
	     AND end_date        = p_ruleset_end_date
	     AND ruleset_type    = p_ruleset_type
	     GROUP BY rule_name, parent_rule_name, level_num
	     ORDER BY level_num;

	-- Cursor to check unique of revenue_class_name, expense_code,
	-- liability_code
	CURSOR c_rules_dtl_csr (l_name cn_rules_imp_v.rule_name%TYPE, l_parent_rule_name cn_rules_imp_v.parent_rule_name%TYPE, l_level_num cn_rules_imp_v.level_num%TYPE) IS
	   SELECT COUNT(1) FROM
	     (SELECT revenue_class_name, expense_code, liability_code
	      FROM CN_RULES_IMP_V
	      WHERE imp_header_id = p_imp_header.imp_header_id
	      AND status_code     = l_stage_status
	      AND ruleset_name    = p_ruleset_name
	      AND start_date      = p_ruleset_start_date
	      AND end_date        = p_ruleset_end_date
	      AND ruleset_type    = p_ruleset_type
	      AND rule_name       = l_name
	      AND level_num       = l_level_num
	      AND nvl(parent_rule_name,FND_API.g_miss_char) = nvl(l_parent_rule_name,FND_API.g_miss_char)
	      GROUP BY revenue_class_name, expense_code, liability_code) v1;

	-- Cursor to get rules details of the ruleset
	CURSOR c_rules_csr (l_name cn_rules_imp_v.rule_name%TYPE, l_parent_rule_name cn_rules_imp_v.parent_rule_name%TYPE, l_level_num cn_rules_imp_v.level_num%TYPE) IS
	   SELECT revenue_class_name, expense_code, liability_code
	     FROM CN_RULES_IMP_V
	     WHERE imp_header_id = p_imp_header.imp_header_id
	     AND status_code     = l_stage_status
	     AND ruleset_name    = p_ruleset_name
	     AND start_date      = p_ruleset_start_date
	     AND end_date        = p_ruleset_end_date
	     AND ruleset_type    = p_ruleset_type
	     AND rule_name       = l_name
	     AND level_num       = l_level_num
	     AND nvl(parent_rule_name,FND_API.g_miss_char) = nvl(l_parent_rule_name,FND_API.g_miss_char);

	-- Cursor to get the rule id given the rule name
	CURSOR c_parent_rule_csr (l_name cn_rules.name%TYPE) IS
	   SELECT rule_id
	     FROM CN_RULES
	     WHERE name = l_name
	     AND ruleset_id=p_ruleset_id
	     AND org_id=p_org_id;

	-- Cursor to get the revenue class id, given the revenue class name
	CURSOR c_revenue_id_csr (l_name cn_revenue_classes.name%TYPE) IS
	   SELECT revenue_class_id
	     FROM cn_revenue_classes
	     WHERE name = l_name
	     and org_id=p_org_id;

	-- cursor to get the liability code id
	--CURSOR c_liability_code_csr (l_name cn_rule_account_code_v.CODE_DESCRIPTION%TYPE) IS
	CURSOR c_liability_code_csr (l_name varchar2) IS
	   SELECT code_combination_id
	     FROM (SELECT
  			gl.code_combination_id code_combination_id ,
  			cn_api.get_ccid_disp_func(gl.code_combination_id,r.org_id) code_description,
  			gl.account_type account_type
		   FROM
			gl_code_combinations gl ,
  			cn_repositories r ,
  			gl_sets_of_books gls
		   WHERE
                        r.set_of_books_id = gls.set_of_books_id and
                        gls.chart_of_accounts_id = gl.chart_of_accounts_id
                        AND r.org_id=p_org_id)
	     WHERE account_type ='L'
	     AND code_description = l_name;

	-- cursor to get the expense code id
	CURSOR c_expense_code_csr (l_name varchar2) IS
	   SELECT code_combination_id
	     FROM (SELECT
  			gl.code_combination_id code_combination_id ,
  			cn_api.get_ccid_disp_func(gl.code_combination_id,r.org_id) code_description,
  			gl.account_type account_type
		   FROM
			gl_code_combinations gl ,
  			cn_repositories r ,
  			gl_sets_of_books gls
		   WHERE
                        r.set_of_books_id = gls.set_of_books_id and
                        gls.chart_of_accounts_id = gl.chart_of_accounts_id
                        AND r.org_id=p_org_id)
	     WHERE account_type = 'E'
	     AND code_description = l_name;

	rules_rec c_rules_csr%ROWTYPE;
	expns_row c_expense_code_csr%ROWTYPE;
	liabl_row c_liability_code_csr%ROWTYPE;
	parent_rul_row c_parent_rule_csr%ROWTYPE;
	revenue_row c_revenue_id_csr%ROWTYPE;
BEGIN
  x_retcode := 0;
  l_org_id:=p_org_id;
  -- Check rule_name cannot null
  OPEN c_null_rule_name_csr;
  FETCH c_null_rule_name_csr INTO l_temp_count;
  CLOSE c_null_rule_name_csr;

  IF l_temp_count > 0 THEN
     cn_message_pkg.debug ('Ruleset has rules with no rules name/null value');
     x_err_mssg := fnd_message.get_string('CN','CN_INVLD_RULE_NAME');
     x_retcode := 2;
     x_imp_line_id := G_INVALID_IMP_LINE_ID;
     l_error_code := 'CN_INVLD_RULE_NAME';
     seterr_imp_rules
       (p_status        => 'FAIL',
	p_ruleset_name  => p_ruleset_name,
	p_ruleset_start_date    => p_ruleset_start_date,
	p_ruleset_end_date      => p_ruleset_end_date,
	p_ruleset_type  => p_ruleset_type,
	p_rule_name     => NULL,
	p_head_id       => p_imp_header.imp_header_id,
	p_error_code    => l_error_code,
	p_error_mssg    => x_err_mssg,
	x_failed_row    => x_failed_row,
	x_processed_row => x_processed_row);
  END IF;

  -- Check level_num cannot null
  l_temp_count := 0 ;
  OPEN c_null_level_num_csr;
  FETCH c_null_level_num_csr INTO l_temp_count;
  CLOSE c_null_level_num_csr;

  IF l_temp_count > 0 THEN
     cn_message_pkg.debug ('Ruleset has level num with null value');
     x_err_mssg := fnd_message.get_string('CN','CN_IMP_MISS_REQUIRED');
     x_retcode := 2;
     x_imp_line_id := G_INVALID_IMP_LINE_ID;
     l_error_code := 'CN_IMP_MISS_REQUIRED';
     seterr_imp_rules
       (p_status        => 'FAIL',
	p_ruleset_name  => p_ruleset_name,
	p_ruleset_start_date    => p_ruleset_start_date,
	p_ruleset_end_date      => p_ruleset_end_date,
	p_ruleset_type  => p_ruleset_type,
	p_level_num     => NULL,
	p_head_id       => p_imp_header.imp_header_id,
	p_error_code    => l_error_code,
	p_error_mssg    => x_err_mssg,
	x_failed_row    => x_failed_row,
	x_processed_row => x_processed_row);
  END IF;
  -- Process each rules
  FOR rule_name_rec IN c_rule_name_csr LOOP
     -- Check unique of rev class, libility/expense code
     l_temp_count := 0 ;
     OPEN c_rules_dtl_csr
       (rule_name_rec.rule_name, rule_name_rec.parent_rule_name,
	rule_name_rec.level_num);
     FETCH c_rules_dtl_csr INTO l_temp_count;
     CLOSE c_rules_dtl_csr;

     IF l_temp_count > 1 THEN
	cn_message_pkg.debug ('Rule has multiple RC, libility/exp code value');
	x_err_mssg := fnd_message.get_string('CN','CN_MULTI_RULE_DTL');
	x_retcode := 2;
	x_imp_line_id := G_INVALID_IMP_LINE_ID;
	l_error_code := 'CN_MULTI_RULE_DTL';
	seterr_imp_rules
	  (p_status        => 'FAIL',
	   p_ruleset_name  => p_ruleset_name,
	   p_ruleset_start_date    => p_ruleset_start_date,
	   p_ruleset_end_date      => p_ruleset_end_date,
	   p_ruleset_type  => p_ruleset_type,
	   p_rule_name     => rule_name_rec.rule_name,
	   p_parent_rule_name => rule_name_rec.parent_rule_name,
	   p_level_num     => rule_name_rec.level_num,
	   p_head_id       => p_imp_header.imp_header_id,
	   p_error_code    => l_error_code,
	   p_error_mssg    => x_err_mssg,
	   x_failed_row    => x_failed_row,
	   x_processed_row => x_processed_row);

	GOTO end_load_rule;
     END IF;

     -- check rule_name length
     IF LENGTH(rule_name_rec.rule_name) > 60 THEN
	cn_message_pkg.debug ('load_rules: Rule name too long :' || rule_name_rec.rule_name);
	x_err_mssg := fnd_message.get_string('CN','CN_RULE_NAME_TOO_LONG');
	x_retcode := 2;
	l_error_code := 'CN_RULE_NAME_TOO_LONG';
	seterr_imp_rules
	  (p_status        => 'FAIL',
	   p_ruleset_name  => p_ruleset_name,
	   p_ruleset_start_date    => p_ruleset_start_date,
	   p_ruleset_end_date      => p_ruleset_end_date,
	   p_ruleset_type  => p_ruleset_type,
	   p_rule_name     => rule_name_rec.rule_name,
	   p_parent_rule_name => rule_name_rec.parent_rule_name,
	   p_level_num     => rule_name_rec.level_num,
	   p_head_id       => p_imp_header.imp_header_id,
	   p_error_code    => l_error_code,
	   p_error_mssg    => x_err_mssg,
	   x_failed_row    => x_failed_row,
	   x_processed_row => x_processed_row);
	GOTO end_load_rule;
     END IF;

     -- get rule detail value
     OPEN c_rules_csr(rule_name_rec.rule_name, rule_name_rec.parent_rule_name,
		      rule_name_rec.level_num);
     FETCH c_rules_csr INTO rules_rec;
     CLOSE c_rules_csr;

     cn_message_pkg.write
       (p_message_text => 'Start to create Rule, name: ' || rule_name_rec.rule_name,
	p_message_type => 'MILESTONE');

     -- get the required values to create a new rule
     l_rule_rec.ruleset_id       := p_ruleset_id;
     l_rule_rec.org_id           := p_org_id;
     l_rule_rec.rule_name        := rule_name_rec.rule_name;
--     l_current_imp_line_id       := rules_rec.imp_line_id;
     l_rule_rec.parent_rule_id   := null;
     l_rule_rec.revenue_class_id := null;
     l_rule_rec.expense_ccid     := null;
     l_rule_rec.liability_ccid   := null;
     l_rule_rec.revenue_class_id := null;

     -- Check for 'ACCGEN', rev class should not have value
     IF (p_ruleset_type = 'ACCGEN' AND rules_rec.revenue_class_name IS NOT NULL) OR (p_ruleset_type = 'REVCLS' AND (rules_rec.liability_code IS NOT NULL OR rules_rec.expense_code IS NOT NULL))
       THEN
	x_err_mssg := fnd_message.get_string('CN','CN_INVLD_RULE_DTL');
	x_retcode := 2;
	l_error_code := 'CN_INVLD_RULE_DTL';
	seterr_imp_rules
	  (p_status        => 'FAIL',
	   p_ruleset_name  => p_ruleset_name,
	   p_ruleset_start_date    => p_ruleset_start_date,
	   p_ruleset_end_date      => p_ruleset_end_date,
	   p_ruleset_type  => p_ruleset_type,
	   p_rule_name     => rule_name_rec.rule_name,
	   p_parent_rule_name => rule_name_rec.parent_rule_name,
	   p_level_num     => rule_name_rec.level_num,
	   p_head_id       => p_imp_header.imp_header_id,
	   p_error_code    => l_error_code,
	   p_error_mssg    => x_err_mssg,
	   x_failed_row    => x_failed_row,
	   x_processed_row => x_processed_row);
	GOTO end_load_rule;
     END IF;

     -- Check Expense code
     IF rules_rec.expense_code IS NOT NULL THEN
        l_value_found := 0;
        FOR expns_row IN c_expense_code_csr (rules_rec.expense_code) LOOP
         l_rule_rec.expense_ccid := expns_row.code_combination_id;
         l_value_found := 1;
        END LOOP;
        IF l_value_found = 0 THEN
          cn_message_pkg.debug ('load_rules: Invalid Expense code :' || rules_rec.expense_code);
          x_err_mssg := fnd_message.get_string('CN','CN_IMP_INVLD_EXPENS_CODE');
          x_retcode := 2;
          l_error_code := 'CN_IMP_INVLD_EXPENS_CODE';
	  seterr_imp_rules
	    (p_status        => 'FAIL',
	     p_ruleset_name  => p_ruleset_name,
	     p_ruleset_start_date    => p_ruleset_start_date,
	     p_ruleset_end_date      => p_ruleset_end_date,
	     p_ruleset_type  => p_ruleset_type,
	     p_rule_name     => rule_name_rec.rule_name,
	     p_parent_rule_name => rule_name_rec.parent_rule_name,
	     p_level_num     => rule_name_rec.level_num,
	     p_expense_code  => rules_rec.expense_code,
	     p_head_id       => p_imp_header.imp_header_id,
	     p_error_code    => l_error_code,
	     p_error_mssg    => x_err_mssg,
	     x_failed_row    => x_failed_row,
	     x_processed_row => x_processed_row);
	  GOTO end_load_rule;
        END IF;
     END IF;
     -- Check liability_code
     IF rules_rec.liability_code IS NOT NULL THEN
        l_value_found := 0;
        FOR liabl_row IN c_liability_code_csr (rules_rec.liability_code) LOOP
	   l_value_found := 1;
	   l_rule_rec.liability_ccid := liabl_row.code_combination_id;
        END LOOP;
        IF l_value_found = 0 THEN
	   cn_message_pkg.debug ('load_rules: Invalid liability code :' || rules_rec.liability_code);
	   x_err_mssg := fnd_message.get_string('CN','CN_IMP_INVLD_LIABLTY_CODE');
	   x_retcode := 2;
	   l_error_code := 'CN_IMP_INVLD_LIABLTY_CODE';
	   seterr_imp_rules
	     (p_status        => 'FAIL',
	      p_ruleset_name  => p_ruleset_name,
	      p_ruleset_start_date    => p_ruleset_start_date,
	      p_ruleset_end_date      => p_ruleset_end_date,
	      p_ruleset_type  => p_ruleset_type,
	      p_rule_name     => rule_name_rec.rule_name,
	      p_parent_rule_name => rule_name_rec.parent_rule_name,
	      p_level_num     => rule_name_rec.level_num,
	      p_liability_code => rules_rec.liability_code,
	      p_head_id       => p_imp_header.imp_header_id,
	      p_error_code    => l_error_code,
	      p_error_mssg    => x_err_mssg,
	      x_failed_row    => x_failed_row,
	      x_processed_row => x_processed_row);
	   GOTO end_load_rule;
        END IF;
     END IF;
     -- Check parent_rule_name
     IF rule_name_rec.parent_rule_name IS NULL THEN
	l_rule_rec.parent_rule_id := -1002;
      ELSE
        l_value_found := 0;
        FOR parent_rul_row IN c_parent_rule_csr (rule_name_rec.parent_rule_name) LOOP
	   l_rule_rec.parent_rule_id := parent_rul_row.rule_id;
	   l_value_found := 1;
        END LOOP;
        IF l_value_found = 0 THEN
	   cn_message_pkg.debug ('load_rules: Invalid Parent Rule name :' || rule_name_rec.parent_rule_name);
	   x_err_mssg := fnd_message.get_string('CN','CN_IMP_INVLD_PAR_RUL_NM');
	   x_retcode := 2;
	   l_error_code := 'CN_IMP_INVLD_PAR_RUL_NM';
	   seterr_imp_rules
	     (p_status        => 'FAIL',
	      p_ruleset_name  => p_ruleset_name,
	      p_ruleset_start_date    => p_ruleset_start_date,
	      p_ruleset_end_date      => p_ruleset_end_date,
	      p_ruleset_type  => p_ruleset_type,
	      p_rule_name     => rule_name_rec.rule_name,
	      p_parent_rule_name => rule_name_rec.parent_rule_name,
	      p_level_num     => rule_name_rec.level_num,
	      p_head_id       => p_imp_header.imp_header_id,
	      p_error_code    => l_error_code,
	      p_error_mssg    => x_err_mssg,
	      x_failed_row    => x_failed_row,
	      x_processed_row => x_processed_row);
	   GOTO end_load_rule;
        END IF;
     END IF;

     -- Check rev class name
     IF rules_rec.revenue_class_name IS NOT NULL THEN
	l_value_found := 0;
	FOR revenue_row IN c_revenue_id_csr (rules_rec.revenue_class_name) LOOP
	   l_value_found := 1;
	   l_rule_rec.revenue_class_id := revenue_row.revenue_class_id;
	END LOOP;
	IF l_value_found = 0 THEN
	   cn_message_pkg.debug ('load_rules: Invalid Revenue class name :' || rules_rec.revenue_class_name);
	   x_err_mssg := fnd_message.get_string('CN','CN_IMP_INVLD_REVNU_CLASS_NM');
	   x_retcode := 2;
	   l_error_code := 'CN_IMP_INVLD_REVNU_CLASS_NM';
	   seterr_imp_rules
	     (p_status        => 'FAIL',
	      p_ruleset_name  => p_ruleset_name,
	      p_ruleset_start_date    => p_ruleset_start_date,
	      p_ruleset_end_date      => p_ruleset_end_date,
	      p_ruleset_type  => p_ruleset_type,
	      p_rule_name     => rule_name_rec.rule_name,
	      p_parent_rule_name => rule_name_rec.parent_rule_name,
	      p_level_num     => rule_name_rec.level_num,
	      p_revcls_name   => rules_rec.revenue_class_name,
	      p_head_id       => p_imp_header.imp_header_id,
	      p_error_code    => l_error_code,
	      p_error_mssg    => x_err_mssg,
	      x_failed_row    => x_failed_row,
	      x_processed_row => x_processed_row);
	   GOTO end_load_rule;
      END IF;
     END IF;

    -- Create rule
     cn_message_pkg.debug('load_rules: Creating rule, rule name:' || rule_name_rec.rule_name);
     cn_message_pkg.debug('load_rules: rule_name_rec.parent_rule_name:'  || rule_name_rec.parent_rule_name || ' l_rule_rec.parent_rule_id:'    || l_rule_rec.parent_rule_id);
     cn_message_pkg.debug('load_rules: rules_rec.revenue_class_name:'    || rules_rec.revenue_class_name   || ' l_rule_rec.revenue_class_id:'  || l_rule_rec.revenue_class_id);
     cn_message_pkg.debug('load_rules: rules_rec.expense_code: '         || rules_rec.expense_code         || ' l_rule_rec.expense_ccid: '     || l_rule_rec.expense_ccid);
     cn_message_pkg.debug('load_rules: rules_rec.liability_code: '       || rules_rec.liability_code       || ' l_rule_rec.liability_ccid: '   || l_rule_rec.liability_ccid);
     cn_message_pkg.debug('load_rules: rules_rec.revenue_class_name: '   || rules_rec.revenue_class_name   || ' l_rule_rec.revenue_class_id: ' || l_rule_rec.revenue_class_id);

     cn_rule_pvt.Create_Rule
       ( p_api_version      => 1.0,
	 p_init_msg_list    => fnd_api.g_true,
	 p_commit	    => FND_API.G_FALSE,
	 p_validation_level => FND_API.G_VALID_LEVEL_FULL,
	 x_return_status    => l_return_status,
	 x_msg_count	    => l_msg_count,
	 x_msg_data	    => l_msg_data,
	 x_loading_status   => l_loading_status,
	 p_rule_rec	    => l_rule_rec,
	 x_rule_id	    => l_current_rule_id);

     cn_message_pkg.debug ('load_rules: completed creating new rule, l_return_status: ' || l_return_status || ' l_current_rule_id: ' || l_current_rule_id);

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	cn_message_pkg.debug ('load_rules: Error in Creating rule, rule name:' || rule_name_rec.rule_name);
	x_err_mssg := l_msg_data;
	x_retcode := 2;
	l_error_code := 'CN_IMP_INVLD_RULE';
	seterr_imp_rules
	  (p_status        => 'FAIL',
	   p_ruleset_name  => p_ruleset_name,
	   p_ruleset_start_date    => p_ruleset_start_date,
	   p_ruleset_end_date      => p_ruleset_end_date,
	   p_ruleset_type  => p_ruleset_type,
	   p_rule_name     => rule_name_rec.rule_name,
	   p_parent_rule_name => rule_name_rec.parent_rule_name,
	   p_level_num     => rule_name_rec.level_num,
	   p_head_id       => p_imp_header.imp_header_id,
	   p_error_code    => l_error_code,
	   p_error_mssg    => x_err_mssg,
	   x_failed_row    => x_failed_row,
	   x_processed_row => x_processed_row);
	GOTO end_load_rule;
     END IF;

     cn_message_pkg.write
       (p_message_text => 'Completed create Rule, name: ' || rule_name_rec.rule_name,
	p_message_type => 'MILESTONE');

     cn_message_pkg.debug ('load_rules: Before load_rule_attributes, rule name: ' || rule_name_rec.rule_name);
     -- now create the rule attributes
     load_rule_attributes
       ( p_ruleset_id         => p_ruleset_id,
	 p_ruleset_name       => p_ruleset_name,
	 p_ruleset_start_date => p_ruleset_start_date,
	 p_ruleset_end_date   => p_ruleset_end_date,
	 p_ruleset_type       => p_ruleset_type,
	 p_rule_id            => l_current_rule_id,
	 p_rule_name          => rule_name_rec.rule_name,
	 p_parent_rule_name   => rule_name_rec.parent_rule_name,
	 p_level_num     => rule_name_rec.level_num,
	 p_imp_header         => p_imp_header,
	 x_err_mssg           => x_err_mssg,
	 x_retcode            => x_retcode,
	 x_imp_line_id        => x_imp_line_id,
	 x_failed_row     => x_failed_row,
	 x_processed_row  => x_processed_row,
	 p_org_id         => l_org_id);

     cn_message_pkg.debug ('load_rules: After load_rule_attributes, x_retcode: ' || x_retcode);

     IF x_retcode = 2 THEN
	cn_message_pkg.debug ('load_rules: After call to load_rule_attributes for rule: ' || rule_name_rec.rule_name || ' with error msg:' || x_err_mssg);
	GOTO end_load_rule;
     END IF;
     << end_load_rule >>
       NULL;
  END LOOP; --  of rules_rec loop

EXCEPTION
   WHEN OTHERS THEN
      cn_message_pkg.debug ('load_rules: ### IMP ### EXCEPTION :  in Creating rule:' || SQLERRM);
      x_err_mssg := SQLERRM;
      x_retcode := 2;
      l_error_code := 'CN_IMP_INVLD_RULE';
	seterr_imp_rules
	  (p_status        => 'FAIL',
	   p_ruleset_name  => p_ruleset_name,
	   p_ruleset_start_date    => p_ruleset_start_date,
	   p_ruleset_end_date      => p_ruleset_end_date,
	   p_ruleset_type  => p_ruleset_type,
	   p_rule_name     => l_rule_rec.rule_name,
	   p_head_id       => p_imp_header.imp_header_id,
	   p_error_code    => l_error_code,
	   p_error_mssg    => x_err_mssg,
	   x_failed_row    => x_failed_row,
	   x_processed_row => x_processed_row);

END load_rules;

--
-- Creat a new entry for the rule attributes
--
PROCEDURE load_rule_attributes
( p_ruleset_id         IN NUMBER,
  p_ruleset_name       IN VARCHAR2,
  p_ruleset_start_date IN VARCHAR,
  p_ruleset_end_date   IN VARCHAR,
  p_ruleset_type       IN VARCHAR,
  p_rule_id            IN NUMBER,
  p_rule_name          IN VARCHAR2,
  p_parent_rule_name   IN VARCHAR2,
  p_level_num          IN VARCHAR2,
  p_imp_header         IN cn_imp_headers_pvt.imp_headers_rec_type,
  x_err_mssg           OUT NOCOPY VARCHAR2,
  x_retcode            OUT NOCOPY VARCHAR2,
  x_imp_line_id        OUT NOCOPY NUMBER,
  x_failed_row    IN OUT NOCOPY NUMBER,
  x_processed_row IN OUT NOCOPY NUMBER,
  p_org_id IN NUMBER
) IS
  l_api_name         CONSTANT VARCHAR2(30) := 'load_rule_attributes';
  l_stage_status     cn_imp_lines.status_code%TYPE := 'STAGE';
  l_error_code       VARCHAR2(30);
  l_loading_status   VARCHAR2(30);
  l_return_status    VARCHAR2(30);
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR (4000);
  l_rule_attrb_rec   CN_RuleAttribute_PVT.RuleAttribute_rec_type;
  l_current_imp_line_id NUMBER;
  l_value_found         NUMBER;
  l_org_id NUMBER;

  -- cursor to get attribute details, given ruleset name, rule name and parent rule name
  -- IMP parent rule name is required because we can have 2 rules with the same name but at different levels
  CURSOR c_rule_attrb_csr IS
     SELECT imp_line_id, record_num, rule_attribute, rule_value, not_flag, rule_hierarchy, rule_low_value, rule_high_value
       FROM CN_RULES_IMP_V
       WHERE imp_header_id = p_imp_header.imp_header_id
       AND status_code = l_stage_status
       AND ruleset_name = p_ruleset_name
       AND start_date = p_ruleset_start_date
       AND end_date = p_ruleset_end_date
       AND ruleset_type= p_ruleset_type
       AND rule_name = p_rule_name
       AND nvl(parent_rule_name, FND_API.g_miss_char) =  nvl(p_parent_rule_name, FND_API.g_miss_char)
       AND level_num = p_level_num;

 -- cursor to get the hierarchy id
  CURSOR c_rule_attrb_hier_id_csr (l_name CN_HEAD_HIERARCHIES.name%TYPE) IS
   SELECT head_hierarchy_id
   FROM CN_HEAD_HIERARCHIES
   WHERE name = l_name
   and org_id=p_org_id;

 -- cursor to get the value associated with the hierarchy attribute
   CURSOR c_rule_attrb_hier_val_csr (h_id CN_HIERARCHY_NODES.dim_hierarchy_id%TYPE, l_name CN_HIERARCHY_NODES.NAME%TYPE) IS
   SELECT CHN.value_id
   FROM CN_DIM_HIERARCHIES CDH, CN_HIERARCHY_NODES CHN
   WHERE cdh.header_dim_hierarchy_id = h_id
   AND name = l_name AND
   CDH.org_id=p_org_id AND
   CDH.org_id=CHN.org_id
   AND cdh.dim_hierarchy_id = chn.dim_hierarchy_id;

 -- Cursor to get the name of the column given the user name
    CURSOR c_rule_attrb_object_name (l_name cn_objects.user_name%TYPE) IS
    SELECT name
    FROM cn_objects
    WHERE table_id = -11803
    and org_id=p_org_id
    AND user_name = l_name;

    attrb_name_row c_rule_attrb_object_name%ROWTYPE;
BEGIN
   FOR attr_rec IN c_rule_attrb_csr LOOP
      cn_message_pkg.write
	(p_message_text => 'Start create Rule Attribute, name: ' || attr_rec.rule_attribute,
	 p_message_type => 'MILESTONE');

      l_current_imp_line_id := attr_rec.imp_line_id;
      cn_message_pkg.debug ('load_rule_attributes: attr_rec.rule_attribute: ' || attr_rec.rule_attribute);
      cn_message_pkg.debug ('load_rule_attributes: attr_rec.rule_value: ' || attr_rec.rule_value);
      cn_message_pkg.debug ('load_rule_attributes: attr_rec.rule_hierarchy: ' || attr_rec.rule_hierarchy);
      cn_message_pkg.debug ('load_rule_attributes: attr_rec.rule_low_value: ' || attr_rec.rule_low_value);
      cn_message_pkg.debug ('load_rule_attributes: attr_rec.rule_high_value: ' || attr_rec.rule_high_value);

      IF (attr_rec.rule_attribute IS NULL) OR
        (attr_rec.rule_value IS NOT NULL AND attr_rec.rule_low_value IS NOT NULL) OR
	  (attr_rec.rule_value IS NOT NULL AND attr_rec.rule_high_value IS NOT NULL)OR
	    (attr_rec.rule_hierarchy IS NOT NULL AND attr_rec.rule_low_value IS NOT NULL) OR
	      (attr_rec.rule_hierarchy IS NOT NULL AND attr_rec.rule_high_value IS NOT NULL) THEN
         cn_message_pkg.debug ('load_rule_attributes: Invalid rule attribute');
         x_err_mssg := fnd_message.get_string('CN', 'CN_IMP_INVLD_RULE_ATTRB');
         x_retcode  := 2;
         x_imp_line_id := attr_rec.imp_line_id;
         l_error_code := 'CN_IMP_INVLD_RULE_ATTRB';

         update_on_error
	   (p_line_id   => attr_rec.imp_line_id,
	    p_err_code  => l_error_code,
	    p_err_mssg  => x_err_mssg,
	    p_head_id   => p_imp_header.imp_header_id);
	 x_failed_row := x_failed_row + 1;
	 GOTO end_rule_attr;
      END IF;

      l_rule_attrb_rec.ruleset_id  := p_ruleset_id;
      l_rule_attrb_rec.rule_id     := p_rule_id;
      l_rule_attrb_rec.org_id := p_org_id;

      l_value_found := 0;
      FOR attrb_name_row IN c_rule_attrb_object_name (attr_rec.rule_attribute) LOOP
	 l_value_found := 1;
	 l_rule_attrb_rec.object_name := attrb_name_row.name;
      END LOOP;
      IF l_value_found = 0 THEN
	 cn_message_pkg.debug ('load_rule_attributes: Invalid attr_rec.rule_attribute: ' || attr_rec.rule_attribute);
	 x_err_mssg := fnd_message.get_string('CN', 'CN_IMP_INVLD_RUL_ATTR');
	 x_retcode := 2;
	 x_imp_line_id := attr_rec.imp_line_id;
	 l_error_code := 'CN_IMP_INVLD_RUL_ATTR';
	 update_on_error
	   (p_line_id   => attr_rec.imp_line_id,
	    p_err_code  => l_error_code,
	    p_err_mssg  => x_err_mssg,
	    p_head_id   => p_imp_header.imp_header_id);
	 x_failed_row := x_failed_row + 1;
	 GOTO end_rule_attr;
      END IF;

      cn_message_pkg.debug ('load_rule_attributes: Past the basic validation');
      cn_message_pkg.debug ('load_rule_attributes: p_ruleset_id: ' || p_ruleset_id);
      cn_message_pkg.debug ('load_rule_attributes: p_rule_id: ' || p_rule_id);
      cn_message_pkg.debug ('load_rule_attributes: attr_rec.rule_attribute: ' || attr_rec.rule_attribute);

      IF attr_rec.not_flag IS NULL OR attr_rec.not_flag = 'N' THEN
       l_rule_attrb_rec.not_flag := 'N';
       ELSIF attr_rec.not_flag = 'Y' THEN
	 l_rule_attrb_rec.not_flag := 'Y';
       ELSE
	 cn_message_pkg.debug ('load_rule_attributes: Invalid not flag value: ' || attr_rec.not_flag);
	 x_err_mssg := fnd_message.get_string('CN', 'CN_IMP_INVLD_NOT_FLG_VAL');
	 x_retcode := 2;
	 x_imp_line_id := attr_rec.imp_line_id;
	 l_error_code := 'CN_IMP_INVLD_NOT_FLG_VAL';
	 update_on_error
	   (p_line_id   => attr_rec.imp_line_id,
	    p_err_code  => l_error_code,
	    p_err_mssg  => x_err_mssg,
	    p_head_id   => p_imp_header.imp_header_id);
	 x_failed_row := x_failed_row + 1;
	 GOTO end_rule_attr;
      END IF;

      cn_message_pkg.debug ('load_rule_attributes: attr_rec.not_flag: ' || attr_rec.not_flag);

      IF attr_rec.rule_value IS NOT NULL AND attr_rec.rule_hierarchy IS NULL THEN
	 -- this is a Single Value Attribute
	 cn_message_pkg.debug ('load_rule_attributes: CASE :Single Value Attribute');
	 l_rule_attrb_rec.value_1   := attr_rec.rule_value;
	 l_rule_attrb_rec.value_2   := NULL;
	 l_rule_attrb_rec.data_flag := 'O';
       ELSIF attr_rec.rule_value IS NOT NULL AND attr_rec.rule_hierarchy IS NOT NULL THEN
	 --  this is a Hierarchy Attribute
	 cn_message_pkg.debug ('load_rule_attributes: CASE :Hierarchy Attribute');
	 OPEN c_rule_attrb_hier_id_csr (attr_rec.rule_hierarchy);
	 FETCH c_rule_attrb_hier_id_csr INTO l_rule_attrb_rec.value_1;
	 CLOSE c_rule_attrb_hier_id_csr;

	 OPEN c_rule_attrb_hier_val_csr (l_rule_attrb_rec.value_1, attr_rec.rule_value);
	 FETCH c_rule_attrb_hier_val_csr INTO l_rule_attrb_rec.value_2;
	 CLOSE c_rule_attrb_hier_val_csr;

	 l_rule_attrb_rec.data_flag := 'H';
       ELSE
	 -- this is a Range Value Attribute
	 cn_message_pkg.debug ('load_rule_attributes: CASE :Range Value Attribute');
	 l_rule_attrb_rec.value_1   := attr_rec.rule_low_value;
	 l_rule_attrb_rec.value_2   := attr_rec.rule_high_value;
	 l_rule_attrb_rec.data_flag := 'R';
      END IF;

      cn_message_pkg.debug ('load_rule_attributes: l_rule_attrb_rec.data_flag:' || l_rule_attrb_rec.data_flag);
      cn_message_pkg.debug ('load_rule_attributes: l_rule_attrb_rec.value_2:' || l_rule_attrb_rec.value_2);
      cn_message_pkg.debug ('load_rule_attributes: l_rule_attrb_rec.value_1:' || l_rule_attrb_rec.value_1);

      cn_message_pkg.debug ('load_rule_attributes: Before call to CN_RuleAttribute_PVT.Create_RuleAttribute for attribute: ' || attr_rec.rule_attribute);

      CN_RuleAttribute_PVT.Create_RuleAttribute
	( p_api_version       => 1.0,
	  p_init_msg_list     => fnd_api.g_true,
	  p_commit            => FND_API.G_FALSE,
	  p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
	  x_return_status     => l_return_status,
	  x_msg_count         => l_msg_count,
	  x_msg_data          => l_msg_data,
	  x_loading_status    => l_loading_status,
	  p_RuleAttribute_rec => l_rule_attrb_rec);

      cn_message_pkg.debug ('load_rule_attributes: Completed creating new rule attribute, l_return_status:' || l_return_status);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 cn_message_pkg.debug ('load_rule_attributes: Error when creating new rule attribute, l_msg_data:' || l_msg_data);
	 x_err_mssg := l_msg_data;
	 x_retcode := 2;
	 x_imp_line_id := attr_rec.imp_line_id;
	 l_error_code := 'CN_IMP_INVLD_RULE_ATTRB';
	 update_on_error
	   (p_line_id   => attr_rec.imp_line_id,
	    p_err_code  => l_error_code,
	    p_err_mssg  => x_err_mssg,
	    p_head_id   => p_imp_header.imp_header_id);
	 x_failed_row := x_failed_row + 1;
     	 GOTO end_rule_attr;
      END IF;
      cn_message_pkg.write
	(p_message_text => 'Completed create Rule Attribute, name: ' || attr_rec.rule_attribute,
	 p_message_type => 'MILESTONE');
      -- Set status to Complete
      CN_IMPORT_PVT.update_imp_lines
	(p_imp_line_id => attr_rec.imp_line_id,
	 p_status_code => 'COMPLETE',
	 p_error_code  => '');

      << end_rule_attr >>
      x_processed_row := x_processed_row + 1;
   END LOOP;
EXCEPTION
   WHEN OTHERS THEN
      cn_message_pkg.debug ('load_rule_attributes: ### IMP ### EXCEPTIONS :' || SQLERRM);
      x_err_mssg := SQLERRM;
      x_retcode := 2;
      x_imp_line_id := l_current_imp_line_id;
      l_error_code := 'CN_IMP_INVLD_RULE_ATTRB';
      update_on_error
	(p_line_id   => l_current_imp_line_id,
	 p_err_code  => l_error_code,
	 p_err_mssg  => x_err_mssg,
	 p_head_id   => p_imp_header.imp_header_id);
      x_failed_row := x_failed_row + 1;
      x_processed_row := x_processed_row + 1;
END load_rule_attributes;

--
-- this will update the row that caused the error
--
PROCEDURE update_on_error
 (p_line_id   IN NUMBER,
  p_err_code  IN VARCHAR2,
  p_err_mssg  IN VARCHAR2,
  p_head_id   IN NUMBER ) IS
   PRAGMA AUTONOMOUS_TRANSACTION;
 BEGIN
 CN_IMPORT_PVT.update_imp_lines
  (p_imp_line_id => p_line_id,
   p_status_code => 'FAIL',
   p_error_code  => p_err_code,
   p_error_msg   => p_err_mssg);
 COMMIT;
END update_on_error;

--
-- this will update all the rows that correspond to the ruleset
--
PROCEDURE update_imp_lines
  (p_status        IN VARCHAR2,
   p_imp_line_id   IN NUMBER,
   p_ruleset_name  IN VARCHAR2,
   p_start_date    IN VARCHAR2,
   p_end_date      IN VARCHAR2,
   p_ruleset_type  IN VARCHAR2,
   p_head_id       IN NUMBER,
   p_error_code    IN VARCHAR2,
   p_error_mssg    IN VARCHAR2,
   x_failed_row    IN OUT NOCOPY NUMBER,
   x_processed_row IN OUT NOCOPY NUMBER) IS

      CURSOR c_check_imp_line_id_csr IS
	 SELECT count(*)
	   FROM cn_rules_imp_v
	   WHERE  nvl(ruleset_name,FND_API.g_miss_char) = nvl(p_ruleset_name ,FND_API.g_miss_char)
	   AND nvl(start_date ,FND_API.g_miss_char)  = nvl(p_start_date, FND_API.g_miss_char)
	   AND nvl(end_date,FND_API.g_miss_char)     = nvl(p_end_date, FND_API.g_miss_char)
	   AND nvl(ruleset_type,FND_API.g_miss_char) = nvl(p_ruleset_type, FND_API.g_miss_char)
	   AND imp_header_id                         = p_head_id
	   AND status_code     = 'STAGE'
	   AND imp_line_id                          <> p_imp_line_id;

      l_temp NUMBER := 0;

      PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   cn_message_pkg.debug('Updating cn_rules_imp_v with status:' || p_status);
   cn_message_pkg.debug('p_ruleset_name:' || p_ruleset_name);
   cn_message_pkg.debug('p_start_date:' || p_start_date);
   cn_message_pkg.debug('p_end_date:' || p_end_date);
   cn_message_pkg.debug('p_ruleset_type:' || p_ruleset_type);
   cn_message_pkg.debug('p_head_id:' || p_head_id);
   cn_message_pkg.debug('p_imp_line_id:' || p_imp_line_id);

   OPEN c_check_imp_line_id_csr;
   FETCH c_check_imp_line_id_csr INTO l_temp;
   CLOSE c_check_imp_line_id_csr;

   -- This check is needed for the case when the user enters just one row for a ruleset and that row is invalid.
   IF l_temp = 0 THEN
      l_temp := G_INVALID_IMP_LINE_ID;
    ELSE
      l_temp := p_imp_line_id;
   END IF;

   cn_message_pkg.debug('l_temp:' || l_temp);

   UPDATE cn_rules_imp_v
     SET status_code=p_status, error_code=p_error_code, error_msg=p_error_mssg
     WHERE  nvl(ruleset_name,FND_API.g_miss_char) = nvl(p_ruleset_name ,FND_API.g_miss_char)
     AND nvl(start_date ,FND_API.g_miss_char)  = nvl(p_start_date, FND_API.g_miss_char)
     AND nvl(end_date,FND_API.g_miss_char)     = nvl(p_end_date, FND_API.g_miss_char)
     AND nvl(ruleset_type,FND_API.g_miss_char) = nvl(p_ruleset_type, FND_API.g_miss_char)
     AND imp_header_id                         = p_head_id
     AND status_code     = 'STAGE'
     AND imp_line_id                          <> l_temp;

   IF p_status <> 'COMPLETE' THEN
      x_failed_row := x_failed_row + SQL%rowcount;

      --  IF l_temp = p_imp_line_id THEN
      --	 x_processed_row := x_processed_row + 1;
      --	 x_failed_row := x_failed_row + 1;
      --      END IF;
   END IF;

   x_processed_row := x_processed_row + SQL%rowcount;

   cn_message_pkg.debug ('SQL%rowcount:' || SQL%rowcount || ' x_processed_row:' || x_processed_row || '  x_failed_row:' || x_failed_row);
   COMMIT;
EXCEPTION
   WHEN OTHERS THEN
      cn_message_pkg.debug ('### IMP ### EXCEPTION: ' || SQLERRM);
END update_imp_lines;

END CN_IMP_RULE_PVT;


/
