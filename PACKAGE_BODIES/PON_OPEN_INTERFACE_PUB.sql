--------------------------------------------------------
--  DDL for Package Body PON_OPEN_INTERFACE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_OPEN_INTERFACE_PUB" as
/* $Header: PON_OPEN_INTERFACE_PUB.plb 120.1.12010000.2 2013/08/15 12:34:15 irasoolm noship $ */

PROCEDURE create_negotiations(
                              EFFBUF           OUT NOCOPY VARCHAR2,
                              RETCODE          OUT NOCOPY VARCHAR2,
                              p_group_batch_id  IN NUMBER
                              )
AS
neg_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
dummy1 VARCHAR2(1);
l_msg VARCHAR2 (2000);
BEGIN
	print_log('create_negotiations');
	print_log('Parameters');
-- Standard Start of API savepoint
   --SAVEPOINT  create_negotiation_save_point;

   FND_MSG_PUB.initialize;

    BEGIN
        SELECT 1
        INTO dummy1
        FROM pon_auction_headers_Interface WHERE  interface_group_id = p_group_batch_id
        AND PROCESSING_STATUS_CODE = 'PENDING'
        AND ROWNUM < 2;
    EXCEPTION
    WHEN No_Data_Found THEN
        print_Log('No row found in pon_auction_headers_Interface table for the given group_batch_id' );
        FND_MESSAGE.SET_NAME('PON','PON_IMPORT_INV_GRPBATCHID');
        FND_MSG_PUB.ADD;
        RETCODE := '2';
        RETURN;
    END;

    BEGIN
      pon_open_interface_pvt.create_negotiations(
                                                p_group_batch_id,
					                                      neg_return_status,
                                                l_msg_count,
                                                l_msg_data);
    EXCEPTION
    WHEN OTHERS THEN
      print_log('Exception in create_negotiations');
      neg_return_status := 'E';
    END;

    IF (neg_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      RETCODE := '2';
      FOR i IN 1..FND_MSG_PUB.COUNT_MSG LOOP
        l_msg := FND_MSG_PUB.get
                  ( p_msg_index => i,
                    p_encoded => FND_API.G_FALSE
                  );

        FND_FILE.put_line(FND_FILE.LOG, l_msg);
      END LOOP;
    ELSE
      RETCODE := '0';
    END IF;

END create_negotiations;

-----------------------------------------------------------------------
--Start of Comments
--Name:  print_log
--Description  : Helper procedure for logging
--Pre-reqs:
--Parameters:
--IN:  p_message
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE print_log
  (
    p_message IN VARCHAR2 )
IS

BEGIN
  IF(g_fnd_debug                = 'Y') THEN
    IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string(log_level  => FND_LOG.level_statement, module => g_module_prefix, MESSAGE => p_message);
    END IF;
  END IF;
END print_log;

END PON_OPEN_INTERFACE_PUB;

/
