--------------------------------------------------------
--  DDL for Package INL_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INL_INTERFACE_PVT" AUTHID CURRENT_USER AS
/* $Header: INLVINTS.pls 120.7.12010000.23 2013/09/06 18:29:47 acferrei ship $ */

    G_MODULE_NAME  CONSTANT VARCHAR2(200) := 'INL.PLSQL.INL_INTERFACE_PVT.';
    G_PKG_NAME     CONSTANT VARCHAR2(30)  := 'INL_INTERFACE_PVT';
    G_RECORDS_PROCESSED NUMBER := 0;
    G_RECORDS_INSERTED NUMBER := 0;
    G_RECORDS_COMPLETED NUMBER := 0; -- Bug 16310024
    L_FND_FALSE                 CONSTANT VARCHAR2(1)   := fnd_api.g_false;              --Bug#9660043
    L_FND_TRUE                  CONSTANT VARCHAR2(1)   := fnd_api.g_true;               --Bug#9660043
    L_FND_VALID_LEVEL_FULL      CONSTANT NUMBER        := fnd_api.g_valid_level_full;   --Bug#9660043
    L_FND_MISS_NUM              CONSTANT NUMBER        := fnd_api.g_miss_num;           --Bug#9660043
    L_FND_MISS_CHAR             CONSTANT VARCHAR2(1)   := fnd_api.g_miss_char;          --Bug#9660043

    TYPE match_int_type IS RECORD (
        match_int_id                 NUMBER,
        group_id                     NUMBER,
        processing_status_code       VARCHAR2(25),
        transaction_type             VARCHAR2(25),
        match_type_code              VARCHAR2(30),
        ship_header_id               NUMBER,
        from_parent_table_name       VARCHAR2(30),
        from_parent_table_id         NUMBER,
        to_parent_table_name         VARCHAR2(30),
        to_parent_table_id           NUMBER,
        parent_match_id              NUMBER,
        matched_qty                  NUMBER,
        matched_uom_code             VARCHAR2(3),
        matched_amt                  NUMBER,
        matched_curr_code            VARCHAR2(15),
        matched_curr_conversion_type VARCHAR2(30),
        matched_curr_conversion_date DATE,
        matched_curr_conversion_rate NUMBER,
        replace_estim_qty_flag       VARCHAR2(1),
        existing_match_info_flag     VARCHAR2(1),
        charge_line_type_id          NUMBER,
        party_id                     NUMBER,
        party_number                 VARCHAR2(30),
        party_site_id                NUMBER,
        party_site_number            VARCHAR2(30),
        tax_code                     VARCHAR2(30),
        nrec_tax_amt                 NUMBER,
        tax_amt_included_flag        VARCHAR2(1),
        match_amounts_flag           VARCHAR2(1),   --BUG#8264388
        match_id                     NUMBER
    );

    TYPE match_int_list_type IS TABLE OF match_int_type INDEX BY BINARY_INTEGER;

    PROCEDURE Import_LCMShipments(
        p_api_version   IN NUMBER,
        p_init_msg_list IN VARCHAR2 := L_FND_FALSE,
        p_commit        IN VARCHAR2 := L_FND_FALSE,
        p_group_id      IN NUMBER,
        p_simulation_id IN NUMBER DEFAULT NULL,
        --   p_org_id        IN NUMBER,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count     OUT NOCOPY NUMBER,
        x_msg_data      OUT NOCOPY VARCHAR2
    );

    PROCEDURE Import_LCMShipments (
        errbuf     OUT NOCOPY VARCHAR2,
        retcode    OUT NOCOPY VARCHAR2,
        p_group_id IN NUMBER
        --     p_org_id   IN NUMBER
    );

    PROCEDURE Import_LCMMatches(
        p_api_version    IN NUMBER,
        p_init_msg_list  IN VARCHAR2 := L_FND_FALSE,
        p_commit         IN VARCHAR2 := L_FND_FALSE,
        p_group_id       IN NUMBER,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count     OUT NOCOPY NUMBER,
        x_msg_data      OUT NOCOPY VARCHAR2
    );

    PROCEDURE Import_LCMMatches (
        errbuf      OUT NOCOPY VARCHAR2,
        retcode     OUT NOCOPY VARCHAR2,
        p_group_id  IN NUMBER
    );

    PROCEDURE Delete_Ship (
        p_ship_header_id IN NUMBER,
        x_return_status OUT NOCOPY VARCHAR2);
-- SCM-051
    PROCEDURE Reset_MatchInt(p_ship_header_id IN NUMBER,
                             x_return_status OUT NOCOPY VARCHAR2);

-- /SCM-051
END INL_INTERFACE_PVT;

/
