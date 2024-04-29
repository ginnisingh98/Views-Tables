--------------------------------------------------------
--  DDL for Package Body IEC_AORECDNU_PUB_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_AORECDNU_PUB_VUHK" AS
/* $Header: IECRDPKB.pls 115.1 2003/10/24 19:49:35 minwang noship $ */


PROCEDURE SetAORecDNU_pre ( p_list_entry_id      IN            NUMBER
                        			 			   ,p_list_header_id      IN            NUMBER
                                       , p_dnu_reason_code     IN            NUMBER
                                       , x_data                IN OUT NOCOPY VARCHAR2
                                       , x_count               IN OUT NOCOPY NUMBER
                                       , x_return_code         IN OUT NOCOPY VARCHAR2)
IS
BEGIN
   NULL;
END SetAORecDNU_pre;


PROCEDURE SetAORecDNU_post ( p_list_entry_id      IN            NUMBER
						                            ,p_list_header_id      IN            NUMBER
                                        , p_dnu_reason_code     IN            NUMBER
                                        , x_data                IN OUT NOCOPY VARCHAR2
                                        , x_count               IN OUT NOCOPY NUMBER
                                        , x_return_code         IN OUT NOCOPY VARCHAR2)
IS
BEGIN
   NULL;
END SetAORecDNU_post;


END IEC_AORECDNU_PUB_VUHK;

/
