--------------------------------------------------------
--  DDL for Package Body AR_CMGT_REFRESH_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CMGT_REFRESH_CONC" AS
/* $Header: ARCMRFHB.pls 115.7 2003/10/10 14:23:41 mraymond noship $ */


PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
PROCEDURE submit_refresh_request(
       p_case_folder_id               IN     NUMBER,
       p_called_from                  IN     VARCHAR2,
       p_conc_request_id              OUT NOCOPY    NUMBER
      ) IS

l_options_ok  BOOLEAN;
l_request_id  NUMBER;
m_request_id  NUMBER;

BEGIN
      arp_util.debug('ar_cmgt_refresh_conc.submit_refresh_request (+)');

      l_options_ok := FND_REQUEST.SET_OPTIONS (
                      implicit      => 'NO'
                    , protected     => 'YES'
                    , language      => ''
                    , territory     => '');
      IF (l_options_ok)
      THEN

        m_request_id := FND_REQUEST.SUBMIT_REQUEST(
                 application   => 'AR'
                , program       => 'ARCMRFHB'
                , description   => ''
                , start_time    => ''
                , sub_request   => FALSE
                , argument1     => to_char(p_case_folder_id)
                , argument2     => p_called_from
                , argument3     => chr(0)
                , argument4     => ''
                , argument5     => ''
                , argument6     => ''
                , argument7     => ''
                , argument8     => ''
                , argument9     => ''
                , argument10    => ''
                , argument11    => ''
                , argument12    => ''
                , argument13    => ''
                , argument14    => ''
                , argument15    => ''
                , argument16    => ''
                , argument17    => ''
                , argument18    => ''
                , argument19    => ''
                , argument20    => ''
                , argument21    => ''
                , argument22    => ''
                , argument23    => ''
                , argument24    => ''
                , argument25    => ''
                , argument26    => ''
                , argument27    => ''
                , argument28    => ''
                , argument29    => ''
                , argument30    => ''
                , argument31    => ''
                , argument32    => ''
                , argument33    => ''
                , argument34    => ''
                , argument35    => ''
                , argument36    => ''
                , argument37    => ''
                , argument38    => ''
                , argument39    => ''
                , argument40    => ''
                , argument41    => ''
                , argument42    => ''
                , argument43    => ''
                , argument44    => ''
                , argument45    => ''
                , argument46    => ''
                , argument47    => ''
                , argument48    => ''
                , argument49    => ''
                , argument50    => ''
                , argument51    => ''
                , argument52    => ''
                , argument53    => ''
                , argument54    => ''
                , argument55    => ''
                , argument56    => ''
                , argument57    => ''
                , argument58    => ''
                , argument59    => ''
                , argument61    => ''
                , argument62    => ''
                , argument63    => ''
                , argument64    => ''
                , argument65    => ''
                , argument66    => ''
                , argument67    => ''
                , argument68    => ''
                , argument69    => ''
                , argument70    => ''
                , argument71    => ''
                , argument72    => ''
                , argument73    => ''
                , argument74    => ''
                , argument75    => ''
                , argument76    => ''
                , argument77    => ''
                , argument78    => ''
                , argument79    => ''
                , argument80    => ''
                , argument81    => ''
                , argument82    => ''
                , argument83    => ''
                , argument84    => ''
                , argument85    => ''
                , argument86    => ''
                , argument87    => ''
                , argument88    => ''
                , argument89    => ''
                , argument90    => ''
                , argument91    => ''
                , argument92    => ''
                , argument93    => ''
                , argument94    => ''
                , argument95    => ''
                , argument96    => ''
                , argument97    => ''
                , argument98    => ''
                , argument99    => ''
                , argument100   => '');
                commit;
   END IF;

   p_conc_request_id := m_request_id;

   arp_util.debug('ar_cmgt_refresh_conc.submit_refresh_request (+)');

END;


PROCEDURE refresh_case_folder(
       errbuf                         IN OUT NOCOPY VARCHAR2,
       retcode                        IN OUT NOCOPY VARCHAR2,
       p_case_folder_id               IN     NUMBER,
       p_called_from                  IN     VARCHAR2
      ) IS

l_called_from      VARCHAR2(50);
case_folders_rec    ar_cmgt_case_folders%ROWTYPE;
l_return_status    VARCHAR2(1);

l_limit_currency        VARCHAR2(50);
l_error_msg             VARCHAR2(2000);
l_resultout             VARCHAR2(100);

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('ar_cmgt_refresh_conc.refresh_case_folder (+)');
   END IF;

 --Print in variables
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('refresh_case_folder: ' || 'p_case_folder_id          :'||p_case_folder_id);
      arp_util.debug('refresh_case_folder: ' || 'p_called_from             :'||p_called_from);
   END IF;

 --Set the return status to success
   l_return_status := 'S';

 --Copy in to local variables
   l_called_from         := p_called_from;

 --Fetch the case folder
   IF p_case_folder_id IS NOT NULL THEN
    BEGIN
      SELECT *
      INTO case_folders_rec
      FROM ar_cmgt_case_folders
      WHERE case_folder_id = p_case_folder_id;
    EXCEPTION
      WHEN others THEN
        l_return_status := 'F';
    END;
   END IF;

   IF l_return_status = 'S' THEN
      ar_cmgt_data_points_pkg.gather_data_points(
            p_party_id              => case_folders_rec.party_id,
            p_cust_account_id       => case_folders_rec.cust_account_id,
            p_cust_acct_site_id     => case_folders_rec.site_use_id,
            p_trx_currency          => case_folders_rec.limit_currency,
            p_org_id                => NULL,
            p_check_list_id         => case_folders_rec.check_list_id,
            p_credit_request_id     => case_folders_rec.credit_request_id,
            p_score_model_id        => case_folders_rec.score_model_id,
            p_credit_classification => case_folders_rec.credit_classification,
            p_review_type           => case_folders_rec.review_type,
            p_case_folder_number    => NULL,
	    p_mode 		    => 'REFRESH',
            p_limit_currency        => l_limit_currency,
            p_case_folder_id        => case_folders_rec.case_folder_id,
            p_error_msg             => l_error_msg,
            p_resultout             => l_resultout);

     --Non standard messages are returned.0 Success,1-Error,2-Warning
     IF l_resultout = 1 THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('refresh_case_folder: ' || 'Call to ar_cmgt_data_points_pkg.gather_data_points failed');
        END IF;
        FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
        FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','ar_cmgt_refresh_conc.refresh_case_folder : '||SQLERRM);
        FND_MSG_PUB.Add;
        app_exception.raise_exception;
     END IF;
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('ar_cmgt_refresh_conc.refresh_case_folder (-)');
   END IF;

END refresh_case_folder;

END AR_CMGT_REFRESH_CONC;

/
