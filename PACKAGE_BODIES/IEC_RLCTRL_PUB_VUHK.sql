--------------------------------------------------------
--  DDL for Package Body IEC_RLCTRL_PUB_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_RLCTRL_PUB_VUHK" AS
/* $Header: IECRCPKB.pls 115.6 2003/08/22 20:42:18 hhuang noship $ */


PROCEDURE MakeListEntriesAvailable_pre ( p_list_header_id      IN            NUMBER
                                       , p_dnu_reason_code     IN            NUMBER
                                       , x_data                IN OUT NOCOPY VARCHAR2
                                       , x_count               IN OUT NOCOPY NUMBER
                                       , x_return_code         IN OUT NOCOPY VARCHAR2)
IS
BEGIN
   NULL;
END MakeListEntriesAvailable_pre;


PROCEDURE MakeListEntriesAvailable_post ( p_list_header_id      IN            NUMBER
                                        , p_dnu_reason_code     IN            NUMBER
                                        , x_data                IN OUT NOCOPY VARCHAR2
                                        , x_count               IN OUT NOCOPY NUMBER
                                        , x_return_code         IN OUT NOCOPY VARCHAR2)
IS
BEGIN
   NULL;
END MakeListEntriesAvailable_post;


PROCEDURE MakeListEntriesAvailable_pre ( p_list_header_id      IN            NUMBER
                                       , x_data                IN OUT NOCOPY VARCHAR2
                                       , x_count               IN OUT NOCOPY NUMBER
                                       , x_return_code         IN OUT NOCOPY VARCHAR2)
IS
BEGIN
   NULL;
END MakeListEntriesAvailable_pre;


PROCEDURE MakeListEntriesAvailable_post ( p_list_header_id      IN            NUMBER
                                        , x_data                IN OUT NOCOPY VARCHAR2
                                        , x_count               IN OUT NOCOPY NUMBER
                                        , x_return_code         IN OUT NOCOPY VARCHAR2)
IS
BEGIN
   NULL;
END MakeListEntriesAvailable_post;

END IEC_RLCTRL_PUB_VUHK;

/
