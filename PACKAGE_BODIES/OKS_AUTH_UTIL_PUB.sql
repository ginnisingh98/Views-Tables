--------------------------------------------------------
--  DDL for Package Body OKS_AUTH_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_AUTH_UTIL_PUB" AS
    /* $Header: OKSPAUTB.pls 120.6 2006/06/09 05:20:05 gchadha noship $ */

    PROCEDURE GetSelections_prod(p_api_version         IN  NUMBER
                                 , p_init_msg_list       IN  VARCHAR2
                                 , p_clvl_filter_rec     IN  clvl_filter_rec
                                 , x_return_status       OUT NOCOPY VARCHAR2
                                 , x_msg_count           OUT NOCOPY NUMBER
                                 , x_msg_data            OUT NOCOPY VARCHAR2
                                 , x_prod_selections_tbl OUT NOCOPY  prod_selections_tbl)
    IS
    l_return_status      VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name           CONSTANT VARCHAR2(30) := 'GetSelections_prod';
    BEGIN
        l_return_status := OKC_API.START_ACTIVITY
        (l_api_name
         , p_init_msg_list
         , '_PUB'
         , x_return_status);
        IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        OKS_AUTH_UTIL_PVT.GetSelections_prod
        (p_api_version => p_api_version
         , p_init_msg_list => p_init_msg_list
         , p_clvl_filter_rec => p_clvl_filter_rec
         , x_return_status => l_return_status
         , x_msg_count => x_msg_count
         , x_msg_data => x_msg_data
         , x_prod_selections_tbl => x_prod_selections_tbl);

        IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

        x_return_status := l_return_status;
    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_ERROR',
             x_msg_count,
             x_msg_data,
             '_PUB');
        WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PUB');
        WHEN OTHERS THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PUB');
    END GetSelections_prod;

    PROCEDURE GetSelections_other(p_api_version         IN  NUMBER
                                  , p_init_msg_list       IN  VARCHAR2
                                  , p_clvl_filter_rec     IN  clvl_filter_rec
                                  , x_return_status       OUT NOCOPY VARCHAR2
                                  , x_msg_count           OUT NOCOPY NUMBER
                                  , x_msg_data            OUT NOCOPY VARCHAR2
                                  , x_clvl_selections_tbl OUT NOCOPY clvl_selections_tbl)
    IS
    l_return_status      VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name           CONSTANT VARCHAR2(30) := 'GetSelections_prod';
    BEGIN
        l_return_status := OKC_API.START_ACTIVITY
        (l_api_name
         , p_init_msg_list
         , '_PUB'
         , x_return_status);
        IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        OKS_AUTH_UTIL_PVT.GetSelections_other
        (p_api_version => p_api_version
         , p_init_msg_list => p_init_msg_list
         , p_clvl_filter_rec => p_clvl_filter_rec
         , x_return_status => l_return_status
         , x_msg_count => x_msg_count
         , x_msg_data => x_msg_data
         , x_clvl_selections_tbl => x_clvl_selections_tbl);

        IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

        x_return_status := l_return_status;
    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_ERROR',
             x_msg_count,
             x_msg_data,
             '_PUB');
        WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PUB');
        WHEN OTHERS THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PUB');
    END GetSelections_other;

    PROCEDURE CopyService(p_api_version   IN  NUMBER
                          , p_init_msg_list IN  VARCHAR2
                          , p_source_rec    IN  copy_source_rec
                          , p_target_tbl    IN  copy_target_tbl
                          , x_return_status OUT NOCOPY VARCHAR2
                          , x_msg_count     OUT NOCOPY NUMBER
                          , x_msg_data      OUT NOCOPY VARCHAR2
                          , p_change_status IN VARCHAR2) -- Added an additional flag parameter, p_change_status,
    -- to decide whether to allow change of status of sublines
    -- of the topline during update service
    IS
    l_return_status      VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name           CONSTANT VARCHAR2(30) := 'CopyService';
    BEGIN
        l_return_status := OKC_API.START_ACTIVITY
        (l_api_name
         , p_init_msg_list
         , '_PUB'
         , x_return_status);
        IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        OKS_AUTH_UTIL_PVT.CopyService
        (p_api_version => p_api_version
         , p_init_msg_list => p_init_msg_list
         , p_source_rec => p_source_rec
         , p_target_tbl => p_target_tbl
         , x_return_status => l_return_status
         , x_msg_count => x_msg_count
         , x_msg_data => x_msg_data
         , p_change_status => p_change_status); -- LLC Added an additional flag parameter, p_change_status,
        -- to decide whether to allow change of status of sublines
        -- of the topline during update service

        IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

        x_return_status := l_return_status;

    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_ERROR',
             x_msg_count,
             x_msg_data,
             '_PUB');
        WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PUB');
        WHEN OTHERS THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PUB');
    END CopyService;

    --Added for Bug#2419645, 07/18/2002, Sudam.
    PROCEDURE COPY_PARAMETER(
                             p_api_version         IN NUMBER,
                             p_init_msg_list       IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                             p_in_parameter_record IN in_parameter_record,
                             x_cur_rec             OUT NOCOPY cur_rec,
                             x_hdr_cur_rec         OUT NOCOPY hdr_cur_rec,
                             x_line_cur_rec        OUT NOCOPY line_cur_rec,
                             x_return_status       OUT NOCOPY VARCHAR2,
                             x_msg_count           OUT NOCOPY NUMBER,
                             x_msg_data            OUT NOCOPY VARCHAR2
                             )
    IS
    CURSOR hdr_cur(p_chr_id  IN  NUMBER) IS
        SELECT short_description,
               contract_number,
               contract_number_modifier,
               start_date,
               end_date,
               currency_code
        FROM   OKC_K_HEADERS_V
        WHERE  ID = p_chr_id;

    CURSOR line_cur(p_line_id  IN  NUMBER) IS
        SELECT line_number,
               start_date,
               end_date,
               cognomen,
               lse_id
         FROM  OKC_K_LINES_V
         WHERE  ID = p_line_id;

    CURSOR prod_name_desc_cur(p_line_id             IN NUMBER,
                              p_organization_id     IN NUMBER,
                              p_inventory_item_id   IN NUMBER) IS
        SELECT description,
               segment1,
               concatenated_segments

        FROM   mtl_system_items_kfv

        WHERE  inventory_item_id = p_inventory_item_id AND
               organization_id = p_organization_id ;

    l_chr_id               NUMBER;
    p_chr_id               NUMBER;
    l_line_id              NUMBER;
    l_organization_id      NUMBER;
    l_inventory_item_id    NUMBER;
    p_inventory_item_id    NUMBER;
    p_line_id              NUMBER;
    p_organization_id      NUMBER;
    l_name                 VARCHAR2(40);
    l_description          VARCHAR2(240);
    l_line_reference       VARCHAR2(300);
    l_short_description    VARCHAR2(600);
    l_cur_rec              cur_rec;
    l_hdr_cur_rec          hdr_cur_rec;
    l_line_cur_rec         line_cur_rec;
    l_api_version	CONSTANT NUMBER := 1.0;
    l_return_status	     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    BEGIN

        p_line_id := p_in_parameter_record.line_id;
        p_chr_id := p_in_parameter_record.chr_id;
        p_organization_id := p_in_parameter_record.organization_id;
        p_inventory_item_id := p_in_parameter_record.inventory_item_id;

        IF p_chr_id IS NOT NULL   THEN
            OPEN  hdr_cur(p_chr_id);
            FETCH hdr_cur INTO l_hdr_cur_rec;

            IF hdr_cur%Notfound THEN
                CLOSE hdr_cur;
                x_return_status := 'E';
                RAISE G_ERROR;
            END IF;

            CLOSE hdr_cur;
        END IF;

        IF p_line_id IS NOT NULL   THEN
            OPEN  line_cur(p_line_id);
            FETCH line_cur INTO l_line_cur_rec;

            IF line_cur%Notfound THEN
                CLOSE line_cur;
                x_return_status := 'E';
                RAISE G_ERROR;
            END IF;

            CLOSE line_cur;
        END IF;

        IF p_line_id IS NOT NULL AND
            p_organization_id IS NOT NULL AND
            p_inventory_item_id IS NOT NULL  THEN

            OPEN   prod_name_desc_cur(p_line_id, p_organization_id, p_inventory_item_id);
            FETCH  prod_name_desc_cur INTO l_cur_rec;

            IF prod_name_desc_cur%Notfound THEN
                CLOSE prod_name_desc_cur;
                x_return_status := 'E';
                RAISE G_ERROR;
            END IF;

            CLOSE  prod_name_desc_cur;
        END IF;

        x_cur_rec := l_cur_rec;
        x_hdr_cur_rec := l_hdr_cur_rec;
        x_line_cur_rec := l_line_cur_rec;
        x_return_status := l_return_status;


    EXCEPTION
        WHEN G_ERROR THEN
            NULL;
        WHEN OTHERS THEN
            OKC_API.SET_MESSAGE(p_app_name => G_APP_NAME_OKC,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM);

            x_return_status := G_RET_STS_UNEXP_ERROR;

    END COPY_PARAMETER;

    FUNCTION chk_counter (p_object1_id1 NUMBER,
                          p_cle_id      NUMBER,
                          p_lse_id      NUMBER DEFAULT NULL) RETURN NUMBER IS
    CURSOR get_ctr_association_csr IS
       	SELECT counter_group_id
        FROM okx_ctr_associations_v
	WHERE source_object_id = p_object1_id1;

    get_ctr_association_rec get_ctr_association_csr%ROWTYPE;

    -- Bug 5284349 --
    -- Called in the case of Service line

    CURSOR get_ctr_grp_csr IS
        --Bug 5036682 performance issue
        --SELECT template_flag
        --FROM okx_counter_groups_v
        --WHERE source_object_id = p_cle_id
        --AND source_object_code = 'CONTRACT_LINE';
        /*
	SELECT a.template_flag
        FROM cs_csi_counter_groups a
        WHERE a.source_object_id = p_cle_id
        AND a.source_object_code = 'CONTRACT_LINE'
        AND(
            (a.template_flag = 'Y') OR
            (a.template_flag = 'N' AND EXISTS (select 1 from
                                      csi_counters_b ccb, csi_counter_associations cca
                                      where a.counter_group_id = ccb.group_id AND
                                      ccb.counter_id = cca.counter_id))
        );*/

	SELECT a.template_flag
	FROM cs_csi_counter_groups a,
	csi_counters_b ccb, csi_counter_associations cca
	WHERE a.counter_group_id = ccb.group_id AND
	ccb.counter_id = cca.counter_id AND
	cca.source_object_id = p_cle_id AND
	cca.source_object_code = 'CONTRACT_LINE';
    -- Bug 5284349 --
    get_ctr_grp_rec get_ctr_grp_csr%ROWTYPE;

    CURSOR get_ctr_csr IS
        --SELECT COUNT(counter_id) cnt
        --FROM okx_counters_v
        --WHERE counter_id = p_object1_id1;
        --bug 5036623
        SELECT COUNT(temp.counter_id) cnt
        FROM
            (SELECT counter_id FROM CSI_COUNTER_TEMPLATE_B
            UNION ALL
            SELECT counter_id FROM CSI_COUNTERS_B) temp
        WHERE temp.counter_id = p_object1_id1;

    get_ctr_rec get_ctr_csr%ROWTYPE;

    CURSOR get_ctr_grp_csr1 (p_ctr_grp_id NUMBER) IS
        SELECT template_flag
	--   FROM okx_counter_groups_v
        FROM csi_counter_groups_v -- Bug 5284349
	WHERE counter_group_id = p_ctr_grp_id;

    get_ctr_grp_rec1 get_ctr_grp_csr1%ROWTYPE;
    l_count         NUMBER := 0;

    /*Value of l_return
    '0'  -> no record
    '1'  -> record exist
    '-99 -> record exists but template one
    */

    BEGIN
        IF NVL(p_lse_id, - 99) = 12
            THEN
            OPEN get_ctr_csr;
            FETCH get_ctr_csr INTO get_ctr_rec;
            CLOSE get_ctr_csr;
            RETURN(get_ctr_rec.cnt);
        ELSE

            l_count := 0;

            IF p_cle_id IS NOT NULL
                THEN
                OPEN get_ctr_grp_csr;
                FETCH get_ctr_grp_csr INTO get_ctr_grp_rec;
                IF get_ctr_grp_csr%FOUND
                    THEN
                    IF get_ctr_grp_rec.template_flag = 'Y'
                        THEN
                        l_count :=  - 99;
                    ELSE
                        l_count := 1;
                    END IF;
                ELSE
                    l_count := 0;
                END IF; --IF get_ctr_grp_csr%FOUND

                CLOSE get_ctr_grp_csr;
                RETURN(l_count);
            END IF; --IF p_cle_id IS NOT NULL

            l_count := 0;
            -- Code would not be Used
            IF (p_cle_id IS NULL AND p_object1_id1 IS NOT NULL)
                THEN
                OPEN get_ctr_association_csr;
                FETCH get_ctr_association_csr INTO get_ctr_association_rec;
                IF get_ctr_association_csr%FOUND
                    THEN
                    OPEN get_ctr_grp_csr1 (get_ctr_association_rec.counter_group_id);
                    FETCH get_ctr_grp_csr1 INTO get_ctr_grp_rec1;
                    IF get_ctr_grp_csr1%FOUND
                        THEN
                        IF get_ctr_grp_rec1.template_flag = 'Y'
                            THEN
                            l_count :=  - 99;
                        ELSE
                            l_count := 1;
                        END IF;
                    END IF; --IF get_ctr_grp_csr1%FOUND
                    CLOSE  get_ctr_grp_csr1;
                ELSE
                    l_count := 0;
                END IF; --IF get_ctr_association_csr%FOUND
                CLOSE get_ctr_association_csr;
                RETURN(l_count);
            END IF; --IF (p_cle_id IS NULL AND p_object1_id1 IS NOT NULL)
            -- Code would not be used
        END IF; -- IF p_lse_id IS NULL
        RETURN(l_count);

    END chk_counter;

    FUNCTION chk_event (p_object1_id1               NUMBER DEFAULT NULL,
                        p_cle_id                    NUMBER DEFAULT NULL,
                        p_lse_id                    NUMBER DEFAULT NULL,
                        p_counter_group_id          NUMBER DEFAULT NULL,
                        p_template_counter_group_id NUMBER DEFAULT NULL) RETURN NUMBER
    IS
    CURSOR get_inst_event_csr IS
        SELECT COUNT(object_id) cnt
        FROM   okc_condition_headers_b
        WHERE  object_id = p_cle_id
        AND    jtot_object_code = 'OKC_K_LINE';

    get_inst_event_rec get_inst_event_csr%ROWTYPE;

    CURSOR get_ctr_association_csr IS
        SELECT counter_group_id
        FROM okx_ctr_associations_v
        WHERE source_object_id = p_object1_id1;

    get_ctr_association_rec get_ctr_association_csr%ROWTYPE;

    CURSOR get_template_event_csr (p_ctr_grp_id NUMBER) IS
        SELECT COUNT(counter_group_id) cnt
        FROM   okc_condition_headers_b
        WHERE  counter_group_id = p_ctr_grp_id
        AND    template_yn = 'Y';

    get_template_event_rec get_template_event_csr%ROWTYPE;
    l_return           NUMBER := 0;

    /*Value of l_return
    '0'  -> no record
    '1'  -> record exist
    '-99 -> record exists but template one
    */

    FUNCTION chk_event_template (p_ctr_grp_id NUMBER) RETURN NUMBER IS
    CURSOR get_event_csr (p_ctr_grp_id NUMBER) IS
        SELECT template_yn
        FROM   OKC_CONDITION_HEADERS_B
        WHERE  counter_group_id = p_ctr_grp_id;
    get_event_rec      get_event_csr%ROWTYPE;
    l_return_no        NUMBER := 0;
    BEGIN

        OPEN get_event_csr(p_ctr_grp_id);
        FETCH get_event_csr INTO get_event_rec;
        IF get_event_csr%FOUND
            THEN
            IF get_event_rec.template_yn = 'Y'
                THEN
                l_return_no :=  - 99;
            ELSE
                l_return_no := 1;
            END IF;
        ELSE
            l_return_no := 0;
        END IF; --IF get_event_csr%FOUND
        CLOSE get_event_csr;
        RETURN (l_return_no);

    END;
    BEGIN
        l_return := 0;

        IF NVL(p_lse_id, - 99) = 12
            THEN
            IF p_counter_group_id IS NOT NULL
                THEN
                l_return := chk_event_template (p_counter_group_id);

                IF (l_return = 0 AND p_template_counter_group_id IS NOT NULL)
                    THEN
                    l_return := chk_event_template (p_template_counter_group_id);
                END IF;
            END IF;
            RETURN (l_return);

        ELSE
            IF p_cle_id IS NOT NULL
                THEN
                OPEN  get_inst_event_csr;
                FETCH get_inst_event_csr INTO get_inst_event_rec;
                CLOSE get_inst_event_csr;
                RETURN(get_inst_event_rec.cnt);

            END IF; -- IF p_cle_id IS NOT NULL

            IF p_cle_id IS NULL
                THEN
                --get counter_group_id
                OPEN get_ctr_association_csr;
                FETCH get_ctr_association_csr INTO get_ctr_association_rec;
                --get attached event if
                IF get_ctr_association_csr%FOUND
                    THEN
                    OPEN get_template_event_csr(get_ctr_association_rec.counter_group_id);
                    FETCH get_template_event_csr INTO get_template_event_rec;
                    CLOSE get_template_event_csr;
                    IF get_template_event_rec.cnt > 0
                        THEN
                        l_return :=  - 99; -- '-99' is for template event not intantiated one
                    ELSE
                        l_return := 0;
                    END IF;
                END IF; --get_ctr_association_csr%FOUND
                CLOSE get_ctr_association_csr;
                RETURN(l_return);

            END IF; -- IF p_cle_id IS NULL
        END IF; --IF p_lse_id = 12
        RETURN(l_return);
    END chk_event;


    PROCEDURE Contact_Point
    (
     p_api_version         IN   NUMBER,
     p_init_msg_list       IN   VARCHAR2,
     p_commit              IN   VARCHAR2,
     P_contact_point_rec   IN   contact_point_rec,
     x_return_status       OUT NOCOPY  VARCHAR2,
     x_msg_count           OUT NOCOPY  NUMBER,
     x_msg_data            OUT NOCOPY  VARCHAR2,
     x_contact_point_id    OUT NOCOPY  NUMBER
     )
    IS
    G_ERROR                  EXCEPTION;
    l_create_update_flag     VARCHAR2(10);
    BEGIN

        IF (P_Contact_point_rec.contact_point_id IS NULL AND
            p_contact_point_rec.email_address IS NULL) THEN
            x_return_status := OKC_API.G_RET_STS_SUCCESS;
            RETURN;
        ELSIF (P_Contact_point_rec.contact_point_id IS NULL AND
               p_contact_point_rec.email_address IS NOT NULL) THEN
            --Create
            oks_auth_util_pvt.Create_Contact_Points
            (
             p_api_version => p_api_version,
             p_init_msg_list => p_init_msg_list,
             p_commit => p_commit,
             P_contact_point_rec => p_contact_point_rec,
             x_return_status => x_return_status,
             x_msg_count => x_msg_count,
             x_msg_data => x_msg_data,
             x_contact_point_id => x_contact_point_id
             );
            IF x_return_status <> 'S' THEN
                RAISE G_ERROR;
            END IF;
        ELSE
            --Update
            oks_auth_util_pvt.Update_Contact_Points
            (
             p_api_version => p_api_version,
             p_init_msg_list => p_init_msg_list,
             p_commit => p_commit,
             P_contact_point_rec => p_contact_point_rec,
             x_return_status => x_return_status,
             x_msg_count => x_msg_count,
             x_msg_data => x_msg_data
             );
            IF x_return_status <> 'S' THEN
                RAISE G_ERROR;
            END IF;
            x_contact_point_id := p_contact_point_rec.contact_point_id;
        END IF;
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
    EXCEPTION
        WHEN G_ERROR THEN
            NULL;
        WHEN OTHERS THEN
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.set_message
            (OKC_API.G_APP_NAME,
             G_UNEXPECTED_ERROR,
             G_SQLCODE_TOKEN,
             SQLCODE,
             G_SQLERRM_TOKEN,
             SQLERRM);
    END Contact_Point;



    PROCEDURE CREATE_CII_FOR_SUBSCRIPTION
    (
     p_api_version   IN NUMBER,
     p_init_msg_list IN VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count     OUT NOCOPY NUMBER,
     x_msg_data      OUT NOCOPY VARCHAR2,
     p_cle_id        IN NUMBER,
     p_quantity      IN NUMBER DEFAULT 1,
     x_instance_id   OUT NOCOPY NUMBER
     )IS
    BEGIN
        OKS_AUTH_UTIL_PVT.CREATE_CII_FOR_SUBSCRIPTION
        (
         p_api_version,
         p_init_msg_list,
         x_return_status,
         x_msg_count,
         x_msg_data,
         p_cle_id,
         p_quantity,
         x_instance_id
         );


    END;

    PROCEDURE DELETE_CII_FOR_SUBSCRIPTION
    (p_api_version   IN NUMBER,
     p_init_msg_list IN VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count     OUT NOCOPY NUMBER,
     x_msg_data      OUT NOCOPY VARCHAR2,
     p_instance_id   IN NUMBER
     )
    IS
    BEGIN
        OKS_AUTH_UTIL_PVT.DELETE_CII_FOR_SUBSCRIPTION
        (p_api_version,
         p_init_msg_list,
         x_return_status,
         x_msg_count,
         x_msg_data,
         p_instance_id
         ) ;

    END DELETE_CII_FOR_SUBSCRIPTION ;


    FUNCTION def_sts_code(p_ste_code VARCHAR2) RETURN VARCHAR2 IS
    CURSOR get_def_sts_code_csr IS
        SELECT code
        FROM okc_statuses_v
        WHERE ste_code = p_ste_code
        AND   default_yn = 'Y';
    get_def_sts_code_rec get_def_sts_code_csr%ROWTYPE;
    BEGIN

        OPEN get_def_sts_code_csr;
        FETCH get_def_sts_code_csr INTO get_def_sts_code_rec;
        CLOSE get_def_sts_code_csr;
        RETURN (get_def_sts_code_rec.code);

    END def_sts_code;

    FUNCTION get_ste_code(p_sts_code VARCHAR2) RETURN VARCHAR2 IS
    CURSOR get_ste_code_csr IS
        SELECT ste_code
        FROM okc_statuses_v
        WHERE code = p_sts_code;
    get_ste_code_rec get_ste_code_csr%ROWTYPE;
    BEGIN

        OPEN get_ste_code_csr;
        FETCH get_ste_code_csr INTO get_ste_code_rec;
        CLOSE get_ste_code_csr;
        RETURN (get_ste_code_rec.ste_code);

    END get_ste_code;
    --start contact creation OCT 2004
    -- added new procedure for contact creation project
    PROCEDURE create_person (
                             p_init_msg_list                    IN      VARCHAR2 := FND_API.G_FALSE,
                             p_person_tbl                       IN      PERSON_TBL_TYPE,
                             x_party_id                         OUT NOCOPY     NUMBER,
                             x_party_number                     OUT NOCOPY     VARCHAR2,
                             x_profile_id                       OUT NOCOPY     NUMBER,
                             x_return_status                    OUT NOCOPY     VARCHAR2,
                             x_msg_count                        OUT NOCOPY     NUMBER,
                             x_msg_data                         OUT NOCOPY     VARCHAR2
                             ) IS
    BEGIN
        OKS_AUTH_UTIL_PVT.create_person
        (p_init_msg_list,
         p_person_tbl,
         x_party_id,
         x_party_number,
         x_profile_id,
         x_return_status,
         x_msg_count,
         x_msg_data);

    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.set_message
            (OKC_API.G_APP_NAME,
             G_UNEXPECTED_ERROR,
             G_SQLCODE_TOKEN,
             SQLCODE,
             G_SQLERRM_TOKEN,
             SQLERRM);
    END;

    PROCEDURE update_person (
                             p_init_msg_list                    IN      VARCHAR2 := FND_API.G_FALSE,
                             p_person_tbl                       IN      PERSON_TBL_TYPE,
                             p_party_object_version_number      IN     NUMBER,
                             x_profile_id                       OUT NOCOPY     NUMBER,
                             x_return_status                    OUT NOCOPY     VARCHAR2,
                             x_msg_count                        OUT NOCOPY     NUMBER,
                             x_msg_data                         OUT NOCOPY     VARCHAR2
                             )IS
    BEGIN
        OKS_AUTH_UTIL_PVT.update_person
        (p_init_msg_list,
         p_person_tbl,
         p_party_object_version_number,
         x_profile_id,
         x_return_status,
         x_msg_count,
         x_msg_data);

    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.set_message
            (OKC_API.G_APP_NAME,
             G_UNEXPECTED_ERROR,
             G_SQLCODE_TOKEN,
             SQLCODE,
             G_SQLERRM_TOKEN,
             SQLERRM);
    END;

    PROCEDURE create_org_contact (
                                  p_init_msg_list                    IN       VARCHAR2 := FND_API.G_FALSE,
                                  p_org_contact_tbl                  IN       ORG_CONTACT_TBL_TYPE,
                                  p_relationship_tbl_type            IN       relationship_tbl_type,
                                  x_org_contact_id                   OUT NOCOPY      NUMBER,
                                  x_party_rel_id                     OUT NOCOPY      NUMBER,
                                  x_party_id                         OUT NOCOPY      NUMBER,
                                  x_party_number                     OUT NOCOPY      VARCHAR2,
                                  x_return_status                    OUT NOCOPY      VARCHAR2,
                                  x_msg_count                        OUT NOCOPY      NUMBER,
                                  x_msg_data                         OUT NOCOPY      VARCHAR2
                                  )IS
    BEGIN
        OKS_AUTH_UTIL_PVT.create_org_contact
        (p_init_msg_list,
         p_org_contact_tbl,
         p_relationship_tbl_type,
         x_org_contact_id,
         x_party_rel_id,
         x_party_id,
         x_party_number,
         x_return_status,
         x_msg_count,
         x_msg_data);

    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.set_message
            (OKC_API.G_APP_NAME,
             G_UNEXPECTED_ERROR,
             G_SQLCODE_TOKEN,
             SQLCODE,
             G_SQLERRM_TOKEN,
             SQLERRM);
    END;

    PROCEDURE update_org_contact (
                                  p_init_msg_list                    IN       VARCHAR2 := FND_API.G_FALSE,
                                  p_org_contact_tbl                  IN       ORG_CONTACT_TBL_TYPE,
                                  p_relationship_tbl_type            IN       relationship_tbl_type,
                                  p_cont_object_version_number       IN OUT NOCOPY   NUMBER,
                                  p_rel_object_version_number        IN OUT NOCOPY   NUMBER,
                                  p_party_object_version_number      IN OUT NOCOPY   NUMBER,
                                  x_return_status                    OUT NOCOPY      VARCHAR2,
                                  x_msg_count                        OUT NOCOPY      NUMBER,
                                  x_msg_data                         OUT NOCOPY      VARCHAR2
                                  )IS
    BEGIN
        OKS_AUTH_UTIL_PVT.update_org_contact
        (p_init_msg_list,
         p_org_contact_tbl,
         p_relationship_tbl_type,
         p_cont_object_version_number,
         p_rel_object_version_number,
         p_party_object_version_number,
         x_return_status,
         x_msg_count,
         x_msg_data);

    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.set_message
            (OKC_API.G_APP_NAME,
             G_UNEXPECTED_ERROR,
             G_SQLCODE_TOKEN,
             SQLCODE,
             G_SQLERRM_TOKEN,
             SQLERRM);
    END;

    PROCEDURE create_party_site (
                                 p_init_msg_list                 IN          VARCHAR2 := FND_API.G_FALSE,
                                 p_party_site_tbl                IN          PARTY_SITE_TBL_TYPE,
                                 x_party_site_id                 OUT NOCOPY         NUMBER,
                                 x_party_site_number             OUT NOCOPY         VARCHAR2,
                                 x_return_status                 OUT NOCOPY         VARCHAR2,
                                 x_msg_count                     OUT NOCOPY         NUMBER,
                                 x_msg_data                      OUT NOCOPY         VARCHAR2
                                 )IS
    BEGIN
        OKS_AUTH_UTIL_PVT.create_party_site
        (p_init_msg_list,
         p_party_site_tbl,
         x_party_site_id,
         x_party_site_number,
         x_return_status,
         x_msg_count,
         x_msg_data);

    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.set_message
            (OKC_API.G_APP_NAME,
             G_UNEXPECTED_ERROR,
             G_SQLCODE_TOKEN,
             SQLCODE,
             G_SQLERRM_TOKEN,
             SQLERRM);
    END;

    PROCEDURE update_party_site (
                                 p_init_msg_list                 IN          VARCHAR2 := FND_API.G_FALSE,
                                 p_party_site_tbl                IN          PARTY_SITE_TBL_TYPE,
                                 p_object_version_number         IN OUT NOCOPY      NUMBER,
                                 x_return_status                 OUT NOCOPY         VARCHAR2,
                                 x_msg_count                     OUT NOCOPY         NUMBER,
                                 x_msg_data                      OUT NOCOPY         VARCHAR2
                                 )IS
    BEGIN
        OKS_AUTH_UTIL_PVT.update_party_site
        (p_init_msg_list,
         p_party_site_tbl,
         p_object_version_number,
         x_return_status,
         x_msg_count,
         x_msg_data);

    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.set_message
            (OKC_API.G_APP_NAME,
             G_UNEXPECTED_ERROR,
             G_SQLCODE_TOKEN,
             SQLCODE,
             G_SQLERRM_TOKEN,
             SQLERRM);
    END;

    PROCEDURE create_cust_account_role (
                                        p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
                                        p_cust_account_role_tbl                 IN     CUST_ACCOUNT_ROLE_tbl_TYPE,
                                        x_cust_account_role_id                  OUT NOCOPY    NUMBER,
                                        x_return_status                         OUT NOCOPY    VARCHAR2,
                                        x_msg_count                             OUT NOCOPY    NUMBER,
                                        x_msg_data                              OUT NOCOPY    VARCHAR2
                                        )IS
    BEGIN
        OKS_AUTH_UTIL_PVT.create_cust_account_role
        (p_init_msg_list,
         p_cust_account_role_tbl,
         x_cust_account_role_id,
         x_return_status,
         x_msg_count,
         x_msg_data);

    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.set_message
            (OKC_API.G_APP_NAME,
             G_UNEXPECTED_ERROR,
             G_SQLCODE_TOKEN,
             SQLCODE,
             G_SQLERRM_TOKEN,
             SQLERRM);
    END;

    PROCEDURE update_cust_account_role (
                                        p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
                                        p_cust_account_role_tbl                 IN     CUST_ACCOUNT_ROLE_tbl_TYPE,
                                        p_object_version_number                 IN OUT NOCOPY NUMBER,
                                        x_return_status                         OUT NOCOPY    VARCHAR2,
                                        x_msg_count                             OUT NOCOPY    NUMBER,
                                        x_msg_data                              OUT NOCOPY    VARCHAR2
                                        ) IS
    BEGIN
        OKS_AUTH_UTIL_PVT.update_cust_account_role
        (p_init_msg_list,
         p_cust_account_role_tbl,
         p_object_version_number,
         x_return_status,
         x_msg_count,
         x_msg_data);

    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.set_message
            (OKC_API.G_APP_NAME,
             G_UNEXPECTED_ERROR,
             G_SQLCODE_TOKEN,
             SQLCODE,
             G_SQLERRM_TOKEN,
             SQLERRM);
    END;

    PROCEDURE create_cust_acct_site (
                                     p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
                                     p_cust_acct_site_tbl                    IN     CUST_ACCT_SITE_TBL_TYPE,
                                     x_cust_acct_site_id                     OUT NOCOPY    NUMBER,
                                     x_return_status                         OUT NOCOPY    VARCHAR2,
                                     x_msg_count                             OUT NOCOPY    NUMBER,
                                     x_msg_data                              OUT NOCOPY    VARCHAR2
                                     )IS
    BEGIN
        OKS_AUTH_UTIL_PVT.create_cust_acct_site
        (p_init_msg_list,
         p_cust_acct_site_tbl,
         x_cust_acct_site_id,
         x_return_status,
         x_msg_count,
         x_msg_data);

    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.set_message
            (OKC_API.G_APP_NAME,
             G_UNEXPECTED_ERROR,
             G_SQLCODE_TOKEN,
             SQLCODE,
             G_SQLERRM_TOKEN,
             SQLERRM);
    END;

    PROCEDURE update_cust_acct_site (
                                     p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
                                     p_cust_acct_site_tbl                    IN     CUST_ACCT_SITE_TBL_TYPE,
                                     p_object_version_number                 IN OUT NOCOPY NUMBER,
                                     x_return_status                         OUT NOCOPY    VARCHAR2,
                                     x_msg_count                             OUT NOCOPY    NUMBER,
                                     x_msg_data                              OUT NOCOPY    VARCHAR2
                                     )IS

    BEGIN
        OKS_AUTH_UTIL_PVT.update_cust_acct_site
        (p_init_msg_list,
         p_cust_acct_site_tbl,
         p_object_version_number,
         x_return_status,
         x_msg_count,
         x_msg_data);

    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.set_message
            (OKC_API.G_APP_NAME,
             G_UNEXPECTED_ERROR,
             G_SQLCODE_TOKEN,
             SQLCODE,
             G_SQLERRM_TOKEN,
             SQLERRM);
    END;


    -- GCHADHA --
    -- MULTI CURRENCY PRICELIST --
    -- THIS FUNCTION IS CALLED WHEN REPRICING MULTIPLE LINES  --
    -- 28-OCT-2004 --
    PROCEDURE  COMPUTE_PRICE_MULTIPLE_LINE(
                                           p_api_version                 IN         NUMBER,
                                           p_detail_tbl                  IN         MULTI_LINE_TBL,
                                           x_return_status               OUT NOCOPY VARCHAR2,
                                           x_status_tbl                  OUT NOCOPY oks_qp_int_pvt.Pricing_Status_tbl )  IS

    l_input_details  OKS_QP_PKG.INPUT_DETAILS;
    l_output_details OKS_QP_PKG.PRICE_DETAILS;
    l_modif_details  QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
    l_pb_details     OKS_QP_PKG.G_PRICE_BREAK_TBL_TYPE;
    l_return_status  VARCHAR2(20);
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(2000);
    l_status_tbl     oks_qp_int_pvt.Pricing_Status_tbl;
    l_final_status_tbl     oks_qp_int_pvt.Pricing_Status_tbl;
    l_count          NUMBER;


    BEGIN
        IF p_detail_tbl.COUNT > 0 THEN
            FOR I IN p_detail_tbl.FIRST..p_detail_tbl.LAST
                LOOP
                -- Changes made for Partial Period Change Request --
                -- IF  nvl(p_detail_tbl(I).line_pl_flag,'N') <> 'N' OR  nvl(p_detail_tbl(I).line_uom_flag,'N') <> 'N' THEN
                IF  nvl(p_detail_tbl(I).line_pl_flag, 'N') <> 'N' THEN
                    -- Changes made for Partial Period Change Request --
                    l_input_details.line_id := p_detail_tbl(I).id;
                    IF p_detail_tbl(I).lse_id = '46' THEN
                        l_input_details.intent := 'SB_P';
                    ELSE
                        l_input_details.intent := 'LP';
                    END IF;


                    oks_qp_int_pvt.compute_price
                    (
                     p_api_version => 1.0,
                     p_init_msg_list => 'T',
                     p_detail_rec => l_input_details,
                     x_price_details => l_output_details,
                     x_modifier_details => l_modif_details,
                     x_price_break_details => l_pb_details,
                     x_return_status => l_return_status,
                     x_msg_count => l_msg_count,
                     x_msg_data => l_msg_data
                     );

                    IF NVL(l_return_status, '!') <> 'S' THEN
                        x_return_status := l_return_status;
                        RAISE G_ERROR;
                    END IF;
                    IF l_status_tbl.COUNT = 0 THEN
                        l_count := 0;
                    END IF;

                    l_status_tbl := oks_qp_int_pvt.Get_Pricing_Messages;
                    -- GCHADHA --
                    -- BUG 4020869 --
                    -- 19-NOV-2004 --
                    IF l_status_tbl.COUNT > 0 THEN
                        FOR I IN l_status_tbl.FIRST..l_status_tbl.LAST LOOP
                            l_final_status_tbl(l_count).Service_name := l_status_tbl(I).Service_name;
                            l_final_status_tbl(l_count).Coverage_level_name := l_status_tbl(I).Coverage_level_name;
                            l_final_status_tbl(l_count).Status_Code := l_status_tbl(I).Status_Code;
                            l_final_status_tbl(l_count).Status_text := l_status_tbl(I).Status_text;
                            l_count := l_count + 1;
                        END LOOP;
                    END IF;
                    -- END GCHADHA --
                END IF;
            END LOOP;
        END IF;

        x_return_status := OKC_API.G_RET_STS_SUCCESS;
        x_status_tbl := l_final_status_tbl;
    EXCEPTION
        WHEN G_ERROR THEN
            NULL;
    END COMPUTE_PRICE_MULTIPLE_LINE;
    -- END GCHADHA --

    -- GCHADHA --
    -- BUG 4053911 --
    -- DELETING THE PRICING MODIFIER WHEN THE CURRENCY OF THE
    -- CONTRACT IS CHANGED.
    PROCEDURE DELETE_PRICE_ADJUST_LINE(
                                       p_api_version                 IN         NUMBER,
                                       p_chr_id                      IN         NUMBER,
                                       p_header_currency             IN         VARCHAR2) IS

    BEGIN
        -- HEADERS --
        DELETE FROM OKC_PRICE_ADJUSTMENTS
        WHERE ID IN
         (SELECT A.ID
          FROM OKC_PRICE_ADJUSTMENTS A, qp_list_headers_b B
          WHERE A.CHR_ID = P_CHR_ID
          AND B.LIST_HEADER_ID = A.LIST_HEADER_ID
          AND B.CURRENCY_CODE <> P_HEADER_CURRENCY
          AND B.CURRENCY_CODE IS NOT NULL ) ;
        -- LINES AND SUBLINES --
        DELETE FROM OKC_PRICE_ADJUSTMENTS WHERE
        ID IN (SELECT A.ID
               FROM OKC_PRICE_ADJUSTMENTS A, QP_LIST_HEADERS_B B
               WHERE A.CLE_ID IN
               (SELECT ID FROM OKC_K_LINES_B WHERE
                DNZ_CHR_ID = P_CHR_ID
                AND LSE_ID IN (1, 12, 46, 19, 7, 8, 9, 10, 11, 13, 35, 25))
               AND B.LIST_HEADER_ID = A.LIST_HEADER_ID
               AND B.CURRENCY_CODE <> P_HEADER_CURRENCY
               AND B.CURRENCY_CODE IS NOT NULL ) ;
    END;
    -- END GCHADHA --

    -- END GCHADHA --

    -- PARTIAL PERIOD COMPUTATION PCC --
    FUNCTION is_not_subscrip(p_cle_id NUMBER) RETURN VARCHAR2
    IS
    CURSOR chk_subscr_item_csr IS
        SELECT COUNT(instance_id) cnt
        FROM   oks_subscr_header_b sub, okc_k_items_v item
        WHERE  sub.instance_id = item.object1_id1
        AND    item.cle_id = p_cle_id;
    chk_subscr_item_rec chk_subscr_item_csr%ROWTYPE;

    l_yes_no    VARCHAR2(1);
    BEGIN

        OPEN chk_subscr_item_csr;
        FETCH chk_subscr_item_csr INTO chk_subscr_item_rec;
        CLOSE chk_subscr_item_csr;

        IF chk_subscr_item_rec.cnt > 0
            THEN
            l_yes_no := 'Y';
        ELSE
            l_yes_no := 'N';
        END IF;
        RETURN(l_yes_no);
    END is_not_subscrip;

    -- PARTIAL PERIOD COMPUTATION PCC --

END OKS_AUTH_UTIL_PUB;

/
