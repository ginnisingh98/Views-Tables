--------------------------------------------------------
--  DDL for Package IEC_RLCTRL_PUB_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_RLCTRL_PUB_VUHK" AUTHID CURRENT_USER AS
/* $Header: IECRCPKS.pls 115.6 2003/08/22 20:42:20 hhuang noship $ */


--
--      AUTHOR                  DATE            MODIFICATION DESCRIPTION
--      ------                  ----            ------------------------
--      ANGIE ROMERO            24-SEP-2001     INITIAL IMPLEMENTATION
--

PROCEDURE MakeListEntriesAvailable_pre ( p_list_header_id      IN            NUMBER
                                       , p_dnu_reason_code     IN            NUMBER
                                       , x_data                IN OUT NOCOPY VARCHAR2
                                       , x_count               IN OUT NOCOPY NUMBER
                                       , x_return_code         IN OUT NOCOPY VARCHAR2);

--
--      AUTHOR                  DATE            MODIFICATION DESCRIPTION
--      ------                  ----            ------------------------
--      ANGIE ROMERO            24-SEP-2001     INITIAL IMPLEMENTATION
--

PROCEDURE MakeListEntriesAvailable_post ( p_list_header_id      IN            NUMBER
                                        , p_dnu_reason_code     IN            NUMBER
                                        , x_data                IN OUT NOCOPY VARCHAR2
                                        , x_count               IN OUT NOCOPY NUMBER
                                        , x_return_code         IN OUT NOCOPY VARCHAR2);

--
--      AUTHOR                  DATE            MODIFICATION DESCRIPTION
--      ------                  ----            ------------------------
--      ANGIE ROMERO            24-SEP-2001     INITIAL IMPLEMENTATION
--

PROCEDURE MakeListEntriesAvailable_pre ( p_list_header_id      IN            NUMBER
                                       , x_data                IN OUT NOCOPY VARCHAR2
                                       , x_count               IN OUT NOCOPY NUMBER
                                       , x_return_code         IN OUT NOCOPY VARCHAR2);

--
--      AUTHOR                  DATE            MODIFICATION DESCRIPTION
--      ------                  ----            ------------------------
--      ANGIE ROMERO            24-SEP-2001     INITIAL IMPLEMENTATION
--

PROCEDURE MakeListEntriesAvailable_post ( p_list_header_id      IN            NUMBER
                                        , x_data                IN OUT NOCOPY VARCHAR2
                                        , x_count               IN OUT NOCOPY NUMBER
                                        , x_return_code         IN OUT NOCOPY VARCHAR2);

END IEC_RLCTRL_PUB_VUHK;

 

/
