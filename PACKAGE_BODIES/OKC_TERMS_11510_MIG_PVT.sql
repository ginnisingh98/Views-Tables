--------------------------------------------------------
--  DDL for Package Body OKC_TERMS_11510_MIG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TERMS_11510_MIG_PVT" AS
/* $Header: OKCVMIGB.pls 120.0 2005/05/26 09:57:19 appldev noship $ */

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
 Procedure migrate_to_11510(
    p_batch_size      IN NUMBER,
    x_return_status   OUT NOCOPY VARCHAR2,
    x_msg_data        OUT NOCOPY VARCHAR2

    ) IS
BEGIN
NULL;
END migrate_to_11510;




PROCEDURE migrate_to_11510(errbuf              OUT NOCOPY VARCHAR2 ,
                           retcode             OUT NOCOPY NUMBER,
                           p_batch_size        IN NUMBER := 1000
                            ) IS
l_return_status Varchar2(1);
l_msg_data      varchar2(1000);
BEGIN
             okc_util.init_trace;

             migrate_to_11510(p_batch_size    => p_batch_size,
                              x_return_status => l_return_status,
                              x_msg_data      => l_msg_data);

               IF l_return_status <> 'S' THEN
	         RETCODE := 2;
               ELSE
               	 RETCODE:=0;
               END IF;

               ERRBUF:=l_msg_data;
               okc_util.stop_trace;
END migrate_to_11510;

END OKC_TERMS_11510_MIG_PVT;

/
