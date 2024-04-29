--------------------------------------------------------
--  DDL for Package Body IGI_STP_NET_DOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_STP_NET_DOC_PKG" as
-- $Header: igistpbb.pls 120.4.12000000.3 2007/09/25 08:49:05 gkumares ship $



PROCEDURE Available_Docs(x_type          VARCHAR2,
                         x_param         VARCHAR2,
    	                 x_ap_trx_min    VARCHAR2,
			 x_ap_trx_max    VARCHAR2,
    	                 x_ar_trx_min    VARCHAR2,
			 x_ar_trx_max    VARCHAR2,
    	                 --x_ref_min       VARCHAR2,
			 --x_ref_max       VARCHAR2,
                         x_customer_id   number,
                         x_vendor_id     number,
                         x_currency_code VARCHAR2) IS

   x_user_id NUMBER := fnd_global.user_id;
   v_ap_trx_min VARCHAR2(30);
   v_ap_trx_max VARCHAR2(30);
   v_ar_trx_min VARCHAR2(30);
   v_ar_trx_max VARCHAR2(30);
   --v_ref_min VARCHAR2(30);
  -- v_ref_max VARCHAR2(30);

/* If the user has left the reference fields blank we assume they are using min/max, */

CURSOR trx_min (p_stp_id in number, p_application in varchar2) IS
   SELECT min(trx_number)
   from igi_stp_candidates
   where stp_id      = p_stp_id
   and application   = p_application
   and user_id       = x_user_id
   and currency_code = x_currency_code ;

CURSOR trx_max(p_stp_id in number, p_application in varchar2) IS
   SELECT max(trx_number)
   from igi_stp_candidates
   where stp_id      = p_stp_id
   and application   = p_application
   and user_id       = x_user_id
   and currency_code = x_currency_code;

/* CURSOR ref_min IS
   SELECT min(a.reference)
   from igi_stp_candidates a
   where a.stp_id      = x_vendor_id
   and a.application   = 'AP'
   and a.user_id       = x_user_id
   and a.currency_code = x_currency_code
   and a.reference in ( select b.reference from igi_stp_candidates b
                        where b.stp_id  = x_customer_id
                          and b.application = 'AR'
                          and b.user_id = x_user_id
                          and b.currency_code = x_currency_code);

CURSOR ref_max IS
   SELECT max(a.reference)
   from igi_stp_candidates a
   where a.stp_id      = x_vendor_id
   and a.application   = 'AP'
   and a.user_id       = x_user_id
   and a.currency_code = x_currency_code
   and a.reference in ( select b.reference from igi_stp_candidates b
                        where b.stp_id  = x_customer_id
                          and b.application = 'AR'
                          and b.user_id = x_user_id
                          and b.currency_code = x_currency_code);

-- This does the match of Reference

CURSOR matched_ref( p_ref_min in varchar2
                   ,p_ref_max in varchar2
                   ,l_ref_min in varchar2
                   ,l_ref_max in varchar2) IS
   SELECT distinct p.reference
   FROM igi_stp_candidates p
   WHERE p.application = 'AP'
     AND p.user_id       =  x_user_id
     AND p.stp_id        =  x_vendor_id
     AND p.currency_code =  x_currency_code
     AND p.reference     >= nvl(p_ref_min, l_ref_min)
     AND p.reference     <= nvl(p_ref_max, l_ref_max)
     AND p.reference IN (SELECT distinct r.reference
                         FROM igi_stp_candidates r
                         WHERE application = 'AR'
                         AND r.user_id       = x_user_id
                         AND r.stp_id        = x_customer_id
                         AND r.currency_code = x_currency_code
                         AND r.reference     >= nvl(p_ref_min, l_ref_min)
                         AND r.reference     <= nvl(p_ref_max, l_ref_max)); */
x_counter NUMBER := 1;
x_commit_cycle VARCHAR2(10) := fnd_profile.value('IGI_STP_COMMIT_CYCLE');



BEGIN

/* Depending on the Netting Type only certain documents are selected either AP and AR, AP or AR */

   UPDATE igi_stp_candidates
   SET process_flag = 'R'
   WHERE user_id = x_user_id
     and stp_id in (x_customer_id, x_vendor_id)
     and currency_code = x_currency_code;
    --shsaxena for bug 2713715
     --and process_flag <> 'S';
     -- ssemwal for bug 2437020
   --shsaxena for bug 2713715
/*   IF x_type IN ('1','2') THEN

 If we are matching we need to restrict the available document
      IF x_param = 'T' THEN
         OPEN trx_min(x_vendor_id, 'AP');
         FETCH trx_min INTO v_ap_trx_min;
         CLOSE trx_min;

         OPEN trx_max(x_vendor_id, 'AP');
         FETCH trx_max INTO v_ap_trx_max;
         CLOSE trx_max;

         UPDATE igi_stp_candidates
         SET process_flag = 'A'
         WHERE user_id       =  x_user_id
           and stp_id        =  x_vendor_id
           and currency_code =  x_currency_code
           and application   = 'AP'
           and trx_type      = 'STANDARD'
           and trx_number    >= nvl(x_ap_trx_min, v_ap_trx_min)
           and trx_number    <= nvl(x_ap_trx_max, v_ap_trx_max)
           and process_flag = 'R';

         OPEN trx_min(x_customer_id, 'AR');
         FETCH trx_min INTO v_ar_trx_min;
         CLOSE trx_min;

         OPEN trx_max(x_customer_id, 'AR');
         FETCH trx_max INTO v_ar_trx_max;
         CLOSE trx_max;

         UPDATE igi_stp_candidates
         SET process_flag = 'A'
         WHERE user_id       =  x_user_id
           and stp_id        =  x_customer_id
           and currency_code =  x_currency_code
           and application   = 'AR'
           and trx_type      = 'INV'
           and trx_number    >= nvl(x_ar_trx_min, v_ar_trx_min)
           and trx_number    <= nvl(x_ar_trx_max, v_ar_trx_max)
           and process_flag = 'R';
     ELSIF x_param = 'R' THEN
         OPEN ref_min;
         FETCH ref_min INTO v_ref_min;
         CLOSE ref_min;

         OPEN ref_max;
         FETCH ref_max INTO v_ref_max;
         CLOSE ref_max;

         for rec_match in  matched_ref(x_ref_min, x_ref_max,
                                       v_ref_min, v_ref_max) loop
             UPDATE igi_stp_candidates
               SET process_flag = 'A'
-- Bug 1322996
--             SET process_flag = 'S'
--               , package_num  = x_counter
             WHERE user_id       =  x_user_id
               and currency_code =  x_currency_code
               and stp_id in ( x_customer_id, x_vendor_id)
               and trx_type in ('STANDARD', 'INV')
               and reference     =  rec_match.reference
               and process_flag = 'R';
--               x_counter := x_counter + 1;
         end loop;
      END IF;*/
   IF x_type IN ('3','5','6') THEN
       IF x_param = 'T' THEN
          OPEN trx_min(x_vendor_id, 'AP');
          FETCH trx_min INTO v_ap_trx_min;
          CLOSE trx_min;

          OPEN trx_max(x_vendor_id, 'AP');
          FETCH trx_max INTO v_ap_trx_max;
          CLOSE trx_max;

          UPDATE igi_stp_candidates
          SET process_flag = 'A'
          WHERE user_id       =  x_user_id
            and stp_id        =  x_vendor_id
            and currency_code =  x_currency_code
            and application   = 'AP'
            and trx_type      = decode(x_type, 6,'CREDIT', 'STANDARD')
            and trx_number    >= nvl(x_ap_trx_min, v_ap_trx_min)
            and trx_number    <= nvl(x_ap_trx_max, v_ap_trx_max)
            and process_flag = 'R';
       END IF;
    ELSIF x_type = '4' THEN
       IF x_param = 'T' THEN
          OPEN trx_min(x_customer_id, 'AR');
          FETCH trx_min INTO v_ar_trx_min;
          CLOSE trx_min;

          OPEN trx_max(x_customer_id, 'AR');
          FETCH trx_max INTO v_ar_trx_max;
          CLOSE trx_max;

          UPDATE igi_stp_candidates
          SET process_flag    = 'A'
          WHERE user_id       =  x_user_id
            and stp_id        =  x_customer_id
            and currency_code =  x_currency_code
            and application   = 'AR'
            and trx_type      = 'CM'
            and trx_number    >= nvl(x_ar_trx_min, v_ar_trx_min)
            and trx_number    <= nvl(x_ar_trx_max, v_ar_trx_max)
            and process_flag = 'R';
       END IF;
    END IF;
    COMMIT;
END Available_Docs;

PROCEDURE Update_Candidates (x_type        VARCHAR2,
                             x_batch_id    NUMBER,
                             x_package_id  NUMBER,
                             x_org_id      number) is

   x_user_id NUMBER := fnd_global.user_id;
BEGIN



   UPDATE igi_stp_candidates_all
   SET batch_id = x_batch_id
     , netting_trx_type_id = x_type
     , package_id = x_package_id
   WHERE user_id = x_user_id
   AND process_flag = 'S'
   AND batch_id = -1
   AND org_id = x_org_id;
   --shsaxena for bug 2713715
   -- AND rowid = x_row_id;
   -- ssemwal for bug 243702
   --shsaxena for bug 2713715

   COMMIT;

END Update_Candidates;

END IGI_STP_NET_DOC_PKG;

/
