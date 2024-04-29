--------------------------------------------------------
--  DDL for Package Body OKL_AM_PROCESS_ASSET_TRX_WRAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_PROCESS_ASSET_TRX_WRAP" AS
/* $Header: OKLBAMAB.pls 115.4 2002/12/18 12:07:08 kjinger noship $ */

  -- Start of comments
--
-- Procedure Name  : process_transactions_wrap
-- Description     : This procedure calls process_transactions procedure of OKL_AM_PROCESS_ASSET_TRX_PUB API
-- Business Rules  :
-- Parameters      :  p_contract_id                  - contract id
--                    p_asset_id                     - asset_id
--                    p_kle_id                       - line id
--                    p_salvage_writedown_yn         - flag indicating whether to process salvage valye transactions
--
-- Version         : 1.0
-- End of comments

  PROCEDURE process_transactions_wrap(   ERRBUF                  OUT NOCOPY 	VARCHAR2,
                                         RETCODE                 OUT NOCOPY    VARCHAR2 ,
                                         p_api_version           IN  	NUMBER,
           		 	                     p_init_msg_list         IN  	VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                         p_contract_id           IN     NUMBER DEFAULT NULL,
                                         p_asset_id              IN     NUMBER DEFAULT NULL,
                                         p_kle_id                IN     VARCHAR2 DEFAULT NULL,
                                         p_salvage_writedown_yn  IN     VARCHAR2 DEFAULT 'N'
           			            )    IS


   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);
   l_transaction_status  VARCHAR2(1);
   l_mesg                VARCHAR2(4000);
   l_mesg_len            NUMBER;
   l_api_name            CONSTANT VARCHAR2(30) := 'process_transactions_wrap';
   l_total_count         NUMBER;
   l_processed_count     NUMBER;
   l_error_count         NUMBER;

   BEGIN

                         OKL_AM_PROCESS_ASSET_TRX_PUB.process_transactions(
                                p_api_version           => p_api_version,
           			            p_init_msg_list         => p_init_msg_list ,
           			            x_return_status         => l_return_status,
           			            x_msg_count             => l_msg_count,
           			            x_msg_data              => l_msg_data,
				                p_contract_id    	    => p_contract_id ,
                                p_asset_id              => p_asset_id,
                                p_kle_id                => TO_NUMBER(p_kle_id),
                                p_salvage_writedown_yn  => p_salvage_writedown_yn,
                                x_total_count           => l_total_count,
                                x_processed_count       => l_processed_count,
                                x_error_count           => l_error_count);

                        l_msg_count := fnd_msg_pub.count_msg;
                        IF l_msg_count > 0 THEN

                            l_mesg :=  substr(fnd_msg_pub.get(fnd_msg_pub.G_FIRST, fnd_api.G_FALSE), 1, 512);

                            FOR i IN 1..(l_msg_count - 1) LOOP
                                l_mesg := l_mesg || ' ' ||
                                substr(fnd_msg_pub.get(fnd_msg_pub.G_NEXT,fnd_api.G_FALSE), 1, 512);
                            END LOOP;

                            fnd_msg_pub.delete_msg();

                            l_mesg_len := length(l_mesg);
                            fnd_file.put_line(fnd_file.log, 'Error: ');
                            fnd_file.put_line(fnd_file.output, 'Error: ');

                            FOR i IN 1..ceil(l_mesg_len/255) LOOP
                                fnd_file.put_line(fnd_file.log, l_mesg);
                                fnd_file.put_line(fnd_file.output, l_mesg);
                            END LOOP;

                            fnd_file.new_line(fnd_file.log,2);
                            fnd_file.new_line(fnd_file.output,2);
                        END IF;

                        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                           fnd_file.put_line(fnd_file.log, 'FA ADJUSTMENTS Failed, None of the transactions got processed');
                           fnd_file.put_line(fnd_file.output, 'FA ADJUSTMENTS Failed, None of the transactions got processed');
                        END IF;

                        IF l_return_status = OKC_API.G_RET_STS_SUCCESS AND
                           l_transaction_status <> OKC_API.G_RET_STS_SUCCESS THEN
                              fnd_file.put_line(fnd_file.log, 'One or more transactions failed');
                              fnd_file.put_line(fnd_file.output, 'One or more transactions failed');
                        END IF;

                        IF l_return_status = OKC_API.G_RET_STS_SUCCESS AND
                           l_transaction_status = OKC_API.G_RET_STS_SUCCESS THEN
                              fnd_file.put_line(fnd_file.log, 'All the transactions got processed successfully');
                              fnd_file.put_line(fnd_file.output, 'All the transactions got processed successfully');
                        END IF;


fnd_file.put_line(fnd_file.log,'KHR ID '||TO_CHAR(P_CONTRACT_ID));
fnd_file.put_line(fnd_file.log,'KLE_ID '||P_KLE_ID);
fnd_file.put_line(fnd_file.log,'msg data '||l_msg_data);
fnd_file.put_line(fnd_file.log,'return status '||l_return_status);
fnd_file.put_line(fnd_file.log,'transaction status  '||l_transaction_status);

   END;

END;

/
