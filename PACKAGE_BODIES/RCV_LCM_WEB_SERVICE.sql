--------------------------------------------------------
--  DDL for Package Body RCV_LCM_WEB_SERVICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_LCM_WEB_SERVICE" AS
/* $Header: RCVLCMWB.pls 120.0.12010000.6 2013/12/31 07:21:24 zhlee noship $ */

   PROCEDURE Get_Landed_Cost (p_group_id IN NUMBER,p_processing_mode IN VARCHAR2) AS
      --

      x_progress             varchar2(5) := '00000';

      p_rti_rec              rti_cur_table;
      --Bug 18017375
      p_rti_opm_rec          rti_opm_cur_table;
      --Bug 18017375
      g_user_id              NUMBER        := FND_PROFILE.value('USER_ID');
      g_resp_id              NUMBER        := FND_PROFILE.value('RESP_ID');
      g_pgm_appl_id          NUMBER        := FND_PROFILE.value('RESP_APPL_ID');
      --
   BEGIN
      --
      asn_debug.put_line('Entering RCV_LCM_WEB_SERVICE.Get_Landed_Cost' || to_char(sysdate,'DD-MON-YYYY HH:MI:SS'));
      asn_debug.put_line('p_group_id        : ' || p_group_id);
      asn_debug.put_line('p_processing_mode : ' || p_processing_mode);
      asn_debug.put_line('g_user_id : ' || g_user_id);
      asn_debug.put_line('g_resp_id : ' || g_resp_id);
      asn_debug.put_line('g_pgm_appl_id : ' || g_pgm_appl_id);
      --

      OPEN rti_cur(p_group_id,p_processing_mode);
      FETCH rti_cur BULK COLLECT into p_rti_rec;


      IF p_rti_rec.first IS NOT NULL THEN

         asn_debug.put_line('calling LCM API to get the landed cost (non OPM)' || p_rti_rec.COUNT);

         INL_INTEGRATION_GRP.Get_LandedCost(p_rti_rec,p_group_id,p_processing_mode);

         asn_debug.put_line('after calling LCM API to get the landed cost (non OPM)' || p_rti_rec.COUNT);

      END IF;

      IF rti_cur%ISOPEN THEN
         CLOSE rti_cur;
      END IF;


      --Bug 18017375

      OPEN rti_opm_cur(p_group_id,p_processing_mode);
      FETCH rti_opm_cur BULK COLLECT into p_rti_opm_rec;

      IF p_rti_opm_rec.first IS NOT NULL THEN

         asn_debug.put_line('calling LCM API to get the landed cost (OPM)' || p_rti_opm_rec.COUNT);

         --Calling overloaded version of Get_LandedCost with opm table
         INL_INTEGRATION_GRP.Get_LandedCost(p_rti_opm_rec,p_group_id,p_processing_mode);

	       asn_debug.put_line('after calling LCM API to get the landed cost (OPM)' || p_rti_opm_rec.COUNT);

      END IF;

      IF rti_opm_cur%ISOPEN THEN
         CLOSE rti_opm_cur;
      END IF;
      --Bug 18017375

   EXCEPTION
      WHEN OTHERS THEN
         asn_debug.put_line('the error is:  ' || sqlcode ||' '||substr(SQLERRM, 1, 1000));

         IF rti_cur%ISOPEN THEN
            CLOSE rti_cur;
         END IF;

         --Bug 18017375
         IF rti_opm_cur%ISOPEN THEN
            CLOSE rti_opm_cur;
         END IF;
         --Bug 18017375

         UPDATE rcv_transactions_interface
         SET    processing_status_code  = 'ERROR'
         WHERE  processing_status_code  = 'RUNNING'
         AND    transaction_status_code = 'PENDING'
         AND    mo_global.check_access(org_id) = 'Y'
         AND    processing_mode_code = p_processing_mode
         AND    group_id = nvl(p_group_id, group_id)
         AND    source_document_code = 'PO'
         AND    transaction_type NOT IN ('SHIP', 'RECEIVE', 'ACCEPT', 'REJECT','TRANSFER','UNORDERED')
         AND    lcm_shipment_line_id IS NOT NULL;

         asn_debug.put_line(sql%rowcount || ' RTIs updated to Error' );

   END Get_Landed_Cost;


END RCV_LCM_WEB_SERVICE;

/
