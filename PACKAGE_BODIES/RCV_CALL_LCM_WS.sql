--------------------------------------------------------
--  DDL for Package Body RCV_CALL_LCM_WS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_CALL_LCM_WS" AS
/* $Header: RCVLCMIB.pls 120.0.12010000.10 2010/02/25 13:48:53 acferrei noship $ */

PROCEDURE insertLCM( x_errbuf          	OUT NOCOPY VARCHAR2
                    ,x_retcode           OUT NOCOPY NUMBER) IS

cursor c_rsh_rti is
select *
from rcv_transactions_interface rti
where transaction_status_code = 'PENDING'
and   processing_status_code = 'LC_PENDING'
and   (transaction_type in ('RECEIVE', 'MATCH') or -- Bug 9109629
       (transaction_type ='SHIP' and auto_transact_code  in ('RECEIVE','DELIVER'))
      )
and   source_document_code = 'PO'
and exists ( select 'lcm shipment'
             from po_line_locations_all pll
	     where pll.line_location_id = rti.po_line_location_id
	     and pll.lcm_flag = 'Y'
	    )
and shipment_header_id IS NOT NULL
order by shipment_header_id,
         ship_to_location_id,  -- Bug #9211099
         interface_transaction_id;



cursor c_rhi_rti is
select *
from rcv_transactions_interface rti
where transaction_status_code = 'PENDING'
and   processing_status_code = 'LC_PENDING'
and   (transaction_type in ('RECEIVE', 'MATCH') or -- Bug 9109629
       (transaction_type ='SHIP' and auto_transact_code  in ('RECEIVE','DELIVER'))
      )
and   source_document_code = 'PO'
and exists ( select 'lcm shipment'
             from po_line_locations_all pll
	     where pll.line_location_id = rti.po_line_location_id
	     and pll.lcm_flag = 'Y'
	    )
and shipment_header_id IS NULL
and header_interface_id IS NOT NULL
order by header_interface_id,
         ship_to_location_id,  -- Bug #9211099
         interface_transaction_id;


l_ret             BOOLEAN;
p_rti_rec         rti_rec;
l_return_status   VARCHAR2(1);
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(2000);

BEGIN

  asn_debug.put_line('Entering RCV_CALL_LCM_WS.insertLCM' || to_char(sysdate,'DD-MON-YYYY HH:MI:SS'));

  -- Bug 9411154
  l_ret := fnd_concurrent.set_completion_status('NORMAL', 'Success');

  x_retcode  := 0;
  x_errbuf   := 'Success';
  -- /Bug 9411154

  open c_rsh_rti;
  fetch c_rsh_rti BULK COLLECT INTO p_rti_rec;

  asn_debug.put_line('No of rows from RSH to be inserted: ' || p_rti_rec.COUNT);


  IF p_rti_rec.first IS NOT NULL THEN

     asn_debug.put_line('calling LCM API for RSH');

     INL_INTEGRATION_GRP.Import_FromRCV(p_rti_rec,
                                        l_return_status,
                                        l_msg_count,
                                        l_msg_data );

     asn_debug.put_line('after calling LCM API for RSH: ' || p_rti_rec.COUNT);

     -- Setting error bufer and return code
     IF l_msg_count = 1 THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, l_msg_data);
          x_retcode := 1;
          -- Bug 9411154
          l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING', 'Warning');
          x_errbuf := 'Warnings found.'||FND_GLOBAL.local_chr (10) ;
          -- /Bug 9411154
     ELSIF l_msg_count > 1 THEN
          FOR i IN 1 ..l_msg_count
          LOOP
              FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.get (i, FND_API.g_false) );
          END LOOP;
          x_retcode := 1;
          -- Bug 9411154
          l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING', 'Warning');
          x_errbuf := 'Warnings found.'||FND_GLOBAL.local_chr (10) ;
          -- /Bug 9411154
     END IF;

     -- If any errors happen abort the process.
     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
  END IF;

  asn_debug.put_line('before closing the RSH cursor');

  IF c_rsh_rti%ISOPEN THEN
     CLOSE c_rsh_rti;
  END IF;

  p_rti_rec.delete;

  open c_rhi_rti;

  asn_debug.put_line('fetching the RHI cursor');

  fetch c_rhi_rti BULK COLLECT INTO p_rti_rec;


  asn_debug.put_line('No of rows from RHI to be inserted: ' || p_rti_rec.COUNT);

  IF p_rti_rec.first IS NOT NULL THEN

     asn_debug.put_line('calling LCM API for RHI' || p_rti_rec.COUNT);

     INL_INTEGRATION_GRP.Import_FromRCV(p_rti_rec,
                                        l_return_status,
                                        l_msg_count,
                                        l_msg_data);

     asn_debug.put_line(' after calling LCM API for RHI' || p_rti_rec.COUNT);

     -- Setting error bufer and return code
     IF l_msg_count = 1 THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, l_msg_data);
          x_retcode := 1;
          -- Bug 9411154
          l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING', 'Warning');
          x_errbuf := 'Warnings found.'||FND_GLOBAL.local_chr (10) ;
          -- /Bug 9411154
     ELSIF l_msg_count > 1 THEN
          FOR i IN 1 ..l_msg_count
          LOOP
              FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.get (i, FND_API.g_false) );
          END LOOP;
          x_retcode := 1;
          -- Bug 9411154
          l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING', 'Warning');
          x_errbuf := 'Warnings found.'||FND_GLOBAL.local_chr (10) ;
          -- /Bug 9411154
     END IF;

     -- If any errors happen abort the process.
     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
  END IF;

  asn_debug.put_line('before closing the RHI cursor');
  IF c_rhi_rti%ISOPEN THEN
     CLOSE c_rhi_rti;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF c_rsh_rti%ISOPEN THEN
         CLOSE c_rsh_rti;
      END IF;
      IF c_rhi_rti%ISOPEN THEN
         CLOSE c_rhi_rti;
      END IF;
      asn_debug.put_line('the error is:  ' || sqlcode ||' '||substr(SQLERRM, 1, 1000));
      x_retcode := 1;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF c_rsh_rti%ISOPEN THEN
         CLOSE c_rsh_rti;
      END IF;
      IF c_rhi_rti%ISOPEN THEN
         CLOSE c_rhi_rti;
      END IF;
      asn_debug.put_line('the error is:  ' || sqlcode ||' '||substr(SQLERRM, 1, 1000));
      x_retcode := 2;
    WHEN OTHERS THEN
      IF c_rsh_rti%ISOPEN THEN
         CLOSE c_rsh_rti;
      END IF;
      IF c_rhi_rti%ISOPEN THEN
         CLOSE c_rhi_rti;
      END IF;
      asn_debug.put_line('the error is:  ' || sqlcode ||' '||substr(SQLERRM, 1, 1000));
      l_ret := fnd_concurrent.set_completion_status('ERROR', 'Error');
      x_retcode  := 2;
      x_errbuf   := 'Error';
END insertLCM;

END RCV_CALL_LCM_WS;

/
