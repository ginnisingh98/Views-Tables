--------------------------------------------------------
--  DDL for Package Body AR_CMGT_CONTROLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CMGT_CONTROLS" AS
/* $Header: ARCMGCCB.pls 120.14 2006/01/31 07:04:06 kjoshi noship $ */
PROCEDURE POPULATE_DNB_DATA (
        p_case_folder_id            IN      NUMBER,
        p_source_table_name         IN      VARCHAR2,
        p_source_key                IN      VARCHAR2,
        p_source_key_type           IN      VARCHAR2 default NULL,
        p_source_key_column_name    IN      VARCHAR2,
        p_source_key_column_type    IN      VARCHAR2 default NULL,
        p_errmsg                    OUT NOCOPY     VARCHAR2,
        p_resultout                 OUT NOCOPY     VARCHAR2) IS
BEGIN
        p_resultout := 0;

        INSERT INTO ar_cmgt_cf_dnb_dtls (
                case_folder_id,
                source_table_name,
                source_key,
                source_key_type,
                source_key_column_name,
                source_key_column_type_name,
		        last_updated_by,
		        last_update_date,
		        created_by,
		        creation_date,
		        last_update_login)
                 VALUES
                ( p_case_folder_id,
                  p_source_table_name,
                  p_source_key,
                  p_source_key_type,
                  p_source_key_column_name,
                  p_source_key_column_type,
		          fnd_global.user_id,
		          SYSDATE,
		          fnd_global.user_id,
		          sysdate,
		          fnd_global.login_id);
        EXCEPTION
            WHEN OTHERS THEN
                p_errmsg := 'Error while inserting into ar_cmgt_cf_dnb_dtls '||sqlerrm;
                p_resultout := 1;
END;

PROCEDURE POPULATE_CF_DETAILS_PVT (
        p_case_folder_id                IN      NUMBER,
        p_data_point_id                 IN      NUMBER,
        p_sequence_number               IN      NUMBER,
        p_parent_data_point_id          IN      NUMBER,
        p_parent_cf_detail_id  		    IN      NUMBER,
        p_data_point_value              IN      VARCHAR2,
        p_score                         IN      NUMBER default NULL,
        p_included_in_checklist         IN      VARCHAR2 default NULL,
        p_data_point_value_id			IN		NUMBER default NULL,
        p_case_folder_detail_id         OUT NOCOPY      NUMBER,
        x_errmsg                        OUT NOCOPY     VARCHAR2,
        x_resultout                     OUT NOCOPY     VARCHAR2) IS

	l_date_check			Date;
BEGIN
        x_resultout := 0;
	-- first validate the format of date in case the data type is DAte
        --
	BEGIN
		select to_date(p_data_point_value, return_date_format)
		INTO l_date_check
		from ar_cmgt_data_points_vl
		where data_point_id = p_data_point_id
		and   return_data_type = 'D';
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			NULL;
		WHEN OTHERS THEN
			x_resultout := 1;
			x_errmsg := 'Incorrect Date Format for Data Point Id :'||p_data_point_id;
			return;
	END;

        SELECT ar_cmgt_cf_dtls_s.nextval
	     INTO  p_case_folder_detail_id
	    FROM dual;

        INSERT INTO ar_cmgt_cf_dtls
                ( case_folder_detail_id,
                  case_folder_id,
                  data_point_id,
                  sequence_number,
                  parent_data_point_id,
                  parent_cf_detail_id,
                  data_point_value,
                  score,
		          included_in_checklist,
		          data_point_value_id,
                  last_updated_by,
                  created_by,
                  creation_date,
                  last_update_login,
                  last_update_date)
        VALUES  (  p_case_folder_detail_id,
        	      p_case_folder_id,
                  p_data_point_id,
                  p_sequence_number,
                  p_parent_data_point_id,
                  p_parent_cf_detail_id,
                  p_data_point_value,
                  p_score,
                  p_included_in_checklist,
                  p_data_point_value_id,
                  fnd_global.user_id,
                  fnd_global.user_id,
                  sysdate,
                  fnd_global.login_id,
                  sysdate);
                return ;

        EXCEPTION
            WHEN OTHERS THEN
                x_resultout := 1;
                x_errmsg := 'Error While trying to populate Case folder Details '||sqlerrm;

END;

PROCEDURE POPULATE_CASE_FOLDER (
        p_case_folder_id                IN      NUMBER,
        p_case_folder_number            IN      VARCHAR2    default NULL,
        p_credit_request_id             IN      NUMBER      default NULL,
        p_check_list_id                 IN      NUMBER      default NULL,
        p_status                        IN      VARCHAR2    default NULL,
        p_party_id                      IN      NUMBER,
        p_cust_account_id               IN      NUMBER,
        p_cust_acct_site_id             IN      NUMBER,
        p_score_model_id                IN      NUMBER      default NULL,
        p_credit_classification         IN      VARCHAR2    default NULL,
        p_review_type                   IN      VARCHAR2    default NULL,
        p_limit_currency                IN      VARCHAR2,
        p_exchange_rate_type            IN      VARCHAR2,
        p_type                          IN      VARCHAR2 ,
        p_errmsg                        OUT NOCOPY     VARCHAR2,
        p_resultout                     OUT NOCOPY     VARCHAR2) IS

        l_case_folder_id                ar_cmgt_case_folders.case_folder_id%type;
        l_case_folder_number            ar_cmgt_case_folders.case_folder_number%type;
BEGIN
        p_resultout := 0;
        IF (p_case_folder_id IS NULL) OR (p_case_folder_id = -99)
        THEN
            SELECT ar_cmgt_case_folders_s.nextval
            INTO   l_case_folder_id
            FROM   DUAL;
        ELSE
            l_case_folder_id := p_case_folder_id;
        END IF;
        IF p_case_folder_number IS NULL
        THEN
            SELECT ar_cmgt_case_folder_number_s.nextval
            INTO   l_case_folder_number
            FROM   DUAL;
        ELSE
            l_case_folder_number := p_case_folder_number;
        END IF;
        INSERT INTO ar_cmgt_case_folders (
                    case_folder_id,
                    case_folder_number,
                    credit_request_id,
                    check_list_id,
                    status,
                    cust_account_id,
                    party_id,
                    site_use_id,
                    score_model_id,
                    credit_classification,
                    review_type,
                    type,
                    limit_currency,
                    exchange_rate_type,
                    last_updated,
                    last_updated_by,
                    last_update_date,
                    last_update_login,
                    creation_date,
                    created_by,
                    creation_date_time)
         VALUES (   l_case_folder_id,
                    l_case_folder_number,
                   p_credit_request_id,
                   p_check_list_id,
                   'CREATED',
                   nvl(p_cust_account_id,-99),
                   p_party_id,
                   nvl(p_cust_acct_site_id,-99),
                   p_score_model_id,
                   p_credit_classification,
                   p_review_type,
                   p_type,
                   p_limit_currency,
                   p_exchange_rate_type,
                   SYSDATE,
                   fnd_global.user_id,
                   SYSDATE,
                   fnd_global.user_id,
                   SYSDATE,
                   fnd_global.login_id,
                   SYSDATE);
        EXCEPTION
            WHEN OTHERS
                THEN
                    p_errmsg := 'Error while populating Case folder Data '||sqlerrm;
                    p_resultout := 1;


END;

PROCEDURE POPULATE_CASE_FOLDER_DETAILS (
        p_case_folder_id                IN      NUMBER,
        p_data_point_id                 IN      NUMBER,
        p_data_point_value              IN      VARCHAR2,
        p_included_in_check_list        IN      VARCHAR2,
        p_score                         IN      NUMBER default NULL,
        p_errmsg                        OUT NOCOPY     VARCHAR2,
        p_resultout                     OUT NOCOPY     VARCHAR2) IS

        l_case_folder_detail_id         NUMBER;
BEGIN
        p_resultout := 0;

         POPULATE_CF_DETAILS_PVT
                ( p_case_folder_id,
                  p_data_point_id,
		          1,
		          null,
		          null,
                  p_data_point_value,
                  p_score,
                  p_included_in_check_list,
                  NULL,
                  l_case_folder_detail_id,
		          p_errmsg,
		          p_resultout);
        EXCEPTION
            WHEN OTHERS THEN
                p_resultout := 1;
                p_errmsg := 'Error While trying to populate Case folder Details '||sqlerrm;
END;

PROCEDURE UPDATE_CASE_FOLDER_DETAILS (
        p_case_folder_id                IN      NUMBER,
        p_data_point_id                 IN      NUMBER,
        p_data_point_value              IN      VARCHAR2,
        p_score                         IN      NUMBER default NULL,
        p_errmsg                        OUT NOCOPY     VARCHAR2,
        p_resultout                     OUT NOCOPY     VARCHAR2) IS
BEGIN
        p_resultout := 0;

        UPDATE ar_cmgt_cf_dtls
            SET score = nvl(p_score,score),
                data_point_value = nvl(p_data_point_value, data_point_value),
		        last_updated_by = fnd_global.user_id,
		        last_update_date = sysdate,
                last_update_login = fnd_global.login_id
        WHERE  case_folder_id = p_case_folder_id
        AND    data_point_id = p_data_point_id;

        IF sql%NOTFOUND
        THEN
            POPULATE_CASE_FOLDER_DETAILS (
                p_case_folder_id            => p_case_folder_id,
                p_data_point_id             => p_data_point_id,
                p_data_point_value          => p_data_point_value,
                p_included_in_check_list    => 'N',
                p_score                     => p_score,
                p_errmsg                    => p_errmsg,
                p_resultout                 => p_resultout);
        END IF;
        EXCEPTION
            WHEN OTHERS THEN
                p_resultout := 1;
                p_errmsg := 'Error While trying to update Case folder Details '||sqlerrm;

END;

PROCEDURE POPULATE_CF_ADP_DETAILS  (
        p_case_folder_id                IN      NUMBER,
        p_data_point_id                 IN      NUMBER,
        p_sequence_number               IN      NUMBER,
        p_parent_data_point_id          IN      NUMBER,
        p_parent_cf_detail_id           IN      NUMBER,
        p_data_point_value              IN      VARCHAR2,
        p_score                         IN      NUMBER default NULL,
        p_included_in_checklist         IN      VARCHAR2 default NULL,
        p_data_point_value_id			IN		NUMBER	default NULL,
        p_case_folder_detail_id         OUT NOCOPY      NUMBER,
        p_errmsg                        OUT NOCOPY     VARCHAR2,
        p_resultout                     OUT NOCOPY     VARCHAR2) IS

BEGIN
        p_resultout := 0;
        POPULATE_CF_DETAILS_PVT
                ( p_case_folder_id,
                  p_data_point_id,
		          p_sequence_number,
                  p_parent_data_point_id,
                  p_parent_cf_detail_id,
                  p_data_point_value,
                  p_score,
                  p_included_in_checklist,
                  p_data_point_value_id,
                  p_case_folder_detail_id,
		          p_errmsg,
		          p_resultout);
END;

PROCEDURE UPDATE_CF_ADP_DETAILS (
        p_case_folder_id                IN      NUMBER,
        p_data_point_id                 IN      NUMBER,
        p_sequence_number               IN      NUMBER,
        p_parent_data_point_id          IN      NUMBER,
        p_parent_cf_detail_id           IN      NUMBER,
        p_data_point_value              IN      VARCHAR2,
        p_score                         IN      NUMBER default NULL,
        p_included_in_checklist         IN      VARCHAR2 default NULL,
        p_data_point_value_id			IN		NUMBER,
        p_case_folder_detail_id         IN OUT NOCOPY     NUMBER,
        x_errmsg                        OUT NOCOPY     VARCHAR2,
        x_resultout                     OUT NOCOPY     VARCHAR2)
IS
BEGIN
        x_resultout := 0;

        UPDATE ar_cmgt_cf_dtls
            SET score = nvl(p_score,score),
                data_point_value = nvl(p_data_point_value, data_point_value),
                last_updated_by = fnd_global.user_id,
                last_update_date = sysdate,
                last_update_login = fnd_global.login_id
        WHERE  case_folder_detail_id = p_case_folder_detail_id
		AND    data_point_id  = p_data_point_id;

		IF sql%NOTFOUND
        THEN
            POPULATE_CF_DETAILS_PVT (
                p_case_folder_id            => p_case_folder_id,
                p_data_point_id             => p_data_point_id,
                p_sequence_number           => p_sequence_number,
                p_parent_data_point_id      => p_parent_data_point_id,
                p_parent_cf_detail_id       => p_parent_cf_detail_id,
                p_data_point_value          => p_data_point_value,
                p_score                     => p_score,
                p_included_in_checklist     => 'N',
                p_data_point_value_id		=> p_data_point_value_id,
                p_case_folder_detail_id     => p_case_folder_detail_id,
                x_errmsg                    => x_errmsg,
                x_resultout                 => x_resultout);
        END IF;
        EXCEPTION
            WHEN OTHERS THEN
                x_resultout := 1;
                x_errmsg := 'Error While trying to update Case folder Details '||sqlerrm;

END;
procedure populate_recommendation(
        p_case_folder_id            IN      NUMBER,
        p_credit_request_id         IN      NUMBER,
        p_score                     IN      NUMBER,
        p_recommended_credit_limit  IN      NUMBER,
        p_credit_review_date        IN      DATE,
        p_credit_recommendation     IN      VARCHAR2,
        p_recommendation_value1     IN      VARCHAR2,
        p_recommendation_value2     IN      VARCHAR2,
        p_status                    IN      VARCHAR2,
        p_credit_type               IN      VARCHAR2,
        p_errmsg                    OUT NOCOPY     VARCHAR2,
        p_resultout                 OUT NOCOPY     VARCHAR2 ) IS

	l_recommendation_name 		ar_cmgt_credit_requests.recommendation_name%type;
	l_appl_id			ar_cmgt_credit_requests.source_resp_appln_id%type;
BEGIN
        p_resultout := 0;
	BEGIN
	   SELECT recommendation_name,source_resp_appln_id
	   INTO   l_recommendation_name, l_appl_id
	   FROM   ar_cmgt_credit_requests
	   WHERE  credit_request_id = p_credit_request_id;
	EXCEPTION
	   WHEN OTHERS THEN
           	p_resultout := 1;
           	p_errmsg := 'Error While Selecting Recommendation Name'||sqlerrm;
		return;
	END;
	IF l_recommendation_name IS NULL
	THEN
	   IF p_credit_type = 'TERM'
	   THEN
		l_recommendation_name := 'AR_CMGT_TERM_RECOMMENDATIONS';
	   ELSIF p_credit_type = 'TRADE'
	   THEN
		l_recommendation_name := 'AR_CMGT_RECOMMENDATIONS';
	   END IF;
	END IF;
        insert into ar_cmgt_cf_recommends
                    ( Recommendation_id,
                       case_folder_id,
                       credit_request_id,
                       credit_review_date,
                       credit_recommendation,
                       recommendation_value1,
                       recommendation_value2,
                       status,
                       last_updated_by,
                       last_update_date,
                       last_update_login,
                       creation_date,
                       created_by,
                       credit_type,
		       recommendation_name,
		       application_id) values
                     (  ar_cmgt_cf_recommends_s.nextval,
                       p_case_folder_id,
                       p_credit_request_id,
                       p_credit_review_date,
                       p_credit_recommendation,
                       p_recommendation_value1,
                       p_recommendation_value2,
                       p_status,
                       fnd_global.user_id,
                       sysdate,
                       fnd_global.login_id,
                       sysdate,
                       fnd_global.user_id,
                       p_credit_type,
		       l_recommendation_name,
		       l_appl_id);
    EXCEPTION
        WHEN OTHERS THEN
           p_resultout := 1;
           p_errmsg := 'Error While creating Recommendation '||sqlerrm;
END;

procedure populate_data_points
	( p_data_point_name		IN		VARCHAR2,
	  p_data_point_category		IN		VARCHAR2,
	  p_user_defined_flag		IN		VARCHAR2,
	  p_scorable_flag		IN		VARCHAR2,
	  p_display_on_checklist	IN		VARCHAR2,
	  p_created_by			IN		NUMBER,
      p_data_point_code     IN      VARCHAR2,
	  p_data_point_id		OUT NOCOPY		NUMBER) IS

BEGIN
   SELECT ar_cmgt_data_points_s.nextval
   INTO   p_data_point_id
   FROM   dual;

   AR_CMGT_DP_TABLE_HANDLER.insert_row(
             	 p_data_point_name	=> p_data_point_name,
	         p_description		=> null,
	         p_data_point_category	=> p_data_point_category,
	         p_user_defined_flag	=> p_user_defined_flag,
	         p_scorable_flag	=> p_scorable_flag,
	         p_display_on_checklist	=> p_display_on_checklist,
	         p_created_by		=> fnd_global.user_id,
	         p_last_updated_by	=> fnd_global.user_id,
	         p_last_update_login	=> fnd_global.login_id,
	         p_data_point_id	=> p_data_point_id,
		 p_return_data_type	=> 'C',
		 p_return_date_format   => null,
		 p_application_id	=> 222,
		 p_parent_data_point_id => null,
		 p_enabled_flag		=> 'N',
		 p_package_name 	=> null,
		 p_function_name	=> null,
		 p_data_point_sub_category => null,
         p_data_point_code => p_data_point_code);

END;

PROCEDURE populate_add_data_points
        ( p_data_point_code		IN		VARCHAR2,
          p_data_point_name             IN              VARCHAR2,
          p_description	                IN              VARCHAR2,
	  	  p_data_point_sub_category     IN              VARCHAR2,
          p_data_point_category         IN              VARCHAR2,
          p_user_defined_flag           IN              VARCHAR2,
          p_scorable_flag               IN              VARCHAR2,
          p_display_on_checklist        IN              VARCHAR2,
          p_created_by                  IN              NUMBER,
          p_application_id              IN              NUMBER,
          p_parent_data_point_id        IN              NUMBER,
          p_enabled_flag                IN              VARCHAR2,
          p_package_name                IN              VARCHAR2,
          p_function_name               IN              VARCHAR2,
          p_function_type				IN				VARCHAR2,
          p_return_data_type			IN				VARCHAR2,
          p_return_date_format			IN				VARCHAR2,
          x_data_point_id        		OUT NOCOPY      NUMBER
	)
IS
l_dp_id NUMBER;
BEGIN

    SELECT ar_cmgt_data_points_s.nextval
    INTO  l_dp_id
    FROM   dual;

    x_data_point_id := l_dp_id;

    AR_CMGT_DP_TABLE_HANDLER.insert_adp_row(
		 p_data_point_code		=> p_data_point_code,
             	 p_data_point_name              => p_data_point_name,
                 p_description                  => p_description,
                 p_data_point_sub_category      => p_data_point_sub_category,
                 p_data_point_category      	=> p_data_point_category,
                 p_user_defined_flag            => p_user_defined_flag,
                 p_scorable_flag                => p_scorable_flag,
                 p_display_on_checklist     	=> p_display_on_checklist,
                 p_created_by                   => fnd_global.user_id,
                 p_last_updated_by              => fnd_global.user_id,
                 p_last_update_login            => fnd_global.login_id,
                 p_data_point_id                => l_dp_id,
                 p_application_id				=> p_application_id,
          	 	 p_parent_data_point_id         => p_parent_data_point_id,
          	 	 p_enabled_flag                 => p_enabled_flag,
          		 p_package_name                 => p_package_name,
          	 	 p_function_name               	=> p_function_name,
			 	 p_function_type				=> p_function_type,
				 p_return_data_type				=> p_return_data_type,
				 p_return_date_format			=> p_return_date_format   );
END;

PROCEDURE populate_aging_dtls(
        p_case_folder_id        IN          NUMBER,
        p_aging_bucket_id       IN          NUMBER,
        p_aging_bucket_line_id  IN          NUMBER,
        p_amount                IN          NUMBER,
        p_error_msg             OUT NOCOPY  VARCHAR2,
        p_resultout             OUT NOCOPY  VARCHAR2) IS
BEGIN
    INSERT INTO AR_CMGT_CF_AGING_DTLS
                (
                 case_folder_id,
                 last_updated_by,
                 last_update_date,
                 last_update_login,
                 creation_date,
                 created_by,
                 aging_bucket_id,
                 aging_bucket_line_id,
                 amount
                )
               values
                (p_case_folder_id,
                 fnd_global.user_id,
                 sysdate,
                 fnd_global.user_id,
                 sysdate,
                 fnd_global.user_id,
                 p_aging_bucket_id,
                 p_aging_bucket_line_id,
                 p_amount
                );
    EXCEPTION
        WHEN OTHERS THEN
            p_error_msg := 'Error While creating Aging records for casefolder id '
                        ||p_case_folder_id ||' SqlError '||sqlerrm;
            p_resultout := 1;
END;

PROCEDURE update_aging_dtls(
        p_case_folder_id            IN          NUMBER,
        p_aging_bucket_id           IN          NUMBER,
        p_aging_bucket_line_id      IN          NUMBER,
        p_amount                    IN          NUMBER,
        p_error_msg                 OUT NOCOPY  VARCHAR2,
        p_resultout                 OUT NOCOPY  VARCHAR2) IS
BEGIN
    UPDATE AR_CMGT_CF_AGING_DTLS
       SET last_updated_by = fnd_global.user_id,
           last_update_date = sysdate,
           last_update_login = fnd_global.login_id,
           amount = p_amount
       WHERE case_folder_id = p_case_folder_id
       AND   aging_bucket_id  = p_aging_bucket_id
       AND   aging_bucket_line_id = p_aging_bucket_line_id;

    EXCEPTION
        WHEN OTHERS THEN
            p_error_msg := 'Error While updating Aging records for casefolder id '
                        ||p_case_folder_id ||' SqlError '||sqlerrm;
            p_resultout := 1;
END;


/*--This procedure creates duplicate case folder in case of appeal and re-submit
--------------------------------------------------------------------------------*/
PROCEDURE DUPLICATE_CASE_FOLDER_TBL
	( p_parnt_case_folder_id		IN      NUMBER ,
	  p_credit_request_id                   IN      NUMBER ,
          p_errmsg                              OUT NOCOPY     VARCHAR2,
          p_resultout                           OUT NOCOPY     VARCHAR2
       ) IS
       l_credit_request_id                      AR_CMGT_CREDIT_REQUESTS.CREDIT_REQUEST_ID%TYPE;
       l_case_folders_id                        AR_CMGT_CASE_FOLDERS.CASE_FOLDER_ID%TYPE;
       BEGIN

       l_credit_request_id := p_credit_request_id;
       l_case_folders_id   := p_parnt_case_folder_id;
       p_resultout :=0;
      -- Create the duplicate record.
      INSERT INTO AR_CMGT_CASE_FOLDERS
                          (
		           CASE_FOLDER_ID,
                           CASE_FOLDER_NUMBER,
                           LAST_UPDATED_BY,
                           LAST_UPDATE_DATE,
                           LAST_UPDATE_LOGIN,
                           CREATION_DATE,
                           CREATED_BY,
                           CREDIT_REQUEST_ID,
                           CHECK_LIST_ID,
                           STATUS,
                           CUST_ACCOUNT_ID,
                           PARTY_ID,
                           SCORE_MODEL_ID,
                           SITE_USE_ID,
                           CREDIT_CLASSIFICATION,
                           REVIEW_TYPE,
                           CREDIT_ANALYST_ID,
                           TYPE,
                           DISPLAY_FLAG,
                           CREATION_DATE_TIME,
                           LAST_UPDATED,
                           LIMIT_CURRENCY,
                           EXCHANGE_RATE_TYPE,
                           REVIEW_CYCLE)
                          ( SELECT AR_CMGT_CASE_FOLDERS_s.NEXTVAL,
                            ar_cmgt_case_folder_number_s.nextval,
                            fnd_global.user_id,
                            SYSDATE,
                            fnd_global.user_id,
                            SYSDATE,
                            fnd_global.login_id,
                            l_credit_request_id,
                            CHECK_LIST_ID,
                            'CREATED',
                            CUST_ACCOUNT_ID,
                            PARTY_ID,
                            SCORE_MODEL_ID,
                            SITE_USE_ID,
                            CREDIT_CLASSIFICATION,
                            REVIEW_TYPE,
                            CREDIT_ANALYST_ID,
                            TYPE,
                            DISPLAY_FLAG,
                            SYSDATE,
                            SYSDATE,
                            LIMIT_CURRENCY,
                            EXCHANGE_RATE_TYPE,
                            REVIEW_CYCLE
                            FROM AR_CMGT_CASE_FOLDERS
                            WHERE CASE_FOLDER_ID = l_case_folders_id
                            AND TYPE = 'CASE') ;
      EXCEPTION
            WHEN OTHERS
                THEN
                    p_errmsg := 'Error while populating Case folder Data '||sqlerrm;
                    p_resultout := 1;
END DUPLICATE_CASE_FOLDER_TBL;

/*--This procedure creates duplicate record for case folder details for appeal and re-submit
------------------------------------------------------------------------------------------*/
PROCEDURE DUPLICATE_CASE_FOLDER_DTLS(
          p_parnt_case_folder_id		IN      NUMBER ,
	  p_credit_request_id                   IN      NUMBER ,
          p_errmsg                              OUT NOCOPY     VARCHAR2,
          p_resultout                           OUT NOCOPY     VARCHAR2
       ) IS
       l_credit_request_id                      AR_CMGT_CREDIT_REQUESTS.CREDIT_REQUEST_ID%TYPE;
       l_case_folders_id                        AR_CMGT_CASE_FOLDERS.CASE_FOLDER_ID%TYPE;
       l_processing_flag                        VARCHAR2(1);
       TYPE list_change_id IS RECORD (
                                                parent    NUMBER,
                                                changed   NUMBER);
       l_rec_changed                            list_change_id;
       TYPE list_of_ids IS                      VARRAY(50000) OF list_change_id;
       rec_changed_ids list_of_ids := list_of_ids();
       counter                                  BINARY_INTEGER;
       counter1                                 BINARY_INTEGER;
       l_seq_num                                AR_CMGT_CF_DTLS.CASE_FOLDER_DETAIL_ID%TYPE;

      CURSOR select_dtls IS
      SELECT case_folder_id,
       DATA_POINT_ID,
       DATA_POINT_VALUE,
       INCLUDED_IN_CHECKLIST,
       SCORE,
       CASE_FOLDER_DETAIL_ID,
       SEQUENCE_NUMBER,
       PARENT_DATA_POINT_ID,
       PARENT_CF_DETAIL_ID
       FROM AR_CMGT_CF_DTLS
       WHERE CASE_FOLDER_ID=p_parnt_case_folder_id;

       BEGIN

       p_resultout :=0;
       l_processing_flag :='Y';
       counter :=1;
       --fetch the newly created case_folder_id.

       BEGIN

       SELECT CASE_FOLDER_ID
       INTO l_case_folders_id
       FROM AR_CMGT_CASE_FOLDERS
       WHERE CREDIT_REQUEST_ID = p_credit_request_id;

       EXCEPTION
            WHEN OTHERS
               THEN
                    p_errmsg := 'Error while fetching Case folder ID '||sqlerrm;
                    p_resultout := 1;
		    l_processing_flag :='N';
       END;

      --create the details record


       IF l_processing_flag = 'Y'

       THEN


      FOR select_dtls_rec IN select_dtls
       LOOP
       BEGIN

        SELECT ar_cmgt_cf_dtls_s.NEXTVAL
        INTO l_seq_num
        FROM dual;

	--store the parent_rec_id and corrosponding seq_num_id

        l_rec_changed.parent := select_dtls_rec.CASE_FOLDER_DETAIL_ID;
        l_rec_changed.changed := l_seq_num;

        rec_changed_ids.EXTEND;

        rec_changed_ids(counter) := l_rec_changed;

        counter := counter +1;



	--insert the records into case folder details.

            INSERT INTO AR_CMGT_CF_DTLS
                          (CASE_FOLDER_ID,
                           DATA_POINT_ID,
                           LAST_UPDATED_BY,
                           LAST_UPDATE_DATE,
                           LAST_UPDATE_LOGIN,
                           CREATION_DATE,
                           CREATED_BY,
                           DATA_POINT_VALUE,
                           INCLUDED_IN_CHECKLIST,
                           SCORE,
                           CASE_FOLDER_DETAIL_ID,
                           SEQUENCE_NUMBER,
                           PARENT_DATA_POINT_ID,
                           PARENT_CF_DETAIL_ID)
			  (select l_case_folders_id,
                                 DATA_POINT_ID,
                                 fnd_global.user_id,
                                 SYSDATE,
                                 fnd_global.login_id,
                                 SYSDATE,
                                 fnd_global.user_id,
                                 DATA_POINT_VALUE,
                                 INCLUDED_IN_CHECKLIST,
                                 SCORE,
                                 l_seq_num,
                                 SEQUENCE_NUMBER,
                                 PARENT_DATA_POINT_ID,
                                 PARENT_CF_DETAIL_ID
                                 FROM AR_CMGT_CF_DTLS
                                 WHERE CASE_FOLDER_ID=p_parnt_case_folder_id
                                 AND CASE_FOLDER_DETAIL_ID = select_dtls_rec.CASE_FOLDER_DETAIL_ID);



             EXCEPTION
                WHEN OTHERS
                    THEN
                    p_errmsg := 'Error while populating Case folder Data '||sqlerrm;
                    p_resultout := 1;

		     l_processing_flag :='N';
		     return;
        END;
        END LOOP;




		--update the records with parent cf detail id
		--with the new changed values
       if  l_processing_flag = 'Y'
       THEN

       counter1 := 1;

       WHILE counter1 < counter
       LOOP
       BEGIN


        l_rec_changed := rec_changed_ids(counter1);
        counter1 := counter1 + 1 ;
      --update the values of parent cf detail id

        UPDATE ar_cmgt_cf_dtls
        SET parent_cf_detail_id = l_rec_changed.changed
        WHERE case_folder_id = l_case_folders_id
        AND   PARENT_CF_DETAIL_ID = l_rec_changed.parent;

	    EXCEPTION
	        WHEN NO_DATA_FOUND
                      THEN
		      --do nothing continue in loop.
                        l_processing_flag :='Y';
                WHEN OTHERS
                    THEN
                    p_errmsg := 'Error while updating Case folder Data '||sqlerrm;
                    p_resultout := 1;

        END;
        END LOOP;

       END IF;



       END IF;
END DUPLICATE_CASE_FOLDER_DTLS;

/*--This procedure creates duplicate record for aging details for appeal and re-submit
------------------------------------------------------------------------------------------*/
PROCEDURE  DUPLICATE_AGING_DATA(
          p_parnt_case_folder_id		IN      NUMBER ,
	  p_credit_request_id                   IN      NUMBER ,
          p_errmsg                              OUT NOCOPY     VARCHAR2,
          p_resultout                           OUT NOCOPY     VARCHAR2
       ) IS
       l_credit_request_id                      AR_CMGT_CREDIT_REQUESTS.CREDIT_REQUEST_ID%TYPE;
       l_case_folders_id                        AR_CMGT_CASE_FOLDERS.CASE_FOLDER_ID%TYPE;
       l_processing_flag                        VARCHAR2(1);
       BEGIN

       p_resultout :=0;
       l_processing_flag := 'Y';
       --fetch the newly created case_folder_id.
       BEGIN

       SELECT CASE_FOLDER_ID
       INTO l_case_folders_id
       FROM AR_CMGT_CASE_FOLDERS
       WHERE CREDIT_REQUEST_ID = p_credit_request_id;

       EXCEPTION
            WHEN OTHERS
               THEN
                    p_errmsg := 'Error while fetching Case folder ID '||sqlerrm;
                    p_resultout := 1;
		    l_processing_flag :='N';
       END;
      --duplicate aging details

      IF l_processing_flag = 'Y'
      THEN

      BEGIN

      INSERT INTO AR_CMGT_CF_AGING_DTLS
                                  (CASE_FOLDER_ID,
                                  LAST_UPDATED_BY,
                                  LAST_UPDATE_DATE,
                                  LAST_UPDATE_LOGIN,
                                  CREATION_DATE,
                                  CREATED_BY,
                                  AGING_BUCKET_ID,
                                  AGING_BUCKET_LINE_ID,
                                  AMOUNT,
                                  COUNT)
                                      (SELECT  l_case_folders_id,
                                       fnd_global.user_id,
                                       SYSDATE,
                                       fnd_global.login_id,
                                       SYSDATE,
                                       fnd_global.user_id,
                                       AGING_BUCKET_ID,
                                       AGING_BUCKET_LINE_ID,
                                       AMOUNT,
                                       COUNT
                                       FROM AR_CMGT_CF_AGING_DTLS
                                       WHERE CASE_FOLDER_ID=p_parnt_case_folder_id);

      EXCEPTION
               WHEN OTHERS
                   THEN
                    p_errmsg := 'Error while populating Aging Data '||sqlerrm;
                    p_resultout := 1;
       END;
       END IF;
END DUPLICATE_AGING_DATA;

/*--This procedure creates duplicate record for DNB DATA for appeal and re-submit
------------------------------------------------------------------------------------------*/
PROCEDURE  DUPLICATE_DNB_DATA(
          p_parnt_case_folder_id		IN      NUMBER  ,
	  p_credit_request_id                   IN      NUMBER  ,
          p_errmsg                              OUT NOCOPY     VARCHAR2,
          p_resultout                           OUT NOCOPY     VARCHAR2
       ) IS
       l_credit_request_id                      AR_CMGT_CREDIT_REQUESTS.CREDIT_REQUEST_ID%TYPE;
       l_case_folders_id                        AR_CMGT_CASE_FOLDERS.CASE_FOLDER_ID%TYPE;
       l_processing_flag                        VARCHAR2(1);
       BEGIN

       p_resultout :=0;
       l_processing_flag := 'Y';
       --fetch the newly created case_folder_id.
       BEGIN

       SELECT CASE_FOLDER_ID
       INTO l_case_folders_id
       FROM AR_CMGT_CASE_FOLDERS
       WHERE CREDIT_REQUEST_ID = p_credit_request_id;

       EXCEPTION
            WHEN OTHERS
               THEN
                    p_errmsg := 'Error while fetching Case folder ID '||sqlerrm;
                    p_resultout := 1;
		    l_processing_flag :='N';
       END;
      --duplicate DNB data.
      IF l_processing_flag = 'Y'
      THEN

      BEGIN
              INSERT INTO AR_CMGT_CF_DNB_DTLS
	                      (CASE_FOLDER_ID,
                               SOURCE_TABLE_NAME,
                               SOURCE_KEY,
                               SOURCE_KEY_TYPE,
                               SOURCE_KEY_COLUMN_NAME,
                               SOURCE_KEY_COLUMN_TYPE_NAME,
                               LAST_UPDATED_BY,
                               LAST_UPDATE_DATE,
                               LAST_UPDATE_LOGIN,
                               CREATION_DATE,
                               CREATED_BY)
                                             (SELECT l_case_folders_id,
                                                      SOURCE_TABLE_NAME,
                                                      SOURCE_KEY,
                                                      SOURCE_KEY_TYPE,
                                                      SOURCE_KEY_COLUMN_NAME,
                                                      SOURCE_KEY_COLUMN_TYPE_NAME,
                                                      fnd_global.user_id,
                                                      sysdate,
                                                      fnd_global.login_id,
                                                      sysdate,
                                                      fnd_global.user_id
                                                      FROM AR_CMGT_CF_DNB_DTLS
                                                      WHERE CASE_FOLDER_ID=p_parnt_case_folder_id);
      EXCEPTION
               WHEN OTHERS
                   THEN
                    p_errmsg := 'Error while populating DNB Data '||sqlerrm;
                    p_resultout := 1;
       END;
       END IF;
END DUPLICATE_DNB_DATA;

/*--This procedure creates duplicate record for financial data for appeal and re-submit
------------------------------------------------------------------------------------------*/
PROCEDURE  DUPLICATE_FINANCIAL_DATA(
          p_parnt_credit_req_id  		IN      NUMBER   ,
	  p_credit_request_id                   IN      NUMBER   ,
          p_errmsg                              OUT NOCOPY     VARCHAR2,
          p_resultout                           OUT NOCOPY     VARCHAR2
       ) IS
       l_credit_request_id                      AR_CMGT_CREDIT_REQUESTS.CREDIT_REQUEST_ID%TYPE;
       l_case_folders_id                        AR_CMGT_CASE_FOLDERS.CASE_FOLDER_ID%TYPE;
       l_processing_flag                        VARCHAR2(1);
       BEGIN
       l_credit_request_id := p_credit_request_id;
       p_resultout :=0;
       l_processing_flag := 'Y';
       --fetch the newly created case_folder_id.
       BEGIN

       SELECT CASE_FOLDER_ID
       INTO l_case_folders_id
       FROM AR_CMGT_CASE_FOLDERS
       WHERE CREDIT_REQUEST_ID = p_credit_request_id;

       EXCEPTION
            WHEN OTHERS
               THEN
                    p_errmsg := 'Error while fetching Case folder ID '||sqlerrm;
                    p_resultout := 1;
		    l_processing_flag :='N';
       END;
      --duplicate financial data.
      IF l_processing_flag = 'Y'
      THEN
      BEGIN

             INSERT INTO AR_CMGT_FINANCIAL_DATA
	                  (FINANCIAL_DATA_ID,
                          CREDIT_REQUEST_ID,
                          LAST_UPDATE_DATE,
                          LAST_UPDATED_BY,
                          CREATION_DATE,
                          CREATED_BY,
                          LAST_UPDATE_LOGIN,
                          REPORTING_CURRENCY,
                          MONETARY_UNIT,
                          CURR_FIN_ST_DATE,
                          REPORTING_PERIOD,
                          CASH,
                          ACCOUNTS_PAYABLE,
                          NET_RECEIVABLES,
                          SHORT_TERM_DEBT,
                          INVENTORIES,
                          OTHER_CUR_LIABILITIES,
                          OTHER_CUR_ASSETS,
                          TOTAL_CUR_LIABILITIES,
                          TOTAL_CUR_ASSETS,
                          LONG_TERM_DEBT,
                          NET_FIXED_ASSETS,
                          OTHER_NON_CUR_LIABILITIES,
                          OTHER_NON_CUR_ASSETS,
                          TOTAL_LIABILITIES,
                          TOTAL_ASSETS,
                          STOCKHOLDER_EQUITY,
                          TOTAL_LIABILITIES_EQUITY,
                          REVENUE,
                          NON_OPERATING_INCOME,
                          COST_OF_GOODS_SOLD,
                          NON_OPERATING_EXPENSES,
                          SGA_EXPENSES,
                          PRE_TAX_NET_INCOME,
                          OPERATING_INCOME,
                          INCOME_TAXES,
                          OPERATING_MARGIN,
                          NET_INCOME,
                          EARNINGS_PER_SHARE,
                          CASE_FOLDER_ID,
                          PARTY_ID,
                          CUST_ACCOUNT_ID,
                          SITE_USE_ID)
                          (SELECT AR_CMGT_FINANCIAL_DATA_S.nextval,
                          l_credit_request_id,
                          SYSDATE,
                          fnd_global.user_id,
                          SYSDATE,
                          fnd_global.user_id,
                          fnd_global.login_id,
                          REPORTING_CURRENCY,
                          MONETARY_UNIT,
                          CURR_FIN_ST_DATE,
                          REPORTING_PERIOD,
                          CASH,
                          ACCOUNTS_PAYABLE,
                          NET_RECEIVABLES,
                          SHORT_TERM_DEBT,
                          INVENTORIES,
                          OTHER_CUR_LIABILITIES,
                          OTHER_CUR_ASSETS,
                          TOTAL_CUR_LIABILITIES,
                          TOTAL_CUR_ASSETS,
                          LONG_TERM_DEBT,
                          NET_FIXED_ASSETS,
                          OTHER_NON_CUR_LIABILITIES,
                          OTHER_NON_CUR_ASSETS,
                          TOTAL_LIABILITIES,
                          TOTAL_ASSETS,
                          STOCKHOLDER_EQUITY,
                          TOTAL_LIABILITIES_EQUITY,
                          REVENUE,
                          NON_OPERATING_INCOME,
                          COST_OF_GOODS_SOLD,
                          NON_OPERATING_EXPENSES,
                          SGA_EXPENSES,
                          PRE_TAX_NET_INCOME,
                          OPERATING_INCOME,
                          INCOME_TAXES,
                          OPERATING_MARGIN,
                          NET_INCOME,
                          EARNINGS_PER_SHARE,
                          nvl(l_case_folders_id,-99),
			  PARTY_ID,
                          CUST_ACCOUNT_ID,
			  SITE_USE_ID
			  FROM AR_CMGT_FINANCIAL_DATA
			  WHERE CREDIT_REQUEST_ID = p_parnt_credit_req_id);

      EXCEPTION
               WHEN OTHERS
                   THEN
                    p_errmsg := 'Error while populating Financial  Data '||sqlerrm;
                    p_resultout := 1;
       END;
       END IF;
END DUPLICATE_FINANCIAL_DATA;

/*--This procedure creates duplicate record for Trade references for appeal and re-submit
------------------------------------------------------------------------------------------*/
PROCEDURE  DUPLICATE_TRADE_DATA(
          p_parnt_credit_req_id  		IN      NUMBER  ,
	  p_credit_request_id                   IN      NUMBER  ,
          p_errmsg                              OUT NOCOPY     VARCHAR2,
          p_resultout                           OUT NOCOPY     VARCHAR2
       ) IS
       l_credit_request_id                      AR_CMGT_CREDIT_REQUESTS.CREDIT_REQUEST_ID%TYPE;
       l_case_folders_id                        AR_CMGT_CASE_FOLDERS.CASE_FOLDER_ID%TYPE;
       l_processing_flag                        VARCHAR2(1);
       BEGIN
       l_credit_request_id := p_credit_request_id;
       p_resultout :=0;
       l_processing_flag := 'Y';
       --fetch the newly created case_folder_id.
       BEGIN

       SELECT CASE_FOLDER_ID
       INTO l_case_folders_id
       FROM AR_CMGT_CASE_FOLDERS
       WHERE CREDIT_REQUEST_ID = p_credit_request_id;

       EXCEPTION
            WHEN OTHERS
               THEN
                    p_errmsg := 'Error while fetching Case folder ID '||sqlerrm;
                    p_resultout := 1;
		    l_processing_flag :='N';
       END;
      --duplicate trade ref data.

      IF l_processing_flag = 'Y'
      THEN

      BEGIN

      INSERT INTO ar_cmgt_trade_ref_data
                          (DATAPOINT_ID,
                           CREDIT_REQUEST_ID,
                           LAST_UPDATE_DATE,
                           LAST_UPDATED_BY,
                           CREATION_DATE,
                           CREATED_BY,
                           LAST_UPDATE_LOGIN,
                           COUNTRY,
                           TAX_NUMBER,
                           REFERENCE_NAME,
                           CONTACT_NAME,
                           ADDRESS,
                           PHONE_NUMBER,
                           CITY,
                           FAX_NUMBER,
                           STATE,
                           EMAIL,
                           POSTAL_CODE,
                           PROVINCE,
                           URL,
                           REPORT_DATE,
                           LAST_TRANSACTION_DATE,
                           NUMBERS_OF_YEARS_IN_TRADE,
                           PAYMENT_TERMS,
                           CREDIT_LIMIT,
                           CURRENCY,
                           AMOUNT_OWED,
                           CREDIT_BALANCE,
                           PAST_DUE_AMOUNT,
                           INTERNAL_TRADE_RATING,
                           CASE_FOLDER_ID,
                           NOTES)
                          (SELECT  AR_CMGT_TRADE_REF_DATA_S.NEXTVAL,
                           l_credit_request_id,
                           SYSDATE,
                           fnd_global.user_id,
                           SYSDATE,
                           fnd_global.user_id,
                           fnd_global.login_id,
                           COUNTRY,
                           TAX_NUMBER,
                           REFERENCE_NAME,
                           CONTACT_NAME,
                           ADDRESS,
                           PHONE_NUMBER,
                           CITY,
                           FAX_NUMBER,
                           STATE,
                           EMAIL,
                           POSTAL_CODE,
                           PROVINCE,
                           URL,
                           REPORT_DATE,
                           LAST_TRANSACTION_DATE,
                           NUMBERS_OF_YEARS_IN_TRADE,
                           PAYMENT_TERMS,
                           CREDIT_LIMIT,
                           CURRENCY,
                           AMOUNT_OWED,
                           CREDIT_BALANCE,
                           PAST_DUE_AMOUNT,
                           INTERNAL_TRADE_RATING,
                           nvl(l_case_folders_id,-99),
                           NOTES
			   FROM AR_CMGT_TRADE_REF_DATA
			   WHERE CREDIT_REQUEST_ID= p_parnt_credit_req_id);

      EXCEPTION
               WHEN OTHERS
                   THEN
                    p_errmsg := 'Error while populating Trade Data '||sqlerrm;
                    p_resultout := 1;
       END;
       END IF;
END DUPLICATE_TRADE_DATA;

/*--This procedure creates duplicate record for bank accounts for appeal and re-submit
------------------------------------------------------------------------------------------*/
PROCEDURE  DUPLICATE_BANK_DATA(
          p_parnt_credit_req_id  		IN      NUMBER  ,
	  p_credit_request_id                   IN      NUMBER  ,
          p_errmsg                              OUT NOCOPY     VARCHAR2,
          p_resultout                           OUT NOCOPY     VARCHAR2
       ) IS
       l_credit_request_id                      AR_CMGT_CREDIT_REQUESTS.CREDIT_REQUEST_ID%TYPE;
       l_case_folders_id                        AR_CMGT_CASE_FOLDERS.CASE_FOLDER_ID%TYPE;
       l_data_point_id                          ar_cmgt_bank_ref_data.DATAPOINT_ID%TYPE;
       l_next_val                               ar_cmgt_bank_ref_data.DATAPOINT_ID%TYPE;
       l_processing_flag                        VARCHAR2(1);

      CURSOR bank_data IS
      SELECT DATAPOINT_ID
      FROM   ar_cmgt_bank_ref_data
      WHERE  CREDIT_REQUEST_ID = p_parnt_credit_req_id;

       BEGIN
       l_credit_request_id := p_credit_request_id;
       p_resultout :=0;
       l_processing_flag := 'Y';
       --fetch the newly created case_folder_id.
       BEGIN

       SELECT CASE_FOLDER_ID
       INTO l_case_folders_id
       FROM AR_CMGT_CASE_FOLDERS
       WHERE CREDIT_REQUEST_ID = p_credit_request_id;

       EXCEPTION
            WHEN OTHERS
               THEN
                    p_errmsg := 'Error while fetching Case folder ID '||sqlerrm;
                    p_resultout := 1;
		    l_processing_flag :='N';
       END;
      --duplicate bank ref data.

      IF l_processing_flag = 'Y'
      THEN

      BEGIN

      FOR bank_data_rec IN bank_data
      LOOP

      BEGIN

         l_data_point_id := bank_data_rec.DATAPOINT_ID;

	 SELECT  AR_CMGT_BANK_REF_DATA_S.NEXTVAL
         INTO   l_next_val FROM dual;

      INSERT INTO ar_cmgt_bank_ref_data
                          (DATAPOINT_ID,
                           CREDIT_REQUEST_ID,
                           LAST_UPDATE_DATE,
                           LAST_UPDATED_BY,
                           CREATION_DATE,
                           CREATED_BY,
                           LAST_UPDATE_LOGIN,
                           BANK_NAME,
                           ADDRESS,
                           CITY,
                           STATE,
                           POSTAL_CODE,
                           PROVINCE,
                           COUNTRY,
                           CONTACT_NAME,
                           PHONE,
                           FAX,
                           EMAIL,
                           URL,
                           BANK_ROUTING_NUMBER,
                           CASE_FOLDER_ID,
                           NOTES)
                          (SELECT l_next_val,
                           l_credit_request_id,
                           SYSDATE,
                           fnd_global.user_id,
                           SYSDATE,
                           fnd_global.user_id,
                           fnd_global.login_id,
                           BANK_NAME,
                           ADDRESS,
                           CITY,
                           STATE,
                           POSTAL_CODE,
                           PROVINCE,
                           COUNTRY,
                           CONTACT_NAME,
                           PHONE,
                           FAX,
                           EMAIL,
                           URL,
                           BANK_ROUTING_NUMBER,
                           nvl(l_case_folders_id,-99),
                           NOTES
                          FROM ar_cmgt_bank_ref_data
                          WHERE CREDIT_REQUEST_ID = p_parnt_credit_req_id
			  AND DATAPOINT_ID = l_data_point_id);

      -- duplicate the account details.


      INSERT INTO AR_CMGT_BANK_REF_ACCTS
                          (BANK_REFERENCE_ACCOUNT_ID,
                           DATAPOINT_ID,
                           CREDIT_REQUEST_ID,
                           LAST_UPDATE_DATE,
                           LAST_UPDATED_BY,
                           CREATION_DATE,
                           CREATED_BY,
                           LAST_UPDATE_LOGIN,
                           ACCOUNT_NUMBER,
                           ACCOUNT_TYPE,
                           DATE_OPENED,
                           CURRENCY,
                           CURRENT_BALANCE,
                           BALANCE_DATE,
                           AVERAGE_BALANCE)
                          ( SELECT AR_CMGT_BANK_REF_ACCTS_S.NEXTVAL,
                           l_next_val,
                           l_credit_request_id,
                           SYSDATE,
                           fnd_global.user_id,
                           SYSDATE,
                           fnd_global.user_id,
                           fnd_global.login_id,
                           ACCOUNT_NUMBER,
                           ACCOUNT_TYPE,
                           DATE_OPENED,
                           CURRENCY,
                           CURRENT_BALANCE,
                           BALANCE_DATE,
                           AVERAGE_BALANCE
                          FROM AR_CMGT_BANK_REF_ACCTS
                          WHERE CREDIT_REQUEST_ID= p_parnt_credit_req_id
			  AND DATAPOINT_ID = l_data_point_id);


      EXCEPTION
               WHEN OTHERS
                   THEN
                    p_errmsg := 'Error while populating bank Account Data '||sqlerrm;
                    p_resultout := 1;
    END;
    END LOOP;
    END;
    END IF;
END DUPLICATE_BANK_DATA;

/*--This procedure creates duplicate record for collateral data for appeal and re-submit
------------------------------------------------------------------------------------------*/
PROCEDURE  DUPLICATE_COLLATERAL_DATA(
          p_parnt_credit_req_id  		IN      NUMBER  ,
	  p_credit_request_id                   IN      NUMBER  ,
          p_errmsg                              OUT NOCOPY     VARCHAR2,
          p_resultout                           OUT NOCOPY     VARCHAR2
       ) IS
       l_credit_request_id                      AR_CMGT_CREDIT_REQUESTS.CREDIT_REQUEST_ID%TYPE;
       l_case_folders_id                        AR_CMGT_CASE_FOLDERS.CASE_FOLDER_ID%TYPE;
       l_processing_flag                        VARCHAR2(1);
       BEGIN

       l_credit_request_id := p_credit_request_id;
       p_resultout :=0;
       l_processing_flag := 'Y';

       --fetch the newly created case_folder_id.
       BEGIN

       SELECT CASE_FOLDER_ID
       INTO l_case_folders_id
       FROM AR_CMGT_CASE_FOLDERS
       WHERE CREDIT_REQUEST_ID = p_credit_request_id;

       EXCEPTION
            WHEN OTHERS
               THEN
                    p_errmsg := 'Error while fetching Case folder ID '||sqlerrm;
                    p_resultout := 1;
		    l_processing_flag :='N';
       END;
      --duplicate trade ref data.

      IF l_processing_flag = 'Y'
      THEN
      BEGIN

      INSERT INTO ar_cmgt_collateral_data
                          (DATAPOINT_ID,
                           CREDIT_REQUEST_ID,
                           LAST_UPDATE_DATE,
                           LAST_UPDATED_BY,
                           CREATION_DATE,
                           CREATED_BY,
                           LAST_UPDATE_LOGIN,
                           COLLATERAL_DESCRIPTION,
                           COLLATERAL_CATEGORY,
                           COLLATERAL_VALUE,
                           COLLATERAL_CURRENCY,
                           VALUATION_TYPE,
                           VALUATION_DATE,
                           PREV_VALUATION_DATE,
                           APPRAISER_NAME,
                           APPRAISER_PHONE_NUMBER,
                           COLLATERAL_LOCATION,
                           CASE_FOLDER_ID,
                           NOTES)
                          ( SELECT  AR_CMGT_COLLATERAL_DATA_S.NEXTVAL,
                           l_credit_request_id,
                           SYSDATE,
                           fnd_global.user_id,
                           SYSDATE,
                           fnd_global.user_id,
                           fnd_global.login_id,
                           COLLATERAL_DESCRIPTION,
                           COLLATERAL_CATEGORY,
                           COLLATERAL_VALUE,
                           COLLATERAL_CURRENCY,
                           VALUATION_TYPE,
                           VALUATION_DATE,
                           PREV_VALUATION_DATE,
                           APPRAISER_NAME,
                           APPRAISER_PHONE_NUMBER,
                           COLLATERAL_LOCATION,
                           nvl(l_case_folders_id,-99),
                           NOTES
                           FROM ar_cmgt_collateral_data
                           WHERE CREDIT_REQUEST_ID = p_parnt_credit_req_id);

      EXCEPTION
               WHEN OTHERS
                   THEN
                    p_errmsg := 'Error while populating Collateral Data '||sqlerrm;
                    p_resultout := 1;

    END;
    END IF;
END DUPLICATE_COLLATERAL_DATA;

/*--This procedure creates duplicate record for other data for appeal and re-submit
------------------------------------------------------------------------------------------*/
PROCEDURE  DUPLICATE_OTHER_DATA(
          p_parnt_credit_req_id  		IN      NUMBER  ,
	  p_credit_request_id                   IN      NUMBER  ,
          p_errmsg                              OUT NOCOPY     VARCHAR2,
          p_resultout                           OUT NOCOPY     VARCHAR2
       ) IS
       l_credit_request_id                      AR_CMGT_CREDIT_REQUESTS.CREDIT_REQUEST_ID%TYPE;
       l_case_folders_id                        AR_CMGT_CASE_FOLDERS.CASE_FOLDER_ID%TYPE;
       l_processing_flag                        VARCHAR2(1);
       BEGIN

       l_credit_request_id := p_credit_request_id;
       p_resultout :=0;
       l_processing_flag := 'Y';

       --fetch the newly created case_folder_id.
       BEGIN

       SELECT CASE_FOLDER_ID
       INTO l_case_folders_id
       FROM AR_CMGT_CASE_FOLDERS
       WHERE CREDIT_REQUEST_ID = p_credit_request_id;

       EXCEPTION
            WHEN OTHERS
               THEN
                    p_errmsg := 'Error while fetching Case folder ID '||sqlerrm;
                    p_resultout := 1;
		    l_processing_flag :='N';
       END;
      --duplicate trade ref data.

      IF l_processing_flag = 'Y'
      THEN
      BEGIN

      INSERT INTO ar_cmgt_other_data
                          (DATAPOINT_ID,
                           CREDIT_REQUEST_ID,
                           LAST_UPDATE_DATE,
                           LAST_UPDATED_BY,
                           CREATION_DATE,
                           CREATED_BY,
                           LAST_UPDATE_LOGIN,
                           COUNTRY,
                           KEY_EXECUTIVE,
                           VENTURE_CAPITAL_NAME,
                           VC_CONTACT_NAME,
                           VC_ADDRESS,
                           VC_CONTACT_PHONE,
                           VC_STATE,
                           VC_CONTACT_FAX,
                           VC_POSTAL_CODE,
                           VC_PROVINCE,
                           VC_CONTACT_EMAIL,
                           CAPITAL_STAGE_COMPLETED,
                           CURRENCY,
                           FUNDING_AMOUNT,
                           PERCENT_INVESTED,
                           BURN_RATE,
                           FUTURE_FUNDING_PLANS,
                           NOTES,
                           CASE_FOLDER_ID)
                          ( SELECT  AR_CMGT_OTHER_DATA_S.NEXTVAL,
                           l_credit_request_id,
                           SYSDATE,
                           fnd_global.user_id,
                           SYSDATE,
                           fnd_global.user_id,
                           fnd_global.login_id,
                           COUNTRY,
                           KEY_EXECUTIVE,
                           VENTURE_CAPITAL_NAME,
                           VC_CONTACT_NAME,
                           VC_ADDRESS,
                           VC_CONTACT_PHONE,
                           VC_STATE,
                           VC_CONTACT_FAX,
                           VC_POSTAL_CODE,
                           VC_PROVINCE,
                           VC_CONTACT_EMAIL,
                           CAPITAL_STAGE_COMPLETED,
                           CURRENCY,
                           FUNDING_AMOUNT,
                           PERCENT_INVESTED,
                           BURN_RATE,
                           FUTURE_FUNDING_PLANS,
                           NOTES,
                           nvl(l_case_folders_id,-99)
                           FROM ar_cmgt_other_data
                           WHERE CREDIT_REQUEST_ID = p_parnt_credit_req_id);

      EXCEPTION
               WHEN OTHERS
                   THEN
                    p_errmsg := 'Error while populating other Data '||sqlerrm;
                    p_resultout := 1;

    END;
    END IF;
END DUPLICATE_OTHER_DATA;

/*--This procedure creates duplicate record for recommendations for appeal and re-submit
------------------------------------------------------------------------------------------*/
PROCEDURE  DUPLICATE_RECO_DATA(
          p_parnt_case_folder_id  		IN      NUMBER   ,
	  p_credit_request_id                   IN      NUMBER   ,
          p_errmsg                              OUT NOCOPY     VARCHAR2,
          p_resultout                           OUT NOCOPY     VARCHAR2
       ) IS
       l_credit_request_id                      AR_CMGT_CREDIT_REQUESTS.CREDIT_REQUEST_ID%TYPE;
       l_case_folders_id                        AR_CMGT_CASE_FOLDERS.CASE_FOLDER_ID%TYPE;
       l_processing_flag                        VARCHAR2(1);
       BEGIN

       l_credit_request_id := p_credit_request_id;
       p_resultout :=0;
       l_processing_flag := 'Y';

       --fetch the newly created case_folder_id.
       BEGIN

       SELECT CASE_FOLDER_ID
       INTO l_case_folders_id
       FROM AR_CMGT_CASE_FOLDERS
       WHERE CREDIT_REQUEST_ID = p_credit_request_id;

       EXCEPTION
            WHEN OTHERS
               THEN
                    p_errmsg := 'Error while fetching Case folder ID '||sqlerrm;
                    p_resultout := 1;
		    l_processing_flag :='N';
       END;
      --duplicate trade ref data.

      IF l_processing_flag = 'Y'
      THEN
      BEGIN
          INSERT INTO AR_CMGT_CF_RECOMMENDS
	                   (RECOMMENDATION_ID,
                           LAST_UPDATED_BY,
                           LAST_UPDATE_DATE,
                           LAST_UPDATE_LOGIN,
                           CREATION_DATE,
                           CREATED_BY,
                           CASE_FOLDER_ID,
                           CREDIT_REQUEST_ID,
                           CREDIT_REVIEW_DATE,
                           CREDIT_RECOMMENDATION,
                           RECOMMENDATION_VALUE1,
                           RECOMMENDATION_VALUE2,
                           STATUS,
                           CREDIT_TYPE,
                           RECOMMENDATION_NAME,
                           APPLICATION_ID)
			   (SELECT AR_CMGT_CF_RECOMMENDS_S.NEXTVAL,
			   fnd_global.user_id,
                           SYSDATE,
                           fnd_global.login_id,
                           SYSDATE,
                           fnd_global.user_id,
                           l_case_folders_id,
                           l_credit_request_id,
                           CREDIT_REVIEW_DATE,
                           CREDIT_RECOMMENDATION,
                           RECOMMENDATION_VALUE1,
                           RECOMMENDATION_VALUE2,
                           STATUS,
                           CREDIT_TYPE,
                           RECOMMENDATION_NAME,
                           APPLICATION_ID
			   FROM AR_CMGT_CF_RECOMMENDS
			   WHERE CASE_FOLDER_ID= p_parnt_case_folder_id);
      EXCEPTION
               WHEN OTHERS
                   THEN
                    p_errmsg := 'Error while populating Recommendation Data '||sqlerrm;
                    p_resultout := 1;

    END;
    END IF;
END DUPLICATE_RECO_DATA;


/*--This procedure creates duplicate record for analysis NOTES for appeal and re-submit
------------------------------------------------------------------------------------------*/
PROCEDURE  DUPLICATE_NOTES_DATA(
          p_parnt_case_folder_id		IN      NUMBER  ,
	  p_credit_request_id                   IN      NUMBER  ,
          p_errmsg                              OUT NOCOPY     VARCHAR2,
          p_resultout                           OUT NOCOPY     VARCHAR2
       ) IS
       l_credit_request_id                      AR_CMGT_CREDIT_REQUESTS.CREDIT_REQUEST_ID%TYPE;
       l_case_folders_id                        AR_CMGT_CASE_FOLDERS.CASE_FOLDER_ID%TYPE;
       l_processing_flag                        VARCHAR2(1);
       BEGIN

       p_resultout :=0;
       l_processing_flag := 'Y';
       --fetch the newly created case_folder_id.
       BEGIN

       SELECT CASE_FOLDER_ID
       INTO l_case_folders_id
       FROM AR_CMGT_CASE_FOLDERS
       WHERE CREDIT_REQUEST_ID = p_credit_request_id;

       EXCEPTION
            WHEN OTHERS
               THEN
                    p_errmsg := 'Error while fetching Case folder ID '||sqlerrm;
                    p_resultout := 1;
		    l_processing_flag :='N';
       END;
      --duplicate NOTES data.
      IF l_processing_flag = 'Y'
      THEN

      BEGIN
              INSERT INTO AR_CMGT_CF_ANL_NOTES
                           (ANALYSIS_NOTES_ID,
                           CASE_FOLDER_ID,
                           LAST_UPDATED_BY,
                           LAST_UPDATE_DATE,
                           LAST_UPDATE_LOGIN,
                           CREATION_DATE,
                           CREATED_BY,
                           TOPIC,
                           DISPLAY,
                           IMPORTANCE,
                           NOTES,
                           DATE_OPENED)
                           (SELECT AR_CMGT_CF_ANL_NOTES_S.NEXTVAL,
                           l_case_folders_id,
                           fnd_global.user_id,
                           sysdate,
                           fnd_global.login_id,
                           sysdate,
                           fnd_global.user_id,
                           TOPIC,
                           DISPLAY,
                           IMPORTANCE,
                           NOTES,
                           DATE_OPENED
			   FROM AR_CMGT_CF_ANL_NOTES
			   WHERE CASE_FOLDER_ID= p_parnt_case_folder_id);
      EXCEPTION
               WHEN OTHERS
                   THEN
                    p_errmsg := 'Error while populating Analysis Notes Data '||sqlerrm;
                    p_resultout := 1;
       END;
       END IF;
END DUPLICATE_NOTES_DATA;

PROCEDURE UPDATE_CASEFOLDER_DETAILS(
              P_DATA_POINT_ID    IN NUMBER,
              P_CASE_FOLDER_ID   IN NUMBER,
              P_RESULT           OUT NOCOPY NUMBER) IS
BEGIN
--initialization
P_RESULT:=0;
BEGIN
--update the included in checklist flag to "Y"

update ar_cmgt_cf_dtls
set included_in_checklist = 'Y'
where case_folder_id=P_CASE_FOLDER_ID
and (data_point_id=P_DATA_POINT_ID
OR PARENT_DATA_POINT_ID =P_DATA_POINT_ID);

EXCEPTION

       WHEN NO_DATA_FOUND
        THEN
            P_RESULT := 1;
            return;
        WHEN TOO_MANY_ROWS
        THEN
            NULL;
        WHEN OTHERS THEN
             P_RESULT := 1;
             return;
END;
END;

PROCEDURE UPDATE_CF_DETAILS_NEGATION(
              P_DATA_POINT_ID    IN NUMBER,
              P_CASE_FOLDER_ID   IN NUMBER,
              P_RESULT           OUT NOCOPY NUMBER) IS
BEGIN
--initialization
P_RESULT:=0;
BEGIN
--update the included in checklist flag to "Y"

update ar_cmgt_cf_dtls
set included_in_checklist = 'N'
where case_folder_id=P_CASE_FOLDER_ID
and data_point_id=P_DATA_POINT_ID;

EXCEPTION

       WHEN NO_DATA_FOUND
        THEN
            P_RESULT := 1;
            return;
        WHEN TOO_MANY_ROWS
        THEN
            NULL;
        WHEN OTHERS THEN
             P_RESULT := 1;
             return;
END;
END;


END AR_CMGT_CONTROLS;

/
