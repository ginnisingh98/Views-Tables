--------------------------------------------------------
--  DDL for Package Body OKL_PURGE_STRM_INTF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PURGE_STRM_INTF_PVT" AS
/* $Header: OKLRPSIB.pls 120.2.12010000.3 2009/06/03 04:21:12 racheruv ship $ */
PROCEDURE PURGE_INTERFACE_TABLES(
   x_errbuf OUT NOCOPY VARCHAR2
  ,x_retcode OUT NOCOPY NUMBER
  ,p_end_date IN VARCHAR2) IS

  l_end_date DATE := null;
  l_sif_id NUMBER;
  l_sir_id NUMBER;
  l_api_name CONSTANT VARCHAR2(40) := 'PURGE_INTERFACE_TABLES';
  l_api_version CONSTANT NUMBER := 1.0;
  lp_api_version CONSTANT NUMBER := 1.0;
  l_init_msg_list VARCHAR2(1) := 'F';
  l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  lx_return_status VARCHAR2(1);
  lx_msg_count NUMBER;
  lx_msg_data VARCHAR2(2000);

  lp_sifv_rec sifv_rec_type;
  lp_sitv_rec sitv_rec_type;
  lp_sfev_rec sfev_rec_type;
  lp_silv_rec silv_rec_type;
  lp_sxpv_rec sxpv_rec_type;
  lp_siyv_rec siyv_rec_type;
  lp_sirv_rec sirv_rec_type;
  lp_srsv_rec srsv_rec_type;
  lp_srlv_rec srlv_rec_type;
  lp_srmv_rec srmv_rec_type;

  lx_sifv_rec sifv_rec_type;
  lx_sitv_rec sitv_rec_type;
  lx_sfev_rec sfev_rec_type;
  lx_silv_rec silv_rec_type;
  lx_sxpv_rec sxpv_rec_type;
  lx_siyv_rec siyv_rec_type;
  lx_sirv_rec sirv_rec_type;
  lx_srsv_rec srsv_rec_type;
  lx_srlv_rec srlv_rec_type;
  lx_srmv_rec srmv_rec_type;

  l_error_msg_rec error_message_type;
BEGIN
  --EXECUTE IMMEDIATE ('ALTER SESSION FORCE PARALLEL QUERY'); -- commented out for test patch 5560534
  -- EXECUTE IMMEDIATE ('ALTER SESSION ENABLE PARALLEL DML');  -- commented out for test patch 5560534

  x_retcode := 0;
  FND_FILE.Put_Line(FND_FILE.LOG,'Lease and Finance Management: Streams Interface Tables purge concurrent program');
  --l_end_date := TO_DATE(p_end_date,'YYYY/MM/DD HH:MI:SS');
  l_end_date := fnd_date.canonical_to_date(p_end_date);
  FND_FILE.Put_Line(FND_FILE.LOG, 'Deleting records with creation date less then '||l_end_date);

  FND_FILE.Put_Line(FND_FILE.LOG,'Deleting records from OKL_SIF_FEES');

  DELETE FROM OKL_SIF_FEES
  WHERE sif_id IN (SELECT id FROM okl_stream_interfaces
                   WHERE creation_date < l_end_date
                   AND sis_code NOT IN ('DATA_ENTERED', 'HDR_INSERTED',
                           'PROCESSING_REQUEST', 'RET_DATA_RECEIVED'));
  commit;
  FND_FILE.Put_Line(FND_FILE.LOG,'Deleting records from OKL_SIF_LINES');

  DELETE FROM OKL_SIF_LINES
  WHERE sif_id IN (SELECT id FROM okl_stream_interfaces
                   WHERE creation_date < l_end_date
                   AND sis_code NOT IN ('DATA_ENTERED', 'HDR_INSERTED',
                           'PROCESSING_REQUEST', 'RET_DATA_RECEIVED'));
  commit;

  FND_FILE.Put_Line(FND_FILE.LOG,'Deleting records from OKL_SIF_STREAM_TYPES');


  DELETE FROM OKL_SIF_STREAM_TYPES
  WHERE sif_id IN (SELECT id FROM okl_stream_interfaces
                   WHERE creation_date < l_end_date
                   AND sis_code NOT IN ('DATA_ENTERED', 'HDR_INSERTED',
                           'PROCESSING_REQUEST', 'RET_DATA_RECEIVED'));
  commit;

  FND_FILE.Put_Line(FND_FILE.LOG,'Deleting records from OKL_SIF_YIELDS');

  DELETE FROM OKL_SIF_YIELDS
  WHERE sif_id IN (SELECT id FROM okl_stream_interfaces
                   WHERE creation_date < l_end_date
                   AND sis_code NOT IN ('DATA_ENTERED', 'HDR_INSERTED',
                           'PROCESSING_REQUEST', 'RET_DATA_RECEIVED'));
 commit;

  FND_FILE.Put_Line(FND_FILE.LOG,'Deleting records from OKL_SIF_PRICING_PARAMS');

  DELETE FROM OKL_SIF_PRICING_PARAMS
  WHERE sif_id IN (SELECT id FROM okl_stream_interfaces
                   WHERE creation_date < l_end_date
                   AND sis_code NOT IN ('DATA_ENTERED', 'HDR_INSERTED',
                           'PROCESSING_REQUEST', 'RET_DATA_RECEIVED'));
 commit;

  FND_FILE.Put_Line(FND_FILE.LOG,'Deleting records from OKL_SIF_TRX_PARMS');

  DELETE FROM OKL_SIF_TRX_PARMS
  WHERE sif_id IN (SELECT id FROM okl_stream_interfaces
                   WHERE creation_date < l_end_date
                   AND sis_code NOT IN ('DATA_ENTERED', 'HDR_INSERTED',
                           'PROCESSING_REQUEST', 'RET_DATA_RECEIVED'));
 commit;

  FND_FILE.Put_Line(FND_FILE.LOG,'Deleting records from OKL_SIF_RET_LEVELS');


  DELETE FROM OKL_SIF_RET_LEVELS
  WHERE sir_id IN (SELECT rets.id from OKL_SIF_RETS rets, okl_stream_interfaces str
            WHERE  rets.transaction_number = str.transaction_number
             and str.creation_date < l_end_date
                                    AND str.sis_code NOT IN ('DATA_ENTERED', 'HDR_INSERTED',
                                   'PROCESSING_REQUEST', 'RET_DATA_RECEIVED'));
 commit;

  FND_FILE.Put_Line(FND_FILE.LOG,'Deleting records from OKL_SIF_RET_ERRORS');

  DELETE FROM OKL_SIF_RET_ERRORS
  WHERE sir_id IN (SELECT rets.id from OKL_SIF_RETS rets, okl_stream_interfaces str
            WHERE  rets.transaction_number = str.transaction_number
             and str.creation_date < l_end_date
                                    AND str.sis_code NOT IN ('DATA_ENTERED', 'HDR_INSERTED',
                                   'PROCESSING_REQUEST', 'RET_DATA_RECEIVED'));
 commit;

  FND_FILE.Put_Line(FND_FILE.LOG,'Deleting records from OKL_SIF_RET_STRMS');


  DELETE FROM OKL_SIF_RET_STRMS
  WHERE sir_id IN (SELECT rets.id from OKL_SIF_RETS rets, okl_stream_interfaces str
            WHERE  rets.transaction_number = str.transaction_number
             and str.creation_date < l_end_date
                                    AND str.sis_code NOT IN ('DATA_ENTERED', 'HDR_INSERTED',
                                   'PROCESSING_REQUEST', 'RET_DATA_RECEIVED'));
 commit;

  --Added by bkatraga
  FND_FILE.Put_Line(FND_FILE.LOG,'Deleting records from okl_stream_trx_data');

  DELETE FROM okl_stream_trx_data
  WHERE transaction_number IN (SELECT transaction_number FROM okl_stream_interfaces
                   WHERE creation_date < l_end_date
                   AND sis_code NOT IN ('DATA_ENTERED', 'HDR_INSERTED',
                           'PROCESSING_REQUEST', 'RET_DATA_RECEIVED'));

  commit;
  --end bkatraga

  FND_FILE.Put_Line(FND_FILE.LOG,'Deleting records from OKL_SIF_RETS');

  DELETE FROM OKL_SIF_RETS
  WHERE transaction_number IN (SELECT transaction_number FROM okl_stream_interfaces
                   WHERE creation_date < l_end_date
                   AND sis_code NOT IN ('DATA_ENTERED', 'HDR_INSERTED',
                           'PROCESSING_REQUEST', 'RET_DATA_RECEIVED'));
 commit;

  FND_FILE.Put_Line(FND_FILE.LOG,'Deleting records from OKL_STREAM_INTERFACES');

  DELETE FROM OKL_STREAM_INTERFACES
  WHERE creation_date < l_end_date
  AND sis_code NOT IN ('DATA_ENTERED', 'HDR_INSERTED',
  'PROCESSING_REQUEST', 'RET_DATA_RECEIVED');

 commit;

  FND_FILE.Put_Line(FND_FILE.LOG, '');
  FND_FILE.Put_Line(FND_FILE.LOG,'End of Message Purge Concurrent Program');
  x_retcode := 0;
  x_errbuf := 'Successful';
  --commit;
  EXCEPTION
    WHEN OTHERS THEN
	ROLLBACK;
       x_errbuf := SQLERRM;
       x_retcode := 2;
END PURGE_INTERFACE_TABLES;
END OKL_PURGE_STRM_INTF_PVT;

/
