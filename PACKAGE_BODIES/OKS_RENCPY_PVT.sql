--------------------------------------------------------
--  DDL for Package Body OKS_RENCPY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_RENCPY_PVT" AS
/* $Header: OKSRCPYB.pls 120.6 2006/06/01 22:33:24 skekkar noship $*/

    SUBTYPE pavv_rec_type 	    IS OKC_PRICE_ADJUSTMENT_PUB.pavv_rec_type;
    SUBTYPE scnv_rec_type 	    IS OKC_SECTIONS_PUB.scnv_rec_type;
    SUBTYPE sccv_rec_type 	    IS OKC_SECTIONS_PUB.sccv_rec_type;
    SUBTYPE gvev_rec_type       IS OKC_CONTRACT_PUB.gvev_rec_type;
    g_chrv_rec chrv_rec_type;
  ----------------------------------------------------------------------------
  --PL/SQL Table to check the sections has already copied.
  --If Yes give the new scn_id
  ----------------------------------------------------------------------------
    TYPE sections_rec_type IS RECORD (
                                      old_scn_id		NUMBER := OKC_API.G_MISS_NUM,
                                      new_scn_id		NUMBER := OKC_API.G_MISS_NUM);

    TYPE	sections_tbl_type IS TABLE OF sections_rec_type INDEX	BY BINARY_INTEGER;
    g_sections	sections_tbl_type;

  ----------------------------------------------------------------------------
  --PL/SQL Table to check the party has already copied.
  --If Yes give the new cpl_id ----Begins
  ----------------------------------------------------------------------------
    TYPE party_rec_type IS RECORD (
                                   old_cpl_id		NUMBER := OKC_API.G_MISS_NUM,
                                   new_cpl_id		NUMBER := OKC_API.G_MISS_NUM);
    TYPE	party_tbl_type IS TABLE OF party_rec_type INDEX	BY BINARY_INTEGER;
    g_party	party_tbl_type;

  ----------------------------------------------------------------------------
  -- PL/SQL table to keep line/header id and corresponding ole_id
  -- This table will store the following combinations
  --                 Header Id  - OLE_ID for Header
  --                 Line ID    - OLE_ID for the Line
  -- To get PARENT_OLE_ID for top line, search for ID = header_id
  --                      for sub line, search for ID = Parent Line Id
  ----------------------------------------------------------------------------
    TYPE line_op_rec_type IS RECORD (
                                     id                           NUMBER := OKC_API.G_MISS_NUM,
                                     ole_id                       NUMBER := OKC_API.G_MISS_NUM);

    TYPE line_op_tbl_type IS TABLE OF line_op_rec_type INDEX BY BINARY_INTEGER;

    g_op_lines line_op_tbl_type;

    FUNCTION Is_Number(p_string VARCHAR2) RETURN BOOLEAN IS
    n NUMBER;
    BEGIN
        n := to_number(p_string);
        RETURN TRUE;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN FALSE;
    END;

  ----------------------------------------------------------------------------
  --Logic to check the sections has already copied.
  --If Yes give the new scn_id ----Begins
  ----------------------------------------------------------------------------

    PROCEDURE add_sections(p_old_scn_id IN NUMBER,
                           p_new_scn_id IN NUMBER) IS
    i 		NUMBER := 0;
    BEGIN
        IF g_sections.COUNT > 0 THEN
            i := g_sections.LAST;
        END IF;
        g_sections(i + 1).old_scn_id := p_old_scn_id;
        g_sections(i + 1).new_scn_id := p_new_scn_id;
    END add_sections;

    FUNCTION get_new_scn_id(p_old_scn_id IN NUMBER,
                            p_new_scn_id OUT NOCOPY  NUMBER) RETURN BOOLEAN IS
    i 		NUMBER := 0;
    BEGIN
        IF g_sections.COUNT > 0 THEN
            i := g_sections.FIRST;
            LOOP
                IF g_sections(i).old_scn_id = p_old_scn_id THEN
                    p_new_scn_id := g_sections(i).new_scn_id;
                    RETURN TRUE;
                END IF;
                EXIT WHEN (i = g_sections.LAST);
                i := g_sections.NEXT(i);
            END LOOP;
            RETURN FALSE;
        END IF;
        RETURN FALSE;
    END get_new_scn_id;

  ----------------------------------------------------------------------------
  --Logic to check the party has already copied.
  --If Yes give the new cpl_id ----Begins
  ----------------------------------------------------------------------------

    PROCEDURE add_party(p_old_cpl_id IN NUMBER,
                        p_new_cpl_id IN NUMBER) IS
    i 		NUMBER := 0;
    BEGIN
        IF g_party.COUNT > 0 THEN
            i := g_party.LAST;
        END IF;
        g_party(i + 1).old_cpl_id := p_old_cpl_id;
        g_party(i + 1).new_cpl_id := p_new_cpl_id;
    END add_party;

    FUNCTION get_new_cpl_id(p_old_cpl_id IN NUMBER,
                            p_new_cpl_id OUT NOCOPY NUMBER) RETURN BOOLEAN IS
    i 		NUMBER := 0;
    BEGIN
        IF g_party.COUNT > 0 THEN
            i := g_party.FIRST;
            LOOP
                IF g_party(i).old_cpl_id = p_old_cpl_id THEN
                    p_new_cpl_id := g_party(i).new_cpl_id;
                    RETURN TRUE;
                END IF;
                EXIT WHEN (i = g_party.LAST);
                i := g_party.NEXT(i);
            END LOOP;
            RETURN FALSE;
        END IF;
        RETURN FALSE;
    END get_new_cpl_id;
  ----------------------------------------------------------------------------
  --Logic to check the party has already copied.
  --If Yes give the new cpl_id ----Ends.
  ----------------------------------------------------------------------------
  ----------------------------------------------------------------------------
  --Function specs  to populate pl/sql record with database values begins
  ----------------------------------------------------------------------------
    FUNCTION    get_atnv_rec(p_atn_id IN NUMBER,
                             x_atnv_rec OUT NOCOPY atnv_rec_type) RETURN  VARCHAR2;
    FUNCTION    get_catv_rec(p_cat_id IN NUMBER,
                             x_catv_rec OUT NOCOPY catv_rec_type) RETURN  VARCHAR2;
    FUNCTION    get_cimv_rec(p_cim_id IN NUMBER,
                             x_cimv_rec OUT NOCOPY cimv_rec_type) RETURN  VARCHAR2;
    FUNCTION    get_cacv_rec(p_cac_id IN NUMBER,
                             x_cacv_rec OUT NOCOPY cacv_rec_type) RETURN  VARCHAR2;
    FUNCTION    get_cplv_rec(p_cpl_id IN NUMBER,
                             x_cplv_rec OUT NOCOPY cplv_rec_type) RETURN  VARCHAR2;
    FUNCTION    get_cpsv_rec(p_cps_id IN NUMBER,
                             x_cpsv_rec OUT NOCOPY cpsv_rec_type) RETURN  VARCHAR2;
    FUNCTION    get_cgcv_rec(p_cgc_id IN NUMBER,
                             x_cgcv_rec OUT NOCOPY cgcv_rec_type) RETURN  VARCHAR2;
    FUNCTION    get_cnhv_rec(p_cnh_id IN NUMBER,
                             x_cnhv_rec OUT NOCOPY cnhv_rec_type) RETURN  VARCHAR2;
    FUNCTION    get_cnlv_rec(p_cnl_id IN NUMBER,
                             x_cnlv_rec OUT NOCOPY cnlv_rec_type) RETURN  VARCHAR2;

    FUNCTION    get_klnv_rec(p_old_cle_id IN NUMBER,
                             x_klnv_rec OUT NOCOPY klnv_rec_type)
    RETURN  VARCHAR2;
    FUNCTION    get_clev_rec(p_cle_id IN NUMBER,
                             x_clev_rec OUT NOCOPY clev_rec_type) RETURN  VARCHAR2;

    FUNCTION    get_ctcv_rec(p_ctc_id IN NUMBER,
                             x_ctcv_rec OUT NOCOPY ctcv_rec_type) RETURN  VARCHAR2;
    FUNCTION    get_pavv_rec(p_pav_id IN NUMBER,
                             x_pavv_rec OUT NOCOPY pavv_rec_type) RETURN  VARCHAR2;
    FUNCTION    get_scnv_rec(p_scn_id IN NUMBER,
                             x_scnv_rec OUT NOCOPY scnv_rec_type) RETURN  VARCHAR2;
    FUNCTION    get_sccv_rec(p_scc_id IN NUMBER,
                             x_sccv_rec OUT NOCOPY sccv_rec_type) RETURN  VARCHAR2;
  ----------------------------------------------------------------------------
  --Function specs  to populate pl/sql record with database values ends
  ----------------------------------------------------------------------------
  ----------------------------------------------------------------------------
  --Proceudre copy_sections - Makes a copy of the okc_sections and okc_section_contents.
  ----------------------------------------------------------------------------
    PROCEDURE copy_sections(
                            p_api_version                  IN NUMBER,
                            p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                            x_return_status                OUT NOCOPY VARCHAR2,
                            x_msg_count                    OUT NOCOPY NUMBER,
                            x_msg_data                     OUT NOCOPY VARCHAR2,
                            p_scc_id                       IN NUMBER,
                            p_to_cat_id                    IN NUMBER,
                            p_to_chr_id                    IN NUMBER) IS

    l_scn_id    NUMBER;
    l_scn_id_new    NUMBER;
    l_scn_id_out    NUMBER;
    l_scn_count NUMBER := 0;

    l_sccv_rec 	sccv_rec_type;
    x_sccv_rec 	sccv_rec_type;
    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    TYPE sec_rec_type IS RECORD (
                                 scn_id		NUMBER := OKC_API.G_MISS_NUM);
    TYPE	sec_tbl_type IS TABLE OF sec_rec_type
    INDEX	BY BINARY_INTEGER;
    l_sec	sec_tbl_type;

    CURSOR c_scc IS
        SELECT scn_id
        FROM   okc_section_contents
        WHERE  id = p_scc_id;

    CURSOR c_scn(p_scn_id IN NUMBER) IS
        SELECT id, LEVEL
        FROM   okc_sections_b
        CONNECT BY PRIOR scn_id = id
        START WITH id = p_scn_id;

    PROCEDURE copy_section(
                           p_api_version                  IN NUMBER,
                           p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                           x_return_status                OUT NOCOPY VARCHAR2,
                           x_msg_count                    OUT NOCOPY NUMBER,
                           x_msg_data                     OUT NOCOPY VARCHAR2,
                           p_scn_id                       IN NUMBER,
                           p_to_chr_id                    IN NUMBER,
                           x_scn_id                       OUT NOCOPY NUMBER) IS


    l_new_scn_id      NUMBER;

    l_scnv_rec 	scnv_rec_type;
    x_scnv_rec 	scnv_rec_type;
    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    BEGIN
        x_return_status := l_return_status;
        IF get_new_scn_id(p_scn_id, l_new_scn_id) THEN
            x_scn_id := l_new_scn_id;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

        l_return_status := get_scnv_rec(p_scn_id => p_scn_id,
                                        x_scnv_rec => l_scnv_rec);

        l_scnv_rec.chr_id := p_to_chr_id;

        IF get_new_scn_id(l_scnv_rec.scn_id, l_new_scn_id) THEN
            l_scnv_rec.scn_id := l_new_scn_id;
        ELSE
            l_scnv_rec.scn_id := NULL;
        END IF;

        OKC_SECTIONS_PUB.create_section(
                                        p_api_version => p_api_version,
                                        p_init_msg_list => p_init_msg_list,
                                        x_return_status => l_return_status,
                                        x_msg_count => x_msg_count,
                                        x_msg_data => x_msg_data,
                                        p_scnv_rec => l_scnv_rec,
                                        x_scnv_rec => x_scnv_rec);

        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

        x_scn_id := x_scnv_rec.id;

        add_sections(p_scn_id, x_scnv_rec.id); --adds the new section id in the global PL/SQL table.

    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
            NULL;
        WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
        -- notify caller of an UNEXPECTED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END copy_section;

    BEGIN

        x_return_status := l_return_status;

        OPEN c_scc;
        FETCH c_scc INTO l_scn_id;
        CLOSE c_scc;

        FOR l_c_scn IN c_scn(l_scn_id) LOOP
            l_sec(l_c_scn.LEVEL).scn_id := l_c_scn.id;
            l_scn_count := l_c_scn.LEVEL;
        END LOOP;

        FOR i IN REVERSE 1 .. l_scn_count LOOP
            copy_section (
                          p_api_version => p_api_version,
                          p_init_msg_list => p_init_msg_list,
                          x_return_status => l_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data,
                          p_scn_id => l_sec(i).scn_id,
                          p_to_chr_id => p_to_chr_id,
                          x_scn_id => l_scn_id_out);

            IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                x_return_status := l_return_status;
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
        END LOOP;


        l_return_status := get_sccv_rec(p_scc_id => p_scc_id,
                                        x_sccv_rec => l_sccv_rec);

        IF get_new_scn_id(l_scn_id, l_scn_id_new) THEN
            l_sccv_rec.scn_id := l_scn_id_new;
        ELSE
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

        l_sccv_rec.cat_id := p_to_cat_id;

        OKC_SECTIONS_PUB.create_section_content(
                                                p_api_version => p_api_version,
                                                p_init_msg_list => p_init_msg_list,
                                                x_return_status => l_return_status,
                                                x_msg_count => x_msg_count,
                                                x_msg_data => x_msg_data,
                                                p_sccv_rec => l_sccv_rec,
                                                x_sccv_rec => x_sccv_rec);

        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;


    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
            NULL;
        WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
      -- notify caller of an UNEXPECTED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END copy_sections;

  --------------------------------------------------------------------------
  --Proceudre copy_accesses - Makes a copy of the okc_k_accesses.
  --------------------------------------------------------------------------
    PROCEDURE copy_accesses(
                            p_api_version                  IN NUMBER,
                            p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                            x_return_status                OUT NOCOPY VARCHAR2,
                            x_msg_count                    OUT NOCOPY NUMBER,
                            x_msg_data                     OUT NOCOPY VARCHAR2,
                            p_from_chr_id                  IN NUMBER,
                            p_to_chr_id                    IN NUMBER) IS

    l_cacv_rec 	cacv_rec_type;
    x_cacv_rec 	cacv_rec_type;
    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    CURSOR 	c_access IS
        SELECT 	id
        FROM 	okc_k_accesses_v
        WHERE 	chr_id = p_from_chr_id;

    BEGIN
        x_return_status := l_return_status;
        FOR l_c_access IN c_access LOOP
            l_return_status := get_cacv_rec(p_cac_id => l_c_access.id,
                                            x_cacv_rec => l_cacv_rec);
            l_cacv_rec.chr_id := p_to_chr_id;

            OKC_CONTRACT_PUB.create_contract_access(
                                                    p_api_version => p_api_version,
                                                    p_init_msg_list => p_init_msg_list,
                                                    x_return_status => l_return_status,
                                                    x_msg_count => x_msg_count,
                                                    x_msg_data => x_msg_data,
                                                    p_cacv_rec => l_cacv_rec,
                                                    x_cacv_rec => x_cacv_rec);

            IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                    x_return_status := l_return_status;
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                ELSE
                    x_return_status := l_return_status;
                END IF;
            END IF;
        END LOOP;

    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
            NULL;
        WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
      -- notify caller of an UNEXPECTED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END copy_accesses;

  ----------------------------------------------------------------------------
  --Proceudre copy_processes - Makes a copy of the okc_k_processes.
  ----------------------------------------------------------------------------
    PROCEDURE copy_processes(
                             p_api_version                  IN NUMBER,
                             p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                             x_return_status                OUT NOCOPY VARCHAR2,
                             x_msg_count                    OUT NOCOPY NUMBER,
                             x_msg_data                     OUT NOCOPY VARCHAR2,
                             p_from_chr_id                  IN NUMBER,
                             p_to_chr_id                    IN NUMBER) IS

    l_cpsv_rec 	cpsv_rec_type;
    x_cpsv_rec 	cpsv_rec_type;
    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    CURSOR 	c_process IS
        SELECT 	id
        FROM 	okc_k_processes
        WHERE 	chr_id = p_from_chr_id;

    BEGIN
        x_return_status := l_return_status;
        FOR l_c_process IN c_process LOOP
            l_return_status := get_cpsv_rec(p_cps_id => l_c_process.id,
                                            x_cpsv_rec => l_cpsv_rec);
            l_cpsv_rec.chr_id := p_to_chr_id;
            l_cpsv_rec.process_id := NULL;

            OKC_CONTRACT_PUB.create_contract_process(
                                                     p_api_version => p_api_version,
                                                     p_init_msg_list => p_init_msg_list,
                                                     x_return_status => l_return_status,
                                                     x_msg_count => x_msg_count,
                                                     x_msg_data => x_msg_data,
                                                     p_cpsv_rec => l_cpsv_rec,
                                                     x_cpsv_rec => x_cpsv_rec);

            IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                    x_return_status := l_return_status;
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                ELSE
                    x_return_status := l_return_status;
                END IF;
            END IF;
        END LOOP;

    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
            NULL;
        WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
      -- notify caller of an UNEXPECTED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END copy_processes;

  ----------------------------------------------------------------------------
  --Proceudre copy_grpings - Makes a copy of the okc_k_grpings.
  ----------------------------------------------------------------------------
    PROCEDURE copy_grpings(
                           p_api_version                  IN NUMBER,
                           p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                           x_return_status                OUT NOCOPY VARCHAR2,
                           x_msg_count                    OUT NOCOPY NUMBER,
                           x_msg_data                     OUT NOCOPY VARCHAR2,
                           p_from_chr_id                  IN NUMBER,
                           p_to_chr_id                    IN NUMBER) IS

    l_cgcv_rec 	cgcv_rec_type;
    x_cgcv_rec 	cgcv_rec_type;
    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    CURSOR 	c_grpings IS
        SELECT 	cgcv.id
        FROM 	     okc_k_grpings_v cgcv,
                   okc_k_groups_b cgpv
        WHERE 	cgcv.included_chr_id = p_from_chr_id
        AND        cgcv.cgp_parent_id = cgpv.id
        AND        (cgpv.public_yn = 'Y' OR cgpv.user_id = fnd_global.user_id);

    BEGIN
        x_return_status := l_return_status;
        FOR l_c_grpings IN c_grpings LOOP
            l_return_status := get_cgcv_rec(p_cgc_id => l_c_grpings.id,
                                            x_cgcv_rec => l_cgcv_rec);
            l_cgcv_rec.included_chr_id := p_to_chr_id;

            OKC_CONTRACT_GROUP_PUB.create_contract_grpngs(
                                                          p_api_version => p_api_version,
                                                          p_init_msg_list => p_init_msg_list,
                                                          x_return_status => l_return_status,
                                                          x_msg_count => x_msg_count,
                                                          x_msg_data => x_msg_data,
                                                          p_cgcv_rec => l_cgcv_rec,
                                                          x_cgcv_rec => x_cgcv_rec);

            IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                    x_return_status := l_return_status;
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                ELSE
                    x_return_status := l_return_status;
                END IF;
            END IF;
        END LOOP;

    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
            NULL;
        WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
      -- notify caller of an UNEXPECTED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END copy_grpings;

  --------------------------------------------------------------------------
  --Proceudre copy_governances - Makes a copy of the okc_governances.
  --------------------------------------------------------------------------
    PROCEDURE copy_governances(
                               p_api_version                  IN NUMBER,
                               p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                               x_return_status                OUT NOCOPY VARCHAR2,
                               x_msg_count                    OUT NOCOPY NUMBER,
                               x_msg_data                     OUT NOCOPY VARCHAR2,
                               p_from_chr_id                  IN NUMBER,
                               p_to_chr_id                    IN NUMBER) IS

    l_gvev_rec 	gvev_rec_type;
    x_gvev_rec 	gvev_rec_type;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    CURSOR 	c_governances IS
        SELECT 	id
        FROM 		okc_governances
        WHERE 	dnz_chr_id = p_from_chr_id
        AND		cle_id IS NULL;

  ----------------------------------------------------------------------------
  --Function to populate the contract governance record to be copied.
  ----------------------------------------------------------------------------
    FUNCTION get_gvev_rec(p_gve_id IN NUMBER,
                          x_gvev_rec OUT NOCOPY gvev_rec_type)
    RETURN  VARCHAR2 IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_no_data_found BOOLEAN := TRUE;

    CURSOR c_gvev_rec IS
        SELECT
          DNZ_CHR_ID,
          ISA_AGREEMENT_ID,
          CHR_ID,
          CLE_ID,
          CHR_ID_REFERRED,
          CLE_ID_REFERRED,
          COPIED_ONLY_YN
       FROM    OKC_GOVERNANCES
       WHERE 	ID = p_gve_id;
    BEGIN
        OPEN c_gvev_rec;
        FETCH c_gvev_rec
        INTO x_gvev_rec.DNZ_CHR_ID,
        x_gvev_rec.ISA_AGREEMENT_ID,
        x_gvev_rec.CHR_ID,
        x_gvev_rec.CLE_ID,
        x_gvev_rec.CHR_ID_REFERRED,
        x_gvev_rec.CLE_ID_REFERRED,
        x_gvev_rec.COPIED_ONLY_YN;

        l_no_data_found := c_gvev_rec%NOTFOUND;
        CLOSE c_gvev_rec;
        IF l_no_data_found THEN
            l_return_status := OKC_API.G_RET_STS_ERROR;
            RETURN(l_return_status);
        ELSE
            RETURN(l_return_status);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
        -- notify caller of an UNEXPECTED error
            l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            RETURN(l_return_status);

    END get_gvev_rec;
    BEGIN
        x_return_status := l_return_status;
        FOR l_c_governances IN c_governances LOOP
            l_return_status := get_gvev_rec(p_gve_id => l_c_governances.id,
                                            x_gvev_rec => l_gvev_rec);
            l_gvev_rec.chr_id := p_to_chr_id;
            l_gvev_rec.dnz_chr_id := p_to_chr_id;

            OKC_CONTRACT_PUB.create_governance(
                                               p_api_version => p_api_version,
                                               p_init_msg_list => p_init_msg_list,
                                               x_return_status => l_return_status,
                                               x_msg_count => x_msg_count,
                                               x_msg_data => x_msg_data,
                                               p_gvev_rec => l_gvev_rec,
                                               x_gvev_rec => x_gvev_rec);

            IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                    x_return_status := l_return_status;
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                ELSE
                    x_return_status := l_return_status;
                END IF;
            END IF;
        END LOOP;

    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
            NULL;
        WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
      -- notify caller of an UNEXPECTED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END copy_governances;
 ----------------------------------------------------------------------------
  --Proceudre copy_articles - Makes a copy of the articles.
  ----------------------------------------------------------------------------
    PROCEDURE copy_articles(
                            p_api_version                  IN NUMBER,
                            p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                            x_return_status                OUT NOCOPY VARCHAR2,
                            x_msg_count                    OUT NOCOPY NUMBER,
                            x_msg_data                     OUT NOCOPY VARCHAR2,
                            p_cat_id                  	   IN NUMBER,
                            p_cle_id                       IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
                            p_chr_id                       IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
                            x_cat_id		           OUT NOCOPY NUMBER) IS

    l_catv_rec 	catv_rec_type;
    x_catv_rec 	catv_rec_type;
    l_atnv_rec 	atnv_rec_type;
    x_atnv_rec 	atnv_rec_type;

    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cle_id			NUMBER := OKC_API.G_MISS_NUM;
    l_new_rul_id			NUMBER := OKC_API.G_MISS_NUM;

    CURSOR c_dnz_chr_id(p_id IN NUMBER) IS
        SELECT dnz_chr_id
        FROM okc_k_lines_b
        WHERE id = p_id;

    CURSOR c_atn(p_id IN NUMBER) IS
        SELECT id
        FROM   okc_article_trans
        WHERE  cat_id = p_id;

    CURSOR c_scc IS
        SELECT id
        FROM   okc_section_contents
        WHERE  cat_id = p_cat_id;

    BEGIN
        x_return_status := l_return_status;
        l_return_status := get_catv_rec(p_cat_id => p_cat_id,
                                        x_catv_rec => l_catv_rec);

        IF p_chr_id IS NULL OR p_chr_id = OKC_API.G_MISS_NUM THEN
            OPEN c_dnz_chr_id(p_cle_id);
            FETCH c_dnz_chr_id INTO l_catv_rec.dnz_chr_id;
            CLOSE c_dnz_chr_id;
        ELSE
            l_catv_rec.dnz_chr_id := p_chr_id;
        END IF;

        l_catv_rec.chr_id := p_chr_id;
        l_catv_rec.cle_id := p_cle_id;

        OKC_K_ARTICLE_PUB.create_k_article(
                                           p_api_version => p_api_version,
                                           p_init_msg_list => p_init_msg_list,
                                           x_return_status => l_return_status,
                                           x_msg_count => x_msg_count,
                                           x_msg_data => x_msg_data,
                                           p_catv_rec => l_catv_rec,
                                           x_catv_rec => x_catv_rec);

        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
                RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
                x_return_status := l_return_status;
            END IF;
        END IF;

        FOR l_c_atn IN c_atn(l_catv_rec.id)
            LOOP
            l_return_status := get_atnv_rec(p_atn_id => l_c_atn.id,
                                            x_atnv_rec => l_atnv_rec);
            l_atnv_rec.rul_id := l_new_rul_id;
            l_atnv_rec.cat_id := x_catv_rec.id;
            l_atnv_rec.dnz_chr_id := x_catv_rec.dnz_chr_id;

            OKC_K_ARTICLE_PUB.create_article_translation(
                                                         p_api_version => p_api_version,
                                                         p_init_msg_list => p_init_msg_list,
                                                         x_return_status => l_return_status,
                                                         x_msg_count => x_msg_count,
                                                         x_msg_data => x_msg_data,
                                                         p_atnv_rec => l_atnv_rec,
                                                         x_atnv_rec => x_atnv_rec);

            IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                    x_return_status := l_return_status;
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                ELSE
                    x_return_status := l_return_status;
                END IF;
            END IF;

    --  END IF;
        END LOOP;

        x_cat_id := x_catv_rec.id; -- passes the new generated id to the caller.

        FOR l_c_scc IN c_scc LOOP
            copy_sections (
                           p_api_version => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_return_status => l_return_status,
                           x_msg_count => x_msg_count,
                           x_msg_data => x_msg_data,
                           p_scc_id => l_c_scc.id,
                           p_to_cat_id => x_catv_rec.id,
                           p_to_chr_id => x_catv_rec.dnz_chr_id);

            IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                x_return_status := l_return_status;
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
        END LOOP;

    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
            NULL;
        WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
      -- notify caller of an UNEXPECTED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END copy_articles;



  ----------------------------------------------------------------------------
  --Proceudre copy_price_att_values - Makes a copy of the price attribute values.
  ----------------------------------------------------------------------------
    PROCEDURE copy_price_att_values(
                                    p_api_version                  IN NUMBER,
                                    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                    x_return_status                OUT NOCOPY VARCHAR2,
                                    x_msg_count                    OUT NOCOPY NUMBER,
                                    x_msg_data                     OUT NOCOPY VARCHAR2,
                                    p_pav_id                  	   IN NUMBER,
                                    p_cle_id                       IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
                                    p_chr_id                       IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
                                    x_pav_id		           OUT NOCOPY NUMBER) IS

    l_pavv_rec 	pavv_rec_type;
    x_pavv_rec 	pavv_rec_type;

    l_return_status	    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cle_id			NUMBER := OKC_API.G_MISS_NUM;

    BEGIN
        x_return_status := l_return_status;
        l_return_status := get_pavv_rec(p_pav_id => p_pav_id,
                                        x_pavv_rec => l_pavv_rec);

        l_pavv_rec.chr_id := p_chr_id;
        l_pavv_rec.cle_id := p_cle_id;

        OKC_PRICE_ADJUSTMENT_PUB.create_price_att_value(
                                                        p_api_version => p_api_version,
                                                        p_init_msg_list => p_init_msg_list,
                                                        x_return_status => l_return_status,
                                                        x_msg_count => x_msg_count,
                                                        x_msg_data => x_msg_data,
                                                        p_pavv_rec => l_pavv_rec,
                                                        x_pavv_rec => x_pavv_rec);

        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
                RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
                x_return_status := l_return_status;
            END IF;
        END IF;

        x_pav_id := x_pavv_rec.id; -- passes the new generated id to the caller.

    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
            NULL;
        WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
      -- notify caller of an UNEXPECTED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END copy_price_att_values;

  ----------------------------------------------------------------------------
  --Proceudre copy_party_roles - Makes a copy of the party_roles.
  ----------------------------------------------------------------------------
    PROCEDURE copy_party_roles(
                               p_api_version                  IN NUMBER,
                               p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                               x_return_status                OUT NOCOPY VARCHAR2,
                               x_msg_count                    OUT NOCOPY NUMBER,
                               x_msg_data                     OUT NOCOPY VARCHAR2,
                               p_cpl_id                  	   IN NUMBER,
                               p_cle_id                       IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
                               p_chr_id                       IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
                               P_rle_code                     IN VARCHAR2,
                               x_cpl_id		           OUT NOCOPY NUMBER) IS

    l_cplv_rec 	cplv_rec_type;
    x_cplv_rec 	cplv_rec_type;
    l_ctcv_rec 	ctcv_rec_type;
    x_ctcv_rec 	ctcv_rec_type;

    l_party_name                VARCHAR2(200);
    l_party_desc                VARCHAR2(2000);
    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cle_id			NUMBER := OKC_API.G_MISS_NUM;

    CURSOR c_dnz_chr_id(p_id IN NUMBER) IS
        SELECT dnz_chr_id
        FROM okc_k_lines_b
        WHERE id = p_id;

    CURSOR c_ctcv IS
        SELECT id
        FROM okc_contacts
        WHERE cpl_id = p_cpl_id;

    BEGIN
        x_return_status := l_return_status;
        l_return_status := get_cplv_rec(p_cpl_id => p_cpl_id,
                                        x_cplv_rec => l_cplv_rec);

        IF p_chr_id IS NULL OR p_chr_id = OKC_API.G_MISS_NUM THEN
            OPEN c_dnz_chr_id(p_cle_id);
            FETCH c_dnz_chr_id INTO l_cplv_rec.dnz_chr_id;
            CLOSE c_dnz_chr_id;
        ELSE
            l_cplv_rec.dnz_chr_id := p_chr_id;
        END IF;

        l_cplv_rec.chr_id := p_chr_id;
        l_cplv_rec.cle_id := p_cle_id;
        IF p_rle_code IS NOT NULL THEN
            l_cplv_rec.rle_code := p_rle_code;
        END IF;

        OKC_CONTRACT_PARTY_PUB.create_k_party_role(
                                                   p_api_version => p_api_version,
                                                   p_init_msg_list => p_init_msg_list,
                                                   x_return_status => l_return_status,
                                                   x_msg_count => x_msg_count,
                                                   x_msg_data => x_msg_data,
                                                   p_cplv_rec => l_cplv_rec,
                                                   x_cplv_rec => x_cplv_rec);

        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

        x_cpl_id := x_cplv_rec.id; -- passes the new generated id to the caller.

     --stores the new rul_id in a global pl/sql table.
        add_party(l_cplv_rec.id, x_cplv_rec.id);


        FOR l_c_ctcv IN c_ctcv LOOP
            l_return_status := get_ctcv_rec(p_ctc_id => l_c_ctcv.id,
                                            x_ctcv_rec => l_ctcv_rec);

            l_ctcv_rec.dnz_chr_id := l_cplv_rec.dnz_chr_id;
            l_ctcv_rec.cpl_id := x_cplv_rec.id;

            OKC_CONTRACT_PARTY_PUB.create_contact(
                p_api_version => p_api_version,
                p_init_msg_list => p_init_msg_list,
                x_return_status => l_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data,
                p_ctcv_rec => l_ctcv_rec,
                x_ctcv_rec => x_ctcv_rec);

            IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                    x_return_status := l_return_status;
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                ELSE
                    x_return_status := OKC_API.G_RET_STS_WARNING;
                    okc_util.get_name_desc_from_jtfv(
                        p_object_code => x_cplv_rec.jtot_object1_code,
                        p_id1 => x_cplv_rec.object1_id1,
                        p_id2 => x_cplv_rec.object1_id2,
                        x_name => l_party_name,
                        x_description => l_party_desc);

                    OKC_API.set_message(G_APP_NAME, 'OKC_CONTACT_NOT_COPIED', 'PARTY_NAME', l_party_name);
                END IF;
            END IF;
        END LOOP;

    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
            NULL;
        WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
      -- notify caller of an UNEXPECTED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END copy_party_roles;

  ----------------------------------------------------------------------------
  --Proceudre copy_rules - Makes a copy of all the rules for a given line
  --parameters :
  --            p_old_cle_id => for old okc line id being renewed
  --            p_cle_id     => id for new created okc line
  --            p_chr_id     => contract header id
  ----------------------------------------------------------------------------
    PROCEDURE copy_rules(
                         p_api_version                  IN NUMBER,
                         p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                         x_return_status                OUT NOCOPY VARCHAR2,
                         x_msg_count                    OUT NOCOPY NUMBER,
                         x_msg_data                     OUT NOCOPY VARCHAR2,
                         p_old_cle_id                   IN NUMBER,
                         p_cle_id                       IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
                         p_chr_id                       IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
                         p_cust_acct_id                 IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
                         p_bill_to_site_use_id          IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
                         p_to_template_yn			   IN VARCHAR2) IS

    l_api_name CONSTANT VARCHAR2(30) := 'COPY_RULES';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PROGRAM_NAME || '.' || l_api_name;

    l_klnv_rec 	klnv_rec_type;
    x_klnv_rec 	klnv_rec_type;

    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dnz_chr_id            NUMBER;
    l_trx_ext_id            NUMBER;

    CURSOR c_dnz_chr_id(p_id IN NUMBER) IS
        SELECT dnz_chr_id
        FROM okc_k_lines_b
        WHERE id = p_id;

   -- bug 5139719
    CURSOR cur_hdr_uom IS
      SELECT price_uom
        FROM oks_k_headers_b
       WHERE chr_id = p_chr_id;

    l_price_uom   oks_k_headers_b.price_uom%TYPE;
   -- end added bug 5139719

    BEGIN

        IF(FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.begin','p_old_cle_id='||p_old_cle_id||' ,p_cle_id='||p_cle_id||' ,p_chr_id='||p_chr_id);
        END IF;

        x_return_status := l_return_status;
        IF FND_API.to_boolean(p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        IF p_chr_id IS NULL OR p_chr_id = OKC_API.G_MISS_NUM THEN
            OPEN c_dnz_chr_id(p_cle_id);
            FETCH c_dnz_chr_id INTO l_dnz_chr_id;
            CLOSE c_dnz_chr_id;
        ELSE
            l_dnz_chr_id := p_chr_id;
        END IF;

        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.get_line_details', 'calling get_klnv_rec' );
        END IF;

        l_return_status := get_klnv_rec(
            p_old_cle_id => p_old_cle_id,
            x_klnv_rec => l_klnv_rec);

        l_klnv_rec.cle_id := p_cle_id;
        l_klnv_rec.dnz_chr_id := l_dnz_chr_id;
        l_klnv_rec.orig_system_id1 := l_klnv_rec.id;
        l_klnv_rec.orig_system_reference1 := 'COPY';
        l_klnv_rec.orig_system_source_code := 'OKC_LINE';
        l_klnv_rec.cust_po_number := NULL; -- null out payment instructions
        l_klnv_rec.cust_po_number_req_yn := NULL;

        -- bug 5139719
          OPEN cur_hdr_uom;
            FETCH cur_hdr_uom INTO l_price_uom;
          CLOSE cur_hdr_uom;
        l_klnv_rec.price_uom := l_price_uom;
        -- end added bug 5139719

        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.create_oks_line', 'calling OKS_CONTRACT_LINE_PUB.create_line' );
        END IF;

        OKS_CONTRACT_LINE_PUB.create_line(
            p_api_version => 1.0,
            p_init_msg_list => OKC_API.G_FALSE,
            x_return_status => l_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            p_klnv_rec => l_klnv_rec,
            x_klnv_rec => x_klnv_rec,
            p_validate_yn => 'N');

        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.create_oks_line', 'after call to OKS_CONTRACT_LINE_PUB.create_line, l_return_status='||l_return_status);
        END IF;

        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
            x_return_status := l_return_status;
        END IF;

        --add call to copy trxn_extension_id
        IF (l_klnv_rec.trxn_extension_id IS NOT NULL) THEN

            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.copy_cc', 'calling  create_tansaction_extension, p_order_id='||p_cle_id||' ,p_old_trx_ext_id='||l_klnv_rec.trxn_extension_id||
                ' ,p_cust_acct_id='||p_cust_acct_id||' ,p_bill_to_site_use_id='||p_bill_to_site_use_id);
            END IF;

            create_trxn_extn(
                p_api_version => 1.0,
                p_init_msg_list => OKC_API.G_FALSE,
                x_return_status => l_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data,
                p_old_trx_ext_id => l_klnv_rec.trxn_extension_id,
                p_order_id =>  p_cle_id,
                p_cust_acct_id => p_cust_acct_id,
                p_bill_to_site_use_id => p_bill_to_site_use_id,
                x_trx_ext_id => l_trx_ext_id);

            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.copy_cc', 'after call to  create_tansaction_extension, x_return_status='||l_return_status||' ,x_trx_ext_id='||l_trx_ext_id);
            END IF;

            IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                x_return_status := l_return_status;
                RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
                x_return_status := l_return_status;
            END IF;

            UPDATE oks_k_lines_b SET
                trxn_extension_id = l_trx_ext_id
                WHERE cle_id = p_cle_id;

        END IF;

        IF(FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.end','x_return_status='||x_return_status);
        END IF;

    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
            NULL;
        WHEN OTHERS THEN
            -- store SQL error message on message stack for caller
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
            -- notify caller of an UNEXPECTED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

            IF(FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name||'.end_other_error','x_return_status='||x_return_status);
            END IF;

    END copy_rules;

  ----------------------------------------------------------------------------
  --Proceudre copy_items
  ----------------------------------------------------------------------------
    PROCEDURE copy_items(
                         p_api_version                  IN NUMBER,
                         p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                         x_return_status                OUT NOCOPY VARCHAR2,
                         x_msg_count                    OUT NOCOPY NUMBER,
                         x_msg_data                     OUT NOCOPY VARCHAR2,
                         p_from_cle_id                  IN NUMBER,
                         p_copy_reference               IN VARCHAR2 DEFAULT 'COPY',
                         p_to_cle_id                    IN NUMBER DEFAULT OKC_API.G_MISS_NUM) IS

    l_api_name CONSTANT VARCHAR2(30) := 'COPY_ITEMS';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PROGRAM_NAME || '.' || l_api_name;

    l_cimv_rec 	cimv_rec_type;
    x_cimv_rec 	cimv_rec_type;

    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dnz_chr_id		NUMBER := OKC_API.G_MISS_NUM;
    l_price_level_ind   VARCHAR2(20);
    l_item_name         VARCHAR2(2000);
    l_item_desc         VARCHAR2(2000);

    CURSOR c_dnz_chr_id IS
        SELECT dnz_chr_id, price_level_ind
        FROM okc_k_lines_b
        WHERE id = p_to_cle_id;

    CURSOR c_cimv IS
        SELECT id
        FROM okc_k_items
        WHERE cle_id = p_from_cle_id;

    BEGIN

        IF(FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.begin', 'p_from_cle_id='||p_from_cle_id||' ,p_to_cle_id='||p_to_cle_id||' ,p_copy_reference='||p_copy_reference);
        END IF;

        x_return_status := l_return_status;
        IF FND_API.to_boolean(p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        OPEN c_dnz_chr_id;
        FETCH c_dnz_chr_id INTO l_dnz_chr_id, l_price_level_ind;
        CLOSE c_dnz_chr_id;

        FOR l_c_cimv IN c_cimv LOOP
            l_return_status := get_cimv_rec(p_cim_id => l_c_cimv.id,
                                            x_cimv_rec => l_cimv_rec);

            l_cimv_rec.cle_id := p_to_cle_id;
            l_cimv_rec.dnz_chr_id := l_dnz_chr_id;

            IF p_copy_reference = 'REFERENCE' THEN
                l_cimv_rec.cle_id_for := p_from_cle_id;
                l_cimv_rec.chr_id := NULL;
            ELSE
                l_cimv_rec.cle_id_for := NULL;
            END IF;

            IF l_price_level_ind = 'N' THEN
                l_cimv_rec.priced_item_yn := 'N';
            END IF;


            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.item_details','l_dnz_chr_id='|| l_dnz_chr_id||' ,object1_id1='||l_cimv_rec.OBJECT1_ID1||' ,object1_id2='||l_cimv_rec.OBJECT1_ID2||
                ' ,jtot_object1_code='||l_cimv_rec.JTOT_OBJECT1_CODE||' ,uom_code='|| l_cimv_rec.UOM_CODE||' ,exception_yn='||l_cimv_rec.EXCEPTION_YN||' ,number_of_items='||l_cimv_rec.NUMBER_OF_ITEMS||' ,priced_item_yn='||l_cimv_rec.PRICED_ITEM_YN);
            END IF;

            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.create_item','calling OKC_CONTRACT_ITEM_PUB.create_contract_item');
            END IF;

            OKC_CONTRACT_ITEM_PUB.create_contract_item(
                p_api_version => p_api_version,
                p_init_msg_list => OKC_API.G_FALSE,
                x_return_status => l_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data,
                p_cimv_rec => l_cimv_rec,
                x_cimv_rec => x_cimv_rec);

            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.create_item','after call to OKC_CONTRACT_ITEM_PUB.create_contract_item, l_return_status='||l_return_status);
            END IF;

            x_return_status := l_return_status;
            IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                    x_return_status := l_return_status;
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                ELSE
                    okc_util.get_name_desc_from_jtfv(p_object_code => l_cimv_rec.jtot_object1_code,
                                                     p_id1 => l_cimv_rec.object1_id1,
                                                     p_id2 => l_cimv_rec.object1_id2,
                                                     x_name => l_item_name,
                                                     x_description => l_item_desc);

                    IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.create_item_error','okc_util.get_name_desc_from_jtfv l_item_name='|| l_item_name);
                    END IF;

                    OKC_API.set_message(G_APP_NAME, 'OKC_ITEM_NOT_COPIED', 'ITEM_NAME', l_item_name);

                    x_return_status := l_return_status;

                END IF;
            END IF;
        END LOOP;

        IF(FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.end','x_return_status='||x_return_status);
        END IF;

    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
            NULL;
        WHEN OTHERS THEN
            -- store SQL error message on message stack for caller
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
            -- notify caller of an UNEXPECTED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

            IF(FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name||'.end_other_error','x_return_status='||x_return_status);
            END IF;

    END copy_items;

  --
  -- Procedure to set attachement session variables if they are null
  -- Currently set only set for OKCAUDET and OKSAUDET
  --
  -- If want to get rid of this hard coding, COPY should add
  -- parameters and user should pass attachement_funtion_name
  -- and attachment_funtion_type
  --
    PROCEDURE Set_Attach_Session_Vars(p_chr_id NUMBER) IS
    l_app_id NUMBER;
    CURSOR l_chr_csr IS
        SELECT application_id
        FROM okc_k_headers_b
        WHERE id = p_chr_id;
    BEGIN
        IF (p_chr_id IS NOT NULL AND
            FND_ATTACHMENT_UTIL_PKG.function_name IS NULL
            )
            THEN
            OPEN l_chr_csr;
            FETCH l_chr_csr INTO l_app_id;
            CLOSE l_chr_csr;
            IF (l_app_id = 510) THEN
                FND_ATTACHMENT_UTIL_PKG.function_name := 'OKCAUDET';
                FND_ATTACHMENT_UTIL_PKG.function_type := 'O';
            ELSIF (l_app_id = 515) THEN
                FND_ATTACHMENT_UTIL_PKG.function_name := 'OKSAUDET';
                FND_ATTACHMENT_UTIL_PKG.function_type := 'O';
            END IF;
        END IF;
    END;

  ----------------------------------------------------------------------------
  -- Function to return the major version of the contract
  -- Major version is required to while copying attachments for
  -- header and line
  ----------------------------------------------------------------------------
    FUNCTION Get_Major_Version(p_chr_id NUMBER) RETURN VARCHAR2 IS

    CURSOR l_cvm_csr IS
        SELECT to_char(major_version)
        FROM okc_k_vers_numbers
        WHERE chr_id = p_chr_id;

    x_from_version  FND_ATTACHED_DOCUMENTS.PK2_VALUE%TYPE := NULL;

    BEGIN
        OPEN l_cvm_csr;
        FETCH l_cvm_csr INTO x_from_version;
        CLOSE l_cvm_csr;

        RETURN x_from_version;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN OKC_API.G_RET_STS_UNEXP_ERROR;

    END Get_Major_Version;

  ----------------------------------------------------------------------------
  -- Proceudre copy_contract_line will copy all the attributes of line i.e, rules
  -- articles, counters etc.Will copy every attr. of old line to new line
  -- Parameters :
  --        p_from_cle_id => old line id
  --        p_from_chr_id => old header id
  --        p_to_cle_id   => new line id
  --        p_to_chr_id   => new header id

  ----------------------------------------------------------------------------
    PROCEDURE copy_contract_line(
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_from_cle_id                  IN NUMBER,
        p_from_chr_id                  IN NUMBER,
        p_to_cle_id                    IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
        p_to_chr_id                    IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
        p_lse_id                       IN NUMBER,
        p_to_template_yn               IN VARCHAR2,
        p_copy_reference               IN VARCHAR2 DEFAULT 'COPY',
        p_copy_line_party_yn           IN VARCHAR2,
        p_renew_ref_yn                 IN VARCHAR2,
        p_need_conversion              IN VARCHAR2 DEFAULT 'N',
        x_cle_id		               OUT NOCOPY NUMBER)
    IS

    l_api_name      CONSTANT VARCHAR2(30) := 'COPY_CONTRACT_LINE';
    l_api_version   CONSTANT NUMBER := 1.0;
    l_mod_name      VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PROGRAM_NAME || '.' || l_api_name;
    l_error_text    VARCHAR2(512);

    l_clev_rec 	    clev_rec_type;
    x_clev_rec 	    clev_rec_type;

    l_sts_code      VARCHAR2(30);
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_old_return_status	    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cle_id		NUMBER := OKC_API.G_MISS_NUM;
    l_rgp_id		NUMBER;
    l_cat_id		NUMBER;
    l_pav_id		NUMBER;
    l_cpl_id		NUMBER;
    l_start_date    DATE;
    l_end_date      DATE;
    l_old_lse_id	NUMBER;


    CURSOR c_dnz_chr_id IS
        SELECT dnz_chr_id
        FROM okc_k_lines_b
        WHERE id = p_to_cle_id;

    CURSOR c_pavv IS
        SELECT id
        FROM okc_price_att_values
        WHERE cle_id = p_from_cle_id;

    -- Pkoganti 08/31, Bug 1392336
    -- Added rle_code <> 'LICENCEE_ACCT'
    -- When the user chooses to copy only the lines, the LICENCEE_ACCT
    -- party role should not be copied, because the target contract
    -- may not have the constraining party information.  This is a temp
    -- fix for GSR.
    --
    CURSOR c_cplv IS
        SELECT id
        FROM okc_k_party_roles_b
        WHERE cle_id = p_from_cle_id
        AND   rle_code <> 'LICENCEE_ACCT'
        AND   dnz_chr_id = p_from_chr_id;

        --------
        -- Procedure to get priced line information
        --------
        PROCEDURE get_priced_line_rec(px_clev_rec  IN OUT NOCOPY clev_rec_type) IS

        l_api_name CONSTANT VARCHAR2(50) := 'COPY_CONTRACT_LINE.GET_PRICED_LINE_REC';
        l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PROGRAM_NAME || '.' || l_api_name;

        l_priced_yn VARCHAR2(3);
        l_cim_id    NUMBER;
        l_lty_code  VARCHAR2(90);
        --l_clev_rec  clev_rec_type := px_clev_rec;
        l_cimv_rec 	cimv_rec_type;

        l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

        CURSOR c_lse(p_id IN NUMBER) IS
            SELECT lty_code,
                   priced_yn
            FROM   okc_line_styles_b
            WHERE  id = p_id;

        CURSOR c_cim(p_cle_id IN NUMBER) IS
            SELECT id
            FROM   okc_k_items
            WHERE  cle_id = p_cle_id
            AND    priced_item_yn = 'Y';

        BEGIN

            IF(FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.begin','begin');
            END IF;

            OPEN c_lse(px_clev_rec.lse_id);
            FETCH c_lse INTO l_lty_code, l_priced_yn;
            CLOSE c_lse;

            IF px_clev_rec.price_level_ind = 'N' THEN
                IF l_priced_yn = 'N' THEN
                    px_clev_rec.price_negotiated := NULL;
                ELSE
                    px_clev_rec.price_negotiated := NULL;
                    IF l_lty_code <> 'FREE_FORM' THEN
                        px_clev_rec.name := NULL;
                    END IF;
                END IF;
            ELSE
                IF l_priced_yn = 'N' THEN
                    px_clev_rec.price_negotiated := NULL;
                    px_clev_rec.PRICE_UNIT := NULL;
                    IF l_lty_code <> 'FREE_FORM' THEN
                        px_clev_rec.name := NULL;
                    END IF;
                ELSE
                    OPEN c_cim(l_clev_rec.id);
                    FETCH c_cim INTO l_cim_id;
                    CLOSE c_cim;

                    IF l_cim_id IS NOT NULL THEN
                        l_return_status := get_cimv_rec(p_cim_id => l_cim_id,
                                                        x_cimv_rec => l_cimv_rec);

                        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.validate_item','calling OKC_CONTRACT_ITEM_PUB.validate_contract_item');
                        END IF;

                        OKC_CONTRACT_ITEM_PUB.validate_contract_item(
                            p_api_version => 1.0,
                            p_init_msg_list => FND_API.G_FALSE,
                            x_return_status => l_return_status,
                            x_msg_count => x_msg_count,
                            x_msg_data => x_msg_data,
                            p_cimv_rec => l_cimv_rec);

                        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.validate_item','after call to OKC_CONTRACT_ITEM_PUB.validate_contract_item, x_return_status='||l_return_status);
                        END IF;

                        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                            px_clev_rec.price_negotiated := NULL;
                            px_clev_rec.PRICE_UNIT := NULL;
                            px_clev_rec.name := NULL;
                        END IF;
                    END IF;
                END IF;
            END IF;
            --x_clev_rec := l_clev_rec;

            IF(FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.end','l_return_status='||l_return_status);
            END IF;

        EXCEPTION
            WHEN OTHERS THEN
                --x_clev_rec := l_clev_rec;
                l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                    l_error_text := substr (SQLERRM, 1, 512);
                    FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                    FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
                END IF;

        END get_priced_line_rec;

        --------
        -- procedure to instantiate counter events for a given line
        --------

        PROCEDURE instantiate_counters_events (
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_old_cle_id     IN  NUMBER,
            p_old_lse_id     IN  NUMBER,
            p_start_date     IN  DATE,
            p_end_date       IN  DATE,
            p_new_cle_id     IN  NUMBER) IS

        l_api_name CONSTANT VARCHAR2(50) := 'COPY_CONTRACT_LINE.INSTANTIATE_COUNTERS_EVENTS';
        l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PROGRAM_NAME || '.' || l_api_name;

        l_item_id               VARCHAR2(40);
        l_standard_cov_yn       VARCHAR2(1);
        l_counter_grp_id	    NUMBER;
        l_found                 BOOLEAN;
        l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
        l_ctr_grp_id_template   NUMBER;
        l_ctr_grp_id_instance   NUMBER;
        l_instcnd_inp_rec       OKC_INST_CND_PUB.instcnd_inp_rec;
        l_actual_coverage_id NUMBER;

        CURSOR c_item IS
            SELECT a.object1_id1, b.standard_cov_yn
            FROM   okc_k_items a, oks_k_lines_b b
            WHERE  a.cle_id = p_old_cle_id
            AND b.cle_id = p_old_cle_id;

        CURSOR l_ctr_csr (p_id NUMBER) IS
            SELECT Counter_Group_id
            FROM   OKX_CTR_ASSOCIATIONS_V
            WHERE  Source_Object_Id = p_id;

        BEGIN

            IF(FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.begin','p_old_cle_id='||p_old_cle_id||' ,p_old_lse_id='||p_old_lse_id||' ,p_start_date='||p_start_date||' ,p_end_date='||p_end_date||' ,p_new_cle_id='||p_new_cle_id);
            END IF;

            x_return_status := l_return_status;
            OPEN c_item;
            FETCH c_item INTO l_item_id, l_standard_cov_yn;
            CLOSE c_item;

            IF l_item_id IS NOT NULL AND Is_Number(l_item_id) THEN

                -- Check whether counters are attached to the item
                OPEN l_ctr_csr(l_item_id);
                FETCH l_ctr_csr INTO l_counter_grp_id;
                l_found := l_ctr_csr%FOUND;
                CLOSE l_ctr_csr;


                IF (l_found) THEN -- if counter attachted, instantiate it

                    IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.inst_ctrs', 'Calling CS_COUNTERS_PUB.autoinstantiate_counters, p_source_object_id_template='||l_item_id||
                        ' ,p_source_object_id_instance='||p_new_cle_id);
                    END IF;

                    CS_COUNTERS_PUB.autoinstantiate_counters(
                        p_api_version => 1.0,
                        p_init_msg_list => FND_API.G_FALSE,
                        x_return_status => l_return_status,
                        x_msg_count => x_msg_count,
                        x_msg_data => x_msg_data,
                        p_commit => FND_API.G_FALSE,
                        p_source_object_id_template => l_item_id,
                        p_source_object_id_instance => p_new_cle_id,
                        x_ctr_grp_id_template => l_ctr_grp_id_template,
                        x_ctr_grp_id_instance => l_ctr_grp_id_instance);

                    IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.inst_ctrs', 'After call to CS_COUNTERS_PUB.autoinstantiate_counters, x_return_status='||l_return_status||' ,x_ctr_grp_id_template='||l_ctr_grp_id_template||
                        ' ,x_ctr_grp_id_instance='||l_ctr_grp_id_instance);
                    END IF;

                    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                        x_return_status := l_return_status;
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;

                    l_instcnd_inp_rec.ins_ctr_grp_id := l_ctr_grp_id_instance;
                    l_instcnd_inp_rec.tmp_ctr_grp_id := l_ctr_grp_id_template;
                    l_instcnd_inp_rec.jtot_object_code := 'OKC_K_LINE';
                    l_instcnd_inp_rec.cle_id := p_new_cle_id;

                    IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.inst_cond', 'Calling OKC_INST_CND_PUB.inst_condition');
                    END IF;

                    OKC_INST_CND_PUB.inst_condition(
                        p_api_version => 1.0,
                        p_init_msg_list => FND_API.G_FALSE,
                        x_return_status => l_return_status,
                        x_msg_count => x_msg_count,
                        x_msg_data => x_msg_data,
                        p_instcnd_inp_rec => l_instcnd_inp_rec);

                    IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.inst_cond', 'After call to OKC_INST_CND_PUB.inst_condition, x_return_status='||l_return_status);
                    END IF;

                    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                        x_return_status := l_return_status;
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;

                END IF;
            END IF;


            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.chk_cov_type','p_old_lse_id='||p_old_lse_id||' ,l_standard_cov_yn='||l_standard_cov_yn);
            END IF;

            IF p_old_lse_id IN (1,19) THEN

                --Instantiate the coverage, if only if it's a non standard coverage
                IF (l_standard_cov_yn = 'N') THEN

                    IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.create_adj_cov','calling OKS_COVERAGES_PUB.create_adjusted_coverage, P_Source_contract_Line_Id='||p_old_cle_id||' ,P_Target_contract_Line_Id='||p_new_cle_id);
                    END IF;

                    OKS_COVERAGES_PUB.create_adjusted_coverage(
                        p_api_version => 1.0,
                        p_init_msg_list => FND_API.G_FALSE,
                        x_return_status => l_return_status,
                        x_msg_count => x_msg_count,
                        x_msg_data => x_msg_data,
                        P_Source_contract_Line_Id => p_old_cle_id,
                        P_Target_contract_Line_Id => p_new_cle_id,
                        x_Actual_coverage_id => l_actual_coverage_id);

                    IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.create_adj_cov','after call to OKS_COVERAGES_PUB.create_adjusted_coverage, x_return_status='||l_return_status||' ,x_Actual_coverage_id='||l_actual_coverage_id);
                    END IF;

                    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                        x_return_status := l_return_status;
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;

                    --update oks top line with the newly created non-std coverage
                    --the oks top line must be present before this can be done
                    UPDATE oks_k_lines_b SET
                        coverage_id = l_actual_coverage_id
                        WHERE cle_id = p_new_cle_id;
                END IF;


                --for both standard and non standard coverage, need to copy
                --coverage notes and pm schedules. These coverage entities are
                --associated to the topline and the not the coverage

                IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.create_cov_extn','calling OKS_COVERAGES_PVT.create_k_coverage_ext, p_src_line_id='||p_old_cle_id||' ,p_tgt_line_id='||p_new_cle_id);
                END IF;

                OKS_COVERAGES_PVT.create_k_coverage_ext(
                    p_api_version => 1.0,
                    p_init_msg_list => FND_API.G_FALSE,
                    x_return_status => l_return_status,
                    x_msg_count => x_msg_count,
                    x_msg_data => x_msg_data,
                    p_src_line_id => p_old_cle_id,
                    p_tgt_line_id => p_new_cle_id);

                IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.create_cov_extn','after call to OKS_COVERAGES_PVT.create_k_coverage_ext, x_return_status='||l_return_status);
                END IF;

                IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                    x_return_status := l_return_status;
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;

            END IF;

            IF(FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.end', 'x_return_status='||x_return_status);
            END IF;

        EXCEPTION
            WHEN G_EXCEPTION_HALT_VALIDATION THEN
                IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_error', 'x_return_status='||x_return_status);
                END IF;

            WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                    l_error_text := substr (SQLERRM, 1, 512);
                    FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                    FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
                END IF;

        END instantiate_counters_events;

        ------
        -- Function to get parent's start_date and end_date for child lines
        -- parameters :
        --        p_from_start_date => start date of old contract header/line
        --        p_from_end_date   => end date of old contract header/line
        --        p_to_cle_id       => id of the new line
        --        p_to_chr_id       => id of the new header
        --        x_start_date      => calculated start date for new lines
        --        x_end_date        => calculated end date fon new lines
        ------

        FUNCTION get_parent_date(
            p_from_start_date IN DATE,
            p_from_end_date   IN DATE,
            p_to_cle_id       IN NUMBER,
            p_to_chr_id       IN NUMBER,
            x_start_date      OUT NOCOPY DATE,
            x_end_date        OUT NOCOPY DATE) RETURN BOOLEAN IS

        l_api_name CONSTANT VARCHAR2(50) := 'COPY_CONTRACT_LINE.GET_PARENT_DATE';
        l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PROGRAM_NAME || '.' || l_api_name;

        l_parent_start_date      DATE;
        l_parent_end_date        DATE;

        CURSOR  c_cle IS
            SELECT  start_date, end_date
            FROM    okc_k_lines_b
            WHERE   id = p_to_cle_id;

        CURSOR  c_chr IS
            SELECT  start_date, end_date
            FROM    okc_k_headers_b
            WHERE   id = p_to_chr_id;

        BEGIN

            IF(FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.begin','p_from_start_date='||p_from_start_date||' ,p_from_end_date='||p_from_end_date||' ,p_to_cle_id='||p_to_cle_id||' ,p_to_chr_id='||p_to_chr_id);
            END IF;

            IF NOT (p_to_cle_id IS NULL OR p_to_cle_id = OKC_API.G_MISS_NUM) THEN
                OPEN c_cle;
                FETCH c_cle INTO l_parent_start_date, l_parent_end_date;
                CLOSE c_cle;
                x_start_date := p_from_end_date + 1;
                x_end_date := l_parent_end_date;
            ELSE
                OPEN c_chr;
                FETCH c_chr INTO l_parent_start_date, l_parent_end_date;
                CLOSE c_chr;
                x_start_date := p_from_end_date + 1;
                x_end_date := l_parent_end_date;
            END IF;

            IF(FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.end','x_start_date='||x_start_date||' ,x_end_date='||x_end_date);
            END IF;

            RETURN(TRUE);

        END get_parent_date;

       -------
       -- procedure for price conversion for renewed header
       -------

        PROCEDURE do_price_conversion (
            px_clev_rec IN OUT NOCOPY clev_rec_type,
            x_return_status OUT NOCOPY VARCHAR2) IS

        l_api_name CONSTANT VARCHAR2(50) := 'COPY_CONTRACT_LINE.DO_PRICE_CONVERSION';
        l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PROGRAM_NAME || '.' || l_api_name;

        CURSOR header_cur(p_cle_id IN NUMBER) IS
            SELECT id, currency_code
            FROM okc_k_headers_b
            WHERE id = (SELECT dnz_chr_id
                        FROM okc_k_lines_b
                        WHERE id = p_cle_id);

        l_hdr_id NUMBER;
        l_curr_code VARCHAR2(15);
        l_old_amount NUMBER;
        l_cvn_type VARCHAR2(30);
        l_cvn_date DATE;
        l_cvn_rate NUMBER;
        l_return_status VARCHAR2(20);

            ----
            -- procedure will get convertion details for a given header id
            ----
            PROCEDURE GET_CVN_DTLS(
                p_chr_id   IN  NUMBER,
                x_cvn_type OUT NOCOPY VARCHAR2,
                x_cvn_date OUT NOCOPY DATE,
                x_cvn_rate OUT NOCOPY NUMBER,
                x_return_status OUT NOCOPY VARCHAR2) IS

            CURSOR cvn_cur IS
                SELECT  CONVERSION_TYPE, CONVERSION_RATE, CONVERSION_RATE_DATE
                FROM okc_k_headers_b
                WHERE id = p_chr_id;
           /*
            cursor cvn_type_cur(p_id in varchar2) is
            select name
            from okx_conversion_types_v
            where id1 = p_id;
            */

            l_cvn_exists BOOLEAN := FALSE;
            l_cvn_type_exists BOOLEAN := FALSE;
            BEGIN
                x_return_status := OKC_API.G_RET_STS_SUCCESS;

                IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.GET_CVN_DTLS.begin', 'p_chr_id='||p_chr_id);
                END IF;

                FOR cvn_rec IN cvn_cur
                    LOOP
                    l_cvn_exists := TRUE;
                    x_cvn_rate := cvn_rec.CONVERSION_RATE;
                    x_cvn_date := to_date(cvn_rec.CONVERSION_RATE_DATE,'YYYY/MM/DD HH24:MI:SS');
                    x_cvn_type := cvn_rec.CONVERSION_TYPE;

                END LOOP;

                IF l_cvn_type_exists THEN
                    x_return_status := OKC_API.G_RET_STS_SUCCESS;
                ELSE
                    IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.GET_CVN_DTLS.cvn_type_chk','no cvn rule');
                    END IF;
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;

                IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.GET_CVN_DTLS.end', 'x_return_status='||x_return_status||' ,x_cvn_type='||x_cvn_type||' ,x_cvn_date='||x_cvn_date||' ,x_cvn_rate='||x_cvn_rate);
                END IF;

            EXCEPTION
                WHEN G_EXCEPTION_HALT_VALIDATION THEN
                    x_return_status := OKC_API.G_RET_STS_ERROR;
                    IF(FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level)THEN
                        FND_LOG.string(FND_LOG.level_unexpected, l_mod_name||'.GET_CVN_DTLS.end_error', 'x_return_status='||x_return_status);
                    END IF;
                WHEN OTHERS THEN
                    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                    IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                        l_error_text := substr (SQLERRM, 1, 512);
                        FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.GET_CVN_DTLS.end_other_error', l_error_text);
                        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
                    END IF;

            END GET_CVN_DTLS;

        BEGIN

            IF(FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.begin','p_from_cle_id='||p_from_cle_id);
            END IF;

            l_return_status := OKC_API.G_RET_STS_SUCCESS;

            OPEN header_cur(p_from_cle_id);
            l_old_amount := px_clev_rec.price_negotiated;
            FETCH header_cur INTO l_hdr_id, l_curr_code;

            get_cvn_dtls(
                p_chr_id => l_hdr_id,
                x_cvn_type => l_cvn_type,
                x_cvn_date => l_cvn_date,
                x_cvn_rate => l_cvn_rate,
                x_return_status => l_return_status);

            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.after_get_cvn_dtls','l_return_status='|| l_return_status);
            END IF;

            x_return_status := l_return_status;

            IF l_return_status = OKC_API.G_RET_STS_SUCCESS THEN

                IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.convert','Calling OKC_CURRENCY_API.convert_amount, p_from_currency='||l_curr_code||' ,p_to_currency=EUR ,p_conversion_date='||l_cvn_date||
                    ' ,p_conversion_type='||l_cvn_type||' ,p_amount='||l_old_amount);
                END IF;

                OKC_CURRENCY_API.convert_amount(
                    p_from_currency => l_curr_code,
                    p_to_currency => 'EUR',
                    p_conversion_date => l_cvn_date,
                    p_conversion_type => l_cvn_type,
                    p_amount => l_old_amount,
                    x_conversion_rate => l_cvn_rate,
                    x_converted_amount => px_clev_rec.price_negotiated);

                px_clev_rec.currency_code := 'EUR';

                IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.convert','after call to OKC_CURRENCY_API.convert_amount, x_conversion_rate='||l_cvn_rate||' ,x_converted_amount='||px_clev_rec.price_negotiated);
                END IF;

            END IF;

            IF(FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.end','x_return_status='||x_return_status);
            END IF;

        EXCEPTION

            WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                    l_error_text := substr (SQLERRM, 1, 512);
                    FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                    FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
                END IF;

        END do_price_conversion;

    BEGIN

        IF(FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.begin','p_from_cle_id='||p_from_cle_id||' ,p_from_chr_id='||p_from_chr_id||' ,p_to_cle_id='||p_to_cle_id||' ,p_to_chr_id='||p_to_chr_id||' ,p_lse_id='||p_lse_id||
            ' ,p_to_template_yn='||p_to_template_yn||' ,p_copy_reference='||p_copy_reference||' ,p_copy_line_party_yn='||p_copy_line_party_yn||' ,p_renew_ref_yn='||p_renew_ref_yn||' ,p_need_conversion='||p_need_conversion);
        END IF;

        --standard api initilization and checks
        SAVEPOINT copy_contract_line_PVT;
        IF NOT FND_API.compatible_api_call (l_api_version, p_api_version, l_api_name, G_PKG_NAME)THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        IF FND_API.to_boolean(p_init_msg_list) THEN
            FND_MSG_PUB.initialize;
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.get_clev_rec', 'Calling get_clev_rec p_cle_id='||p_from_cle_id);
        END IF;

        l_return_status := get_clev_rec(p_cle_id => p_from_cle_id,
                                        x_clev_rec => l_clev_rec);

        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.get_clev_rec', 'After get_clev_rec l_clev_rec.date_renewed='||l_clev_rec.date_renewed);
        END IF;

        --
        -- If copy called for renewal, do not copy renewed lines
        --
        IF p_renew_ref_yn = 'Y' AND l_clev_rec.date_renewed IS NOT NULL THEN
            RETURN;
        END IF;

        IF p_to_chr_id IS NULL OR p_to_chr_id = OKC_API.G_MISS_NUM THEN
            OPEN c_dnz_chr_id;
            FETCH c_dnz_chr_id INTO l_clev_rec.dnz_chr_id;
            CLOSE c_dnz_chr_id;
        ELSE
            l_clev_rec.dnz_chr_id := p_to_chr_id;
        END IF;

        DECLARE -- Added by Jacob K. on 09/07/01 for the line numbering functionality
        CURSOR c_toplinenum(p_id IN NUMBER) IS
            SELECT MAX(to_number(line_number))
            FROM okc_k_lines_b
            WHERE dnz_chr_id = p_id
            AND cle_id IS NULL;
        CURSOR c_sublinenum(p_id IN NUMBER) IS
            SELECT MAX(to_number(line_number))
            FROM okc_k_lines_b
            WHERE cle_id = p_id
            AND lse_id IN (7, 8, 9, 10, 11, 35, 25);
        BEGIN
            IF l_clev_rec.lse_id IN (1, 12, 14, 19) THEN
                OPEN c_toplinenum(l_clev_rec.dnz_chr_id);
                FETCH c_toplinenum INTO l_clev_rec.line_number;
                CLOSE c_toplinenum;
            ELSE
                OPEN c_sublinenum(p_to_cle_id);
                FETCH c_sublinenum INTO l_clev_rec.line_number;
                CLOSE c_sublinenum;
            END IF;
            l_clev_rec.line_number := nvl(l_clev_rec.line_number, 0) + 1;

        END; -- End of line numbering

        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.line_numbering', 'l_clev_rec.line_number='||l_clev_rec.line_number);
        END IF;

        l_clev_rec.payment_instruction_type := NULL; --null out the payment instructions
        l_clev_rec.orig_system_id1 := l_clev_rec.id;
        l_clev_rec.orig_system_reference1 := 'COPY';
        l_clev_rec.orig_system_source_code := 'OKC_LINE';

        l_clev_rec.cle_id := p_to_cle_id;
        l_clev_rec.chr_id := p_to_chr_id;
        l_clev_rec.trn_code := NULL;
        l_clev_rec.date_terminated := NULL;

        -- get status code for the line
        OKC_ASSENT_PUB.get_default_status(
            x_return_status => l_return_status,
            p_status_type => 'ENTERED',
            x_status_code => l_sts_code);

        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.default_status', 'after call to OKC_ASSENT_PUB.get_default_status, p_status_type=ENTERED, x_status_code='||l_sts_code);
        END IF;

        l_clev_rec.sts_code := l_sts_code;

        -- get parent date
        IF get_parent_date(p_from_start_date => l_clev_rec.start_date,
                           p_from_end_date => l_clev_rec.end_date,
                           p_to_cle_id => p_to_cle_id,
                           p_to_chr_id => p_to_chr_id,
                           x_start_date => l_start_date,
                           x_end_date => l_end_date) THEN
            -- If the line dates are not in between its parents date default to parent date.
            l_clev_rec.start_date := l_start_date;
            l_clev_rec.end_date := l_end_date;
        END IF;

        l_old_lse_id := l_clev_rec.lse_id;

        -- for renewal populate following fields
        IF p_renew_ref_yn = 'Y' THEN
            l_clev_rec.PRICE_NEGOTIATED_RENEWED := l_clev_rec.PRICE_NEGOTIATED;
            l_clev_rec.CURRENCY_CODE_RENEWED := l_clev_rec.CURRENCY_CODE;
        END IF;

        -- populate lse_id field with the parameter passed
        IF p_lse_id IS NOT NULL THEN
            l_clev_rec.lse_id := p_lse_id;
        END IF;

        -- for non top lines, the chr_id field should be null
        IF l_clev_rec.lse_id NOT IN (1, 12, 14, 19) THEN
            l_clev_rec.chr_id := NULL;
            l_clev_rec.cle_id := p_to_cle_id;
        END IF;

        get_priced_line_rec(l_clev_rec);

        -- For EURO CONVERSION
        -- Change for bug # 2455295
        IF p_need_conversion = 'Y' THEN
            IF (l_clev_rec.price_negotiated IS NULL OR
                l_clev_rec.price_negotiated = 0 ) THEN
                --- only change the currency code
                IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.curr_conv','price_negotiated is 0, only changing currency code to EUR');
                END IF;
                l_clev_rec.currency_code := 'EUR';
            ELSE

                IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.curr_conv','Calling do_price_conversion');
                END IF;
                do_price_conversion(l_clev_rec, l_return_status);

                IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.curr_conv','after call to do_price_conversion, l_return_status='||l_return_status);
                END IF;

                IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                    x_return_status := l_return_status;
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;
            END IF;
        END IF;
        -- For EURO CONVERSION

        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.create_okc_line','calling OKC_CONTRACT_PUB.create_contract_line, l_clev_rec: lse_id='||l_clev_rec.lse_id||
            ' ,start_date='||l_clev_rec.start_date||' ,end_date='||l_clev_rec.end_date||' ,cle_id='||l_clev_rec.cle_id||' ,dnz_chr_id='||l_clev_rec.dnz_chr_id);
        END IF;

        OKC_CONTRACT_PUB.create_contract_line(
            p_api_version => 1.0,
            p_init_msg_list => FND_API.G_FALSE,
            x_return_status => l_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            p_clev_rec => l_clev_rec,
            x_clev_rec => x_clev_rec);

        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.create_okc_line','after call to OKC_CONTRACT_PUB.create_contract_line, x_return_status='|| l_return_status||' ,x_clev_rec.id='||x_clev_rec.id);
        END IF;

        IF (l_return_status NOT IN (OKC_API.G_RET_STS_SUCCESS, OKC_API.G_RET_STS_WARNING)) THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
            IF (l_return_status = OKC_API.G_RET_STS_SUCCESS AND x_return_status =  OKC_API.G_RET_STS_WARNING) THEN
                NULL; --do not overwrite warning with success
            ELSE
                x_return_status := l_return_status;
            END IF;
        END IF;

        x_cle_id := x_clev_rec.id; -- passes the new generated id to the caller.

        --we need to create the oks line before creating non-std cov in the following call to
        --instantiate_counters_events
        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.create_oks_line','Calling copy_rules, p_old_cle_id='||p_from_cle_id||' ,p_cle_id='||x_clev_rec.id||' ,p_chr_id='||l_clev_rec.dnz_chr_id||' ,p_to_template_yn='||p_to_template_yn);
        END IF;

        copy_rules (
            p_api_version => 1.0,
            p_init_msg_list => FND_API.G_FALSE,
            x_return_status => l_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            p_old_cle_id => p_from_cle_id,
            p_cle_id => x_clev_rec.id,
            p_chr_id => l_clev_rec.dnz_chr_id,
            p_cust_acct_id => l_clev_rec.cust_acct_id,
            p_bill_to_site_use_id => l_clev_rec.bill_to_site_use_id,
            p_to_template_yn => p_to_template_yn);

        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.create_oks_line','after call to copy_rules, x_return_status='||l_return_status);
        END IF;

        IF (l_return_status NOT IN (OKC_API.G_RET_STS_SUCCESS, OKC_API.G_RET_STS_WARNING)) THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
            IF (l_return_status = OKC_API.G_RET_STS_SUCCESS AND x_return_status =  OKC_API.G_RET_STS_WARNING) THEN
                NULL; --do not overwrite warning with success
            ELSE
                x_return_status := l_return_status;
            END IF;
        END IF;

        -- instantiate counters
        IF l_clev_rec.lse_id IN (1, 14, 19) THEN

            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.instantiate_ctr_evts','Calling instantiate_counters_events, p_old_cle_id='||l_clev_rec.id||' ,p_old_lse_id='||l_old_lse_id||
                ' ,p_start_date='||x_clev_rec.start_date||' ,p_end_date='||x_clev_rec.end_date||' ,p_new_cle_id='||x_clev_rec.id);
            END IF;

            instantiate_counters_events(
                x_return_status => l_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data,
                p_old_cle_id => l_clev_rec.id,
                p_old_lse_id => l_old_lse_id,
                p_start_date => x_clev_rec.start_date,
                p_end_date => x_clev_rec.end_date,
                p_new_cle_id => x_clev_rec.id);

            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'instantiate_ctr_evts','after call to instantiate_counters_events, x_return_status='||l_return_status);
            END IF;

            IF (l_return_status NOT IN (OKC_API.G_RET_STS_SUCCESS, OKC_API.G_RET_STS_WARNING)) THEN
                x_return_status := l_return_status;
                RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
                IF (l_return_status = OKC_API.G_RET_STS_SUCCESS AND x_return_status =  OKC_API.G_RET_STS_WARNING) THEN
                    NULL; --do not overwrite warning with success
                ELSE
                    x_return_status := l_return_status;
                END IF;
            END IF;

        END IF;


        FOR l_c_pavv IN c_pavv LOOP

            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.price_att_values','Calling copy_price_att_values, p_pav_id='||l_c_pavv.id||' ,p_cle_id='||x_clev_rec.id||' ,p_chr_id=NULL');
            END IF;

            copy_price_att_values(
                p_api_version => 1.0,
                p_init_msg_list => FND_API.G_FALSE,
                x_return_status => l_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data,
                p_pav_id => l_c_pavv.id,
                p_cle_id => x_clev_rec.id,
                p_chr_id => NULL,
                x_pav_id => l_pav_id);

            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.price_att_values','after call to copy_price_att_values, x_return_status='||l_return_status||' ,x_pav_id='||l_pav_id);
            END IF;

            IF (l_return_status NOT IN (OKC_API.G_RET_STS_SUCCESS, OKC_API.G_RET_STS_WARNING)) THEN
                x_return_status := l_return_status;
                RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
                IF (l_return_status = OKC_API.G_RET_STS_SUCCESS AND x_return_status =  OKC_API.G_RET_STS_WARNING) THEN
                    NULL; --do not overwrite warning with success
                ELSE
                    x_return_status := l_return_status;
                END IF;
            END IF;

        END LOOP;


        FOR l_c_cplv IN c_cplv LOOP
            l_old_return_status := l_return_status;

            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.party_roles', 'Calling copy_party_roles, p_cpl_id='||l_c_cplv.id||' p_cle_id='||x_clev_rec.id||' ,p_chr_id=NULL ,p_rle_code=NULL');
            END IF;

            copy_party_roles(
                p_api_version => 1.0,
                p_init_msg_list => FND_API.G_FALSE,
                x_return_status => l_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data,
                p_cpl_id => l_c_cplv.id,
                p_cle_id => x_clev_rec.id,
                p_chr_id => NULL,
                p_rle_code => NULL,
                x_cpl_id => l_cpl_id);

            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.party_roles', 'after call to copy_party_roles, x_return_status='||l_return_status||' ,x_cpl_id='||l_cpl_id);
            END IF;

            IF (l_return_status NOT IN (OKC_API.G_RET_STS_SUCCESS, OKC_API.G_RET_STS_WARNING)) THEN
                x_return_status := l_return_status;
                RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
                IF (l_return_status = OKC_API.G_RET_STS_SUCCESS AND x_return_status =  OKC_API.G_RET_STS_WARNING) THEN
                    NULL; --do not overwrite warning with success
                ELSE
                    x_return_status := l_return_status;
                END IF;
            END IF;

        END LOOP;

        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.items', 'Calling copy_items, p_from_cle_id='||p_from_cle_id||' ,p_copy_reference='||p_copy_reference||' ,p_to_cle_id='||x_clev_rec.id);
        END IF;

        copy_items(
            p_api_version => 1.0,
            p_init_msg_list => FND_API.G_FALSE,
            x_return_status => l_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            p_from_cle_id => p_from_cle_id,
            p_copy_reference => p_copy_reference,
            p_to_cle_id => x_clev_rec.id);

        IF (l_return_status NOT IN (OKC_API.G_RET_STS_SUCCESS, OKC_API.G_RET_STS_WARNING)) THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
            IF (l_return_status = OKC_API.G_RET_STS_SUCCESS AND x_return_status =  OKC_API.G_RET_STS_WARNING) THEN
                NULL; --do not overwrite warning with success
            ELSE
                x_return_status := l_return_status;
            END IF;
        END IF;

        FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

        IF(FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.end', 'x_return_status='||x_return_status);
        END IF;

    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
            ROLLBACK TO copy_contract_line_PVT;

            IF(FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name||'.end_halt_validation', 'x_return_status='||x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

        WHEN OTHERS THEN
            ROLLBACK TO copy_contract_line_PVT;

            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                l_error_text := substr (SQLERRM, 1, 512);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

    END copy_contract_line;



  ----------------------------------------------------------------------------
  -- Proceduere to create operation instance and operation lines for
  -- contract header in case of RENEW
  -- Parameters: p_chrv_rec    - in header record for object_chr_id and scs_code
  --             p_to_chr_id   - subject_chr_id
  ----------------------------------------------------------------------------
    PROCEDURE Create_Renewal_Header_Link (
                                          p_api_version                  IN NUMBER,
                                          p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                          x_return_status                OUT NOCOPY VARCHAR2,
                                          x_msg_count                    OUT NOCOPY NUMBER,
                                          x_msg_data                     OUT NOCOPY VARCHAR2,
                                          p_chrv_rec                     IN OKC_CONTRACT_PUB.chrv_rec_type,
                                          p_to_chr_id                    IN NUMBER)
    IS
    -- bug 5262302
    -- below cursor is not needed as this code is only called for ren_con with id = 41
    -- Cursor to get class operation id
    -- CURSOR cop_csr IS
    --    SELECT id
    --    FROM okc_class_operations
    --    WHERE cls_code = (SELECT cls_code
    --                      FROM okc_subclasses_b
    --                      WHERE code = p_chrv_rec.scs_code );

    l_cop_id        NUMBER;
    l_oiev_rec      OKC_OPER_INST_PUB.oiev_rec_type;
    lx_oiev_rec     OKC_OPER_INST_PUB.oiev_rec_type;
    l_olev_rec      OKC_OPER_INST_PUB.olev_rec_type;
    lx_olev_rec     OKC_OPER_INST_PUB.olev_rec_type;
    l_count         NUMBER := 0;
    BEGIN
    -- bug 5262302
    -- get class operation id
    --    OPEN cop_csr;
    --    FETCH cop_csr INTO l_cop_id;
    --    CLOSE cop_csr;

        l_oiev_rec.cop_id := 41; -- l_cop_id; bug 5262302
        l_oiev_rec.target_chr_id := p_to_chr_id;
        l_oiev_rec.status_code := 'ENTERED';

        OKC_OPER_INST_PUB.Create_Operation_Instance (
                                                     p_api_version => p_api_version,
                                                     p_init_msg_list => p_init_msg_list,
                                                     x_return_status => x_return_status,
                                                     x_msg_count => x_msg_count,
                                                     x_msg_data => x_msg_data,
                                                     p_oiev_rec => l_oiev_rec,
                                                     x_oiev_rec => lx_oiev_rec);

        IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
            l_olev_rec.SELECT_YN := 'Y';
            l_olev_rec.OIE_ID := lx_oiev_rec.id;
            l_olev_rec.SUBJECT_CHR_ID := p_to_chr_id;
            l_olev_rec.OBJECT_CHR_ID := p_chrv_rec.id;

            OKC_OPER_INST_PUB.Create_Operation_Line (
                                                     p_api_version => p_api_version,
                                                     p_init_msg_list => p_init_msg_list,
                                                     x_return_status => x_return_status,
                                                     x_msg_count => x_msg_count,
                                                     x_msg_data => x_msg_data,
                                                     p_olev_rec => l_olev_rec,
                                                     x_olev_rec => lx_olev_rec);
            IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
           -- set g_op_lines table
                l_count := g_op_lines.COUNT + 1;
                g_op_lines(l_count).id := p_chrv_rec.ID;
                g_op_lines(l_count).ole_id := lx_olev_rec.ID;
            END IF;
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
	  -- store SQL error message on message stack
            x_return_status := OKC_API.G_RET_STS_ERROR;
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => 'OKC_NOT_FOUND',
                                p_token1 => 'VALUE1',
                                p_token1_value => 'Status Code',
                                p_token2 => 'VALUE2',
                                p_token2_value => 'OKC_CLASS_OPERATIONS_V');
        WHEN OTHERS THEN
	  -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_unexpected_error,
                                p_token1 => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2 => g_sqlerrm_token,
                                p_token2_value => SQLERRM);
	   -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END Create_Renewal_Header_Link;


  ----------------------------------------------------------------------------
  --Function to populate the articles translation record to be copied.
  ----------------------------------------------------------------------------
    FUNCTION    get_atnv_rec(p_atn_id IN NUMBER,
                             x_atnv_rec OUT NOCOPY atnv_rec_type)
    RETURN  VARCHAR2 IS
    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_no_data_found BOOLEAN := TRUE;

    CURSOR c_atnv_rec IS
        SELECT	ID,
          CAT_ID,
          CLE_ID,
          RUL_ID,
          DNZ_CHR_ID
      FROM    OKC_ARTICLE_TRANS_V
      WHERE 	ID = p_atn_id;
    BEGIN
        OPEN c_atnv_rec;
        FETCH c_atnv_rec
        INTO	x_atnv_rec.ID,
        x_atnv_rec.CAT_ID,
        x_atnv_rec.CLE_ID,
        x_atnv_rec.RUL_ID,
        x_atnv_rec.DNZ_CHR_ID;

        l_no_data_found := c_atnv_rec%NOTFOUND;
        CLOSE c_atnv_rec;
        IF l_no_data_found THEN
            l_return_status := OKC_API.G_RET_STS_ERROR;
            RETURN(l_return_status);
        ELSE
            RETURN(l_return_status);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
        -- notify caller of an UNEXPECTED error
            l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            RETURN(l_return_status);

    END get_atnv_rec;

  ----------------------------------------------------------------------------
  --Function to populate the articles record to be copied.
  ----------------------------------------------------------------------------
    FUNCTION    get_catv_rec(p_cat_id IN NUMBER,
                             x_catv_rec OUT NOCOPY catv_rec_type)
    RETURN  VARCHAR2 IS
    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_no_data_found BOOLEAN := TRUE;

    CURSOR c_catv_rec IS
        SELECT	ID,
          CHR_ID,
          CLE_ID,
          CAT_ID,
          SFWT_FLAG,
          SAV_SAE_ID,
          SAV_SAV_RELEASE,
          SBT_CODE,
          DNZ_CHR_ID,
          COMMENTS,
          FULLTEXT_YN,
          VARIATION_DESCRIPTION,
          NAME,
          TEXT,
          ATTRIBUTE_CATEGORY,
          ATTRIBUTE1,
          ATTRIBUTE2,
          ATTRIBUTE3,
          ATTRIBUTE4,
          ATTRIBUTE5,
          ATTRIBUTE6,
          ATTRIBUTE7,
          ATTRIBUTE8,
          ATTRIBUTE9,
          ATTRIBUTE10,
          ATTRIBUTE11,
          ATTRIBUTE12,
          ATTRIBUTE13,
          ATTRIBUTE14,
          ATTRIBUTE15,
          CAT_TYPE
      FROM    OKC_K_ARTICLES_V
      WHERE 	ID = p_cat_id;
    BEGIN
        OPEN c_catv_rec;
        FETCH c_catv_rec
        INTO	x_catv_rec.ID,
        x_catv_rec.CHR_ID,
        x_catv_rec.CLE_ID,
        x_catv_rec.CAT_ID,
        x_catv_rec.SFWT_FLAG,
        x_catv_rec.SAV_SAE_ID,
        x_catv_rec.SAV_SAV_RELEASE,
        x_catv_rec.SBT_CODE,
        x_catv_rec.DNZ_CHR_ID,
        x_catv_rec.COMMENTS,
        x_catv_rec.FULLTEXT_YN,
        x_catv_rec.VARIATION_DESCRIPTION,
        x_catv_rec.NAME,
        x_catv_rec.TEXT,
        x_catv_rec.ATTRIBUTE_CATEGORY,
        x_catv_rec.ATTRIBUTE1,
        x_catv_rec.ATTRIBUTE2,
        x_catv_rec.ATTRIBUTE3,
        x_catv_rec.ATTRIBUTE4,
        x_catv_rec.ATTRIBUTE5,
        x_catv_rec.ATTRIBUTE6,
        x_catv_rec.ATTRIBUTE7,
        x_catv_rec.ATTRIBUTE8,
        x_catv_rec.ATTRIBUTE9,
        x_catv_rec.ATTRIBUTE10,
        x_catv_rec.ATTRIBUTE11,
        x_catv_rec.ATTRIBUTE12,
        x_catv_rec.ATTRIBUTE13,
        x_catv_rec.ATTRIBUTE14,
        x_catv_rec.ATTRIBUTE15,
        x_catv_rec.CAT_TYPE;

        l_no_data_found := c_catv_rec%NOTFOUND;
        CLOSE c_catv_rec;
        IF l_no_data_found THEN
            l_return_status := OKC_API.G_RET_STS_ERROR;
            RETURN(l_return_status);
        ELSE
            RETURN(l_return_status);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
        -- notify caller of an UNEXPECTED error
            l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            RETURN(l_return_status);

    END get_catv_rec;

  ----------------------------------------------------------------------------
  --Function to populate the contract items record to be copied.
  ----------------------------------------------------------------------------
    FUNCTION    get_cimv_rec(p_cim_id IN NUMBER,
                             x_cimv_rec OUT NOCOPY cimv_rec_type) RETURN  VARCHAR2 IS
    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_no_data_found BOOLEAN := TRUE;

    CURSOR c_cimv_rec IS
        SELECT	ID,
          CLE_ID,
          CHR_ID,
          CLE_ID_FOR,
          DNZ_CHR_ID,
          OBJECT1_ID1,
          OBJECT1_ID2,
          JTOT_OBJECT1_CODE,
          UOM_CODE,
          EXCEPTION_YN,
          NUMBER_OF_ITEMS,
                  PRICED_ITEM_YN
      FROM    OKC_K_ITEMS_V
      WHERE 	ID = p_cim_id;

    BEGIN
        OPEN c_cimv_rec;
        FETCH c_cimv_rec
        INTO	x_cimv_rec.ID,
        x_cimv_rec.CLE_ID,
        x_cimv_rec.CHR_ID,
        x_cimv_rec.CLE_ID_FOR,
        x_cimv_rec.DNZ_CHR_ID,
        x_cimv_rec.OBJECT1_ID1,
        x_cimv_rec.OBJECT1_ID2,
        x_cimv_rec.JTOT_OBJECT1_CODE,
        x_cimv_rec.UOM_CODE,
        x_cimv_rec.EXCEPTION_YN,
        x_cimv_rec.NUMBER_OF_ITEMS,
        x_cimv_rec.PRICED_ITEM_YN;


        l_no_data_found := c_cimv_rec%NOTFOUND;
        CLOSE c_cimv_rec;
        IF l_no_data_found THEN
            l_return_status := OKC_API.G_RET_STS_ERROR;
            RETURN(l_return_status);
        ELSE
            RETURN(l_return_status);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
        -- notify caller of an UNEXPECTED error
            l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            RETURN(l_return_status);

    END get_cimv_rec;
  ----------------------------------------------------------------------------
  --Function to populate the contract access record to be copied.
  ----------------------------------------------------------------------------
    FUNCTION    get_cacv_rec(p_cac_id IN NUMBER,
                             x_cacv_rec OUT NOCOPY cacv_rec_type) RETURN  VARCHAR2 IS
    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_no_data_found BOOLEAN := TRUE;

    CURSOR c_cacv_rec IS
        SELECT	ID,
          GROUP_ID,
          CHR_ID,
          RESOURCE_ID,
          ACCESS_LEVEL
      FROM    OKC_K_ACCESSES_V
      WHERE 	ID = p_cac_id;
    BEGIN
        OPEN c_cacv_rec;
        FETCH c_cacv_rec
        INTO	x_cacv_rec.ID,
        x_cacv_rec.GROUP_ID,
        x_cacv_rec.CHR_ID,
        x_cacv_rec.RESOURCE_ID,
        x_cacv_rec.ACCESS_LEVEL;

        l_no_data_found := c_cacv_rec%NOTFOUND;
        CLOSE c_cacv_rec;
        IF l_no_data_found THEN
            l_return_status := OKC_API.G_RET_STS_ERROR;
            RETURN(l_return_status);
        ELSE
            RETURN(l_return_status);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
        -- notify caller of an UNEXPECTED error
            l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            RETURN(l_return_status);

    END get_cacv_rec;
  ----------------------------------------------------------------------------
  --Function to populate the contract party roles record to be copied.
  ----------------------------------------------------------------------------
    FUNCTION    get_cplv_rec(p_cpl_id IN NUMBER,
                             x_cplv_rec OUT NOCOPY cplv_rec_type) RETURN  VARCHAR2 IS
    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_no_data_found BOOLEAN := TRUE;

    CURSOR c_cplv_rec IS
        SELECT	ID,
          SFWT_FLAG,
          CHR_ID,
          CLE_ID,
          RLE_CODE,
          DNZ_CHR_ID,
          OBJECT1_ID1,
          OBJECT1_ID2,
          JTOT_OBJECT1_CODE,
          COGNOMEN,
          CODE,
          FACILITY,
          MINORITY_GROUP_LOOKUP_CODE,
          SMALL_BUSINESS_FLAG,
          WOMEN_OWNED_FLAG,
          ALIAS,
          ATTRIBUTE_CATEGORY,
          ATTRIBUTE1,
          ATTRIBUTE2,
          ATTRIBUTE3,
          ATTRIBUTE4,
          ATTRIBUTE5,
          ATTRIBUTE6,
          ATTRIBUTE7,
          ATTRIBUTE8,
          ATTRIBUTE9,
          ATTRIBUTE10,
          ATTRIBUTE11,
          ATTRIBUTE12,
          ATTRIBUTE13,
          ATTRIBUTE14,
          ATTRIBUTE15
      FROM    OKC_K_PARTY_ROLES_V
      WHERE 	ID = p_cpl_id;
    BEGIN
        OPEN c_cplv_rec;
        FETCH c_cplv_rec
        INTO	x_cplv_rec.ID,
        x_cplv_rec.SFWT_FLAG,
        x_cplv_rec.CHR_ID,
        x_cplv_rec.CLE_ID,
        x_cplv_rec.RLE_CODE,
        x_cplv_rec.DNZ_CHR_ID,
        x_cplv_rec.OBJECT1_ID1,
        x_cplv_rec.OBJECT1_ID2,
        x_cplv_rec.JTOT_OBJECT1_CODE,
        x_cplv_rec.COGNOMEN,
        x_cplv_rec.CODE,
        x_cplv_rec.FACILITY,
        x_cplv_rec.MINORITY_GROUP_LOOKUP_CODE,
        x_cplv_rec.SMALL_BUSINESS_FLAG,
        x_cplv_rec.WOMEN_OWNED_FLAG,
        x_cplv_rec.ALIAS,
        x_cplv_rec.ATTRIBUTE_CATEGORY,
        x_cplv_rec.ATTRIBUTE1,
        x_cplv_rec.ATTRIBUTE2,
        x_cplv_rec.ATTRIBUTE3,
        x_cplv_rec.ATTRIBUTE4,
        x_cplv_rec.ATTRIBUTE5,
        x_cplv_rec.ATTRIBUTE6,
        x_cplv_rec.ATTRIBUTE7,
        x_cplv_rec.ATTRIBUTE8,
        x_cplv_rec.ATTRIBUTE9,
        x_cplv_rec.ATTRIBUTE10,
        x_cplv_rec.ATTRIBUTE11,
        x_cplv_rec.ATTRIBUTE12,
        x_cplv_rec.ATTRIBUTE13,
        x_cplv_rec.ATTRIBUTE14,
        x_cplv_rec.ATTRIBUTE15;

        l_no_data_found := c_cplv_rec%NOTFOUND;
        CLOSE c_cplv_rec;
        IF l_no_data_found THEN
            l_return_status := OKC_API.G_RET_STS_ERROR;
            RETURN(l_return_status);
        ELSE
            RETURN(l_return_status);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
        -- notify caller of an UNEXPECTED error
            l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            RETURN(l_return_status);

    END get_cplv_rec;
  ----------------------------------------------------------------------------
  --Function to populate the contract process record to be copied.
  ----------------------------------------------------------------------------
    FUNCTION    get_cpsv_rec(p_cps_id IN NUMBER,
                             x_cpsv_rec OUT NOCOPY cpsv_rec_type) RETURN  VARCHAR2 IS
    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_no_data_found BOOLEAN := TRUE;

    CURSOR c_cpsv_rec IS
        SELECT	ID,
          PDF_ID,
          CHR_ID,
          USER_ID,
          CRT_ID,
          PROCESS_ID,
          IN_PROCESS_YN,
          ATTRIBUTE_CATEGORY,
          ATTRIBUTE1,
          ATTRIBUTE2,
          ATTRIBUTE3,
          ATTRIBUTE4,
          ATTRIBUTE5,
          ATTRIBUTE6,
          ATTRIBUTE7,
          ATTRIBUTE8,
          ATTRIBUTE9,
          ATTRIBUTE10,
          ATTRIBUTE11,
          ATTRIBUTE12,
          ATTRIBUTE13,
          ATTRIBUTE14,
          ATTRIBUTE15
      FROM    OKC_K_PROCESSES_V
      WHERE 	ID = p_cps_id;
    BEGIN
        OPEN c_cpsv_rec;
        FETCH c_cpsv_rec
        INTO	x_cpsv_rec.ID,
        x_cpsv_rec.PDF_ID,
        x_cpsv_rec.CHR_ID,
        x_cpsv_rec.USER_ID,
        x_cpsv_rec.CRT_ID,
        x_cpsv_rec.PROCESS_ID,
        x_cpsv_rec.IN_PROCESS_YN,
        x_cpsv_rec.ATTRIBUTE_CATEGORY,
        x_cpsv_rec.ATTRIBUTE1,
        x_cpsv_rec.ATTRIBUTE2,
        x_cpsv_rec.ATTRIBUTE3,
        x_cpsv_rec.ATTRIBUTE4,
        x_cpsv_rec.ATTRIBUTE5,
        x_cpsv_rec.ATTRIBUTE6,
        x_cpsv_rec.ATTRIBUTE7,
        x_cpsv_rec.ATTRIBUTE8,
        x_cpsv_rec.ATTRIBUTE9,
        x_cpsv_rec.ATTRIBUTE10,
        x_cpsv_rec.ATTRIBUTE11,
        x_cpsv_rec.ATTRIBUTE12,
        x_cpsv_rec.ATTRIBUTE13,
        x_cpsv_rec.ATTRIBUTE14,
        x_cpsv_rec.ATTRIBUTE15;

        l_no_data_found := c_cpsv_rec%NOTFOUND;
        CLOSE c_cpsv_rec;
        IF l_no_data_found THEN
            l_return_status := OKC_API.G_RET_STS_ERROR;
            RETURN(l_return_status);
        ELSE
            RETURN(l_return_status);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
        -- notify caller of an UNEXPECTED error
            l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            RETURN(l_return_status);

    END get_cpsv_rec;
  ----------------------------------------------------------------------------
  --Function to populate the contract group record to be copied.
  ----------------------------------------------------------------------------
    FUNCTION    get_cgcv_rec(p_cgc_id IN NUMBER,
                             x_cgcv_rec OUT NOCOPY cgcv_rec_type) RETURN  VARCHAR2 IS
    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_no_data_found BOOLEAN := TRUE;

    CURSOR c_cgcv_rec IS
        SELECT	ID,
          CGP_PARENT_ID,
          INCLUDED_CHR_ID,
          INCLUDED_CGP_ID
      FROM    OKC_K_GRPINGS_V
      WHERE 	ID = p_cgc_id;
    BEGIN
        OPEN c_cgcv_rec;
        FETCH c_cgcv_rec
        INTO	x_cgcv_rec.ID,
        x_cgcv_rec.CGP_PARENT_ID,
        x_cgcv_rec.INCLUDED_CHR_ID,
        x_cgcv_rec.INCLUDED_CGP_ID;
        l_no_data_found := c_cgcv_rec%NOTFOUND;
        CLOSE c_cgcv_rec;
        IF l_no_data_found THEN
            l_return_status := OKC_API.G_RET_STS_ERROR;
            RETURN(l_return_status);
        ELSE
            RETURN(l_return_status);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
        -- notify caller of an UNEXPECTED error
            l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            RETURN(l_return_status);

    END get_cgcv_rec;
  ----------------------------------------------------------------------------
  --Function to populate the condition headers record to be copied.
  ----------------------------------------------------------------------------
    FUNCTION    get_cnhv_rec(p_cnh_id IN NUMBER,
                             x_cnhv_rec OUT NOCOPY cnhv_rec_type) RETURN  VARCHAR2 IS
    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_no_data_found BOOLEAN := TRUE;

    CURSOR c_cnhv_rec IS
        SELECT	ID,
          SFWT_FLAG,
          ACN_ID,
          COUNTER_GROUP_ID,
          DESCRIPTION,
          SHORT_DESCRIPTION,
          COMMENTS,
          ONE_TIME_YN,
          NAME,
          CONDITION_VALID_YN,
          BEFORE_AFTER,
          TRACKED_YN,
          CNH_VARIANCE,
          DNZ_CHR_ID,
          TEMPLATE_YN,
          DATE_ACTIVE,
          OBJECT_ID,
          DATE_INACTIVE,
          JTOT_OBJECT_CODE,
          TASK_OWNER_ID,
          CNH_TYPE,
          ATTRIBUTE_CATEGORY,
          ATTRIBUTE1,
          ATTRIBUTE2,
          ATTRIBUTE3,
          ATTRIBUTE4,
          ATTRIBUTE5,
          ATTRIBUTE6,
          ATTRIBUTE7,
          ATTRIBUTE8,
          ATTRIBUTE9,
          ATTRIBUTE10,
          ATTRIBUTE11,
          ATTRIBUTE12,
          ATTRIBUTE13,
          ATTRIBUTE14,
          ATTRIBUTE15
      FROM    OKC_CONDITION_HEADERS_V
      WHERE 	ID = p_cnh_id;
    BEGIN
        OPEN c_cnhv_rec;
        FETCH c_cnhv_rec
        INTO	x_cnhv_rec.ID,
        x_cnhv_rec.SFWT_FLAG,
        x_cnhv_rec.ACN_ID,
        x_cnhv_rec.COUNTER_GROUP_ID,
        x_cnhv_rec.DESCRIPTION,
        x_cnhv_rec.SHORT_DESCRIPTION,
        x_cnhv_rec.COMMENTS,
        x_cnhv_rec.ONE_TIME_YN,
        x_cnhv_rec.NAME,
        x_cnhv_rec.CONDITION_VALID_YN,
        x_cnhv_rec.BEFORE_AFTER,
        x_cnhv_rec.TRACKED_YN,
        x_cnhv_rec.CNH_VARIANCE,
        x_cnhv_rec.DNZ_CHR_ID,
        x_cnhv_rec.TEMPLATE_YN,
        x_cnhv_rec.DATE_ACTIVE,
        x_cnhv_rec.OBJECT_ID,
        x_cnhv_rec.DATE_INACTIVE,
        x_cnhv_rec.JTOT_OBJECT_CODE,
        x_cnhv_rec.TASK_OWNER_ID,
        x_cnhv_rec.CNH_TYPE,
        x_cnhv_rec.ATTRIBUTE_CATEGORY,
        x_cnhv_rec.ATTRIBUTE1,
        x_cnhv_rec.ATTRIBUTE2,
        x_cnhv_rec.ATTRIBUTE3,
        x_cnhv_rec.ATTRIBUTE4,
        x_cnhv_rec.ATTRIBUTE5,
        x_cnhv_rec.ATTRIBUTE6,
        x_cnhv_rec.ATTRIBUTE7,
        x_cnhv_rec.ATTRIBUTE8,
        x_cnhv_rec.ATTRIBUTE9,
        x_cnhv_rec.ATTRIBUTE10,
        x_cnhv_rec.ATTRIBUTE11,
        x_cnhv_rec.ATTRIBUTE12,
        x_cnhv_rec.ATTRIBUTE13,
        x_cnhv_rec.ATTRIBUTE14,
        x_cnhv_rec.ATTRIBUTE15;

        l_no_data_found := c_cnhv_rec%NOTFOUND;
        CLOSE c_cnhv_rec;
        IF l_no_data_found THEN
            l_return_status := OKC_API.G_RET_STS_ERROR;
            RETURN(l_return_status);
        ELSE
            RETURN(l_return_status);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
        -- notify caller of an UNEXPECTED error
            l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            RETURN(l_return_status);

    END get_cnhv_rec;
  ----------------------------------------------------------------------------
  --Function to populate the condition lines record to be copied.
  ----------------------------------------------------------------------------
    FUNCTION    get_cnlv_rec(p_cnl_id IN NUMBER,
                             x_cnlv_rec OUT NOCOPY cnlv_rec_type) RETURN  VARCHAR2 IS
    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_no_data_found BOOLEAN := TRUE;

    CURSOR c_cnlv_rec IS
        SELECT	ID,
          SFWT_FLAG,
          START_AT,
          CNH_ID,
          PDF_ID,
          AAE_ID,
          LEFT_CTR_MASTER_ID,
          RIGHT_CTR_MASTER_ID,
          LEFT_COUNTER_ID,
          RIGHT_COUNTER_ID,
          DNZ_CHR_ID,
          SORTSEQ,
          CNL_TYPE,
          DESCRIPTION,
          LEFT_PARENTHESIS,
          RELATIONAL_OPERATOR,
          RIGHT_PARENTHESIS,
          LOGICAL_OPERATOR,
          TOLERANCE,
          RIGHT_OPERAND,
          ATTRIBUTE_CATEGORY,
          ATTRIBUTE1,
          ATTRIBUTE2,
          ATTRIBUTE3,
          ATTRIBUTE4,
          ATTRIBUTE5,
          ATTRIBUTE6,
          ATTRIBUTE7,
          ATTRIBUTE8,
          ATTRIBUTE9,
          ATTRIBUTE10,
          ATTRIBUTE11,
          ATTRIBUTE12,
          ATTRIBUTE13,
          ATTRIBUTE14,
          ATTRIBUTE15
      FROM    OKC_CONDITION_LINES_V
      WHERE 	ID = p_cnl_id;
    BEGIN
        OPEN c_cnlv_rec;
        FETCH c_cnlv_rec
        INTO	x_cnlv_rec.ID,
        x_cnlv_rec.SFWT_FLAG,
        x_cnlv_rec.START_AT,
        x_cnlv_rec.CNH_ID,
        x_cnlv_rec.PDF_ID,
        x_cnlv_rec.AAE_ID,
        x_cnlv_rec.LEFT_CTR_MASTER_ID,
        x_cnlv_rec.RIGHT_CTR_MASTER_ID,
        x_cnlv_rec.LEFT_COUNTER_ID,
        x_cnlv_rec.RIGHT_COUNTER_ID,
        x_cnlv_rec.DNZ_CHR_ID,
        x_cnlv_rec.SORTSEQ,
        x_cnlv_rec.CNL_TYPE,
        x_cnlv_rec.DESCRIPTION,
        x_cnlv_rec.LEFT_PARENTHESIS,
        x_cnlv_rec.RELATIONAL_OPERATOR,
        x_cnlv_rec.RIGHT_PARENTHESIS,
        x_cnlv_rec.LOGICAL_OPERATOR,
        x_cnlv_rec.TOLERANCE,
        x_cnlv_rec.RIGHT_OPERAND,
        x_cnlv_rec.ATTRIBUTE_CATEGORY,
        x_cnlv_rec.ATTRIBUTE1,
        x_cnlv_rec.ATTRIBUTE2,
        x_cnlv_rec.ATTRIBUTE3,
        x_cnlv_rec.ATTRIBUTE4,
        x_cnlv_rec.ATTRIBUTE5,
        x_cnlv_rec.ATTRIBUTE6,
        x_cnlv_rec.ATTRIBUTE7,
        x_cnlv_rec.ATTRIBUTE8,
        x_cnlv_rec.ATTRIBUTE9,
        x_cnlv_rec.ATTRIBUTE10,
        x_cnlv_rec.ATTRIBUTE11,
        x_cnlv_rec.ATTRIBUTE12,
        x_cnlv_rec.ATTRIBUTE13,
        x_cnlv_rec.ATTRIBUTE14,
        x_cnlv_rec.ATTRIBUTE15;

        l_no_data_found := c_cnlv_rec%NOTFOUND;
        CLOSE c_cnlv_rec;
        IF l_no_data_found THEN
            l_return_status := OKC_API.G_RET_STS_ERROR;
            RETURN(l_return_status);
        ELSE
            RETURN(l_return_status);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
        -- notify caller of an UNEXPECTED error
            l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            RETURN(l_return_status);

    END get_cnlv_rec;
  ----------------------------------------------------------------------------
  --Function to populate the contacts record to be copied.
  ----------------------------------------------------------------------------

    FUNCTION    get_ctcv_rec(p_ctc_id IN NUMBER,
                             x_ctcv_rec OUT NOCOPY ctcv_rec_type) RETURN  VARCHAR2 IS

    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_no_data_found BOOLEAN := TRUE;

    CURSOR c_ctcv_rec IS
        SELECT	ID,
                  CPL_ID,
                  CRO_CODE,
                  DNZ_CHR_ID,
                  CONTACT_SEQUENCE,
                  OBJECT1_ID1,
                  OBJECT1_ID2,
                  JTOT_OBJECT1_CODE,
                  ATTRIBUTE_CATEGORY,
                  ATTRIBUTE1,
                  ATTRIBUTE2,
                  ATTRIBUTE3,
                  ATTRIBUTE4,
                  ATTRIBUTE5,
                  ATTRIBUTE6,
                  ATTRIBUTE7,
                  ATTRIBUTE8,
                  ATTRIBUTE9,
                  ATTRIBUTE10,
                  ATTRIBUTE11,
                  ATTRIBUTE12,
                  ATTRIBUTE13,
                  ATTRIBUTE14,
                  ATTRIBUTE15
      FROM    OKC_CONTACTS_V
      WHERE 	ID = p_ctc_id;
    BEGIN
        OPEN c_ctcv_rec;
        FETCH c_ctcv_rec
        INTO	x_ctcv_rec.ID,
        x_ctcv_rec.CPL_ID,
        x_ctcv_rec.CRO_CODE,
        x_ctcv_rec.DNZ_CHR_ID,
        x_ctcv_rec.CONTACT_SEQUENCE,
        x_ctcv_rec.OBJECT1_ID1,
        x_ctcv_rec.OBJECT1_ID2,
        x_ctcv_rec.JTOT_OBJECT1_CODE,
        x_ctcv_rec.ATTRIBUTE_CATEGORY,
        x_ctcv_rec.ATTRIBUTE1,
        x_ctcv_rec.ATTRIBUTE2,
        x_ctcv_rec.ATTRIBUTE3,
        x_ctcv_rec.ATTRIBUTE4,
        x_ctcv_rec.ATTRIBUTE5,
        x_ctcv_rec.ATTRIBUTE6,
        x_ctcv_rec.ATTRIBUTE7,
        x_ctcv_rec.ATTRIBUTE8,
        x_ctcv_rec.ATTRIBUTE9,
        x_ctcv_rec.ATTRIBUTE10,
        x_ctcv_rec.ATTRIBUTE11,
        x_ctcv_rec.ATTRIBUTE12,
        x_ctcv_rec.ATTRIBUTE13,
        x_ctcv_rec.ATTRIBUTE14,
        x_ctcv_rec.ATTRIBUTE15;

        l_no_data_found := c_ctcv_rec%NOTFOUND;
        CLOSE c_ctcv_rec;
        IF l_no_data_found THEN
            l_return_status := OKC_API.G_RET_STS_ERROR;
            RETURN(l_return_status);
        ELSE
            RETURN(l_return_status);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
        -- notify caller of an UNEXPECTED error
            l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            RETURN(l_return_status);

    END get_ctcv_rec;

   ----------------------------------------------------------------------------
  --Function to populate the rules record to be copied.
  --p_old_cle_id is for passing old line id
  --x_klnv_rec will hold the table of records with new rules to be copied
  ----------------------------------------------------------------------------
    FUNCTION    get_klnv_rec(p_old_cle_id IN NUMBER,
                             x_klnv_rec OUT NOCOPY klnv_rec_type)
    RETURN  VARCHAR2 IS
    l_return_status	     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_no_data_found BOOLEAN := TRUE;
    l_count         NUMBER := 1;

    CURSOR c_klnv_rec(cp_cle_id IN NUMBER) IS
        SELECT
            id
            ,cle_id
            ,dnz_chr_id
            ,discount_list
            ,acct_rule_id
            ,payment_type
            ,cc_no
            ,cc_expiry_date
            ,cc_bank_acct_id
            ,cc_auth_code
            ,commitment_id
            ,locked_price_list_id
            ,usage_est_yn
            ,usage_est_method
            ,usage_est_start_date
            ,termn_method
            ,ubt_amount
            ,credit_amount
            ,suppressed_credit
            ,override_amount
            ,cust_po_number_req_yn
            ,cust_po_number
            ,grace_duration
            ,grace_period
            ,inv_print_flag
            ,price_uom
            ,tax_amount
            ,tax_inclusive_yn
            ,tax_status
            ,tax_code
            ,tax_exemption_id
            ,ib_trans_type
            ,ib_trans_date
            ,prod_price
            ,service_price
            ,clvl_list_price
            ,clvl_quantity
            ,clvl_extended_amt
            ,clvl_uom_code
            ,toplvl_operand_code
            ,toplvl_operand_val
            ,toplvl_quantity
            ,toplvl_uom_code
            ,toplvl_adj_price
            ,toplvl_price_qty
            ,averaging_interval
            ,settlement_interval
            ,minimum_quantity
            ,default_quantity
            ,amcv_flag
            ,fixed_quantity
            ,usage_duration
            ,usage_period
            ,level_yn
            ,usage_type
            ,uom_quantified
            ,base_reading
            ,billing_schedule_type
            ,full_credit
            ,locked_price_list_line_id
            ,break_uom
            ,prorate
            ,coverage_type
            ,exception_cov_id
            ,limit_uom_quantified
            ,discount_amount
            ,discount_percent
            ,offset_duration
            ,offset_period
            ,incident_severity_id
            ,pdf_id
            ,work_thru_yn
            ,react_active_yn
            ,transfer_option
            ,prod_upgrade_yn
            ,inheritance_type
            ,pm_program_id
            ,pm_conf_req_yn
            ,pm_sch_exists_yn
            ,allow_bt_discount
            ,apply_default_timezone
            ,sync_date_install
            ,sfwt_flag
            ,invoice_text
            ,ib_trx_details
            ,status_text
            ,react_time_name
            ,object_version_number
            ,security_group_id
            ,request_id
            ,created_by
            ,creation_date
            ,last_updated_by
            ,last_update_date
            ,last_update_login
            ,trxn_extension_id
            ,tax_classification_code
            ,exempt_certificate_number
            ,exempt_reason_code
            ,coverage_id
            ,standard_cov_yn
            ,orig_system_id1
            ,orig_system_reference1
            ,orig_system_source_code
        FROM 	OKS_K_LINES_V
        WHERE	cle_id = cp_cle_id;

    BEGIN

        OPEN c_klnv_rec(p_old_cle_id);
        FETCH c_klnv_rec INTO
            x_klnv_rec.id
            ,x_klnv_rec.cle_id
            ,x_klnv_rec.dnz_chr_id
            ,x_klnv_rec.discount_list
            ,x_klnv_rec.acct_rule_id
            ,x_klnv_rec.payment_type
            ,x_klnv_rec.cc_no
            ,x_klnv_rec.cc_expiry_date
            ,x_klnv_rec.cc_bank_acct_id
            ,x_klnv_rec.cc_auth_code
            ,x_klnv_rec.commitment_id
            ,x_klnv_rec.locked_price_list_id
            ,x_klnv_rec.usage_est_yn
            ,x_klnv_rec.usage_est_method
            ,x_klnv_rec.usage_est_start_date
            ,x_klnv_rec.termn_method
            ,x_klnv_rec.ubt_amount
            ,x_klnv_rec.credit_amount
            ,x_klnv_rec.suppressed_credit
            ,x_klnv_rec.override_amount
            ,x_klnv_rec.cust_po_number_req_yn
            ,x_klnv_rec.cust_po_number
            ,x_klnv_rec.grace_duration
            ,x_klnv_rec.grace_period
            ,x_klnv_rec.inv_print_flag
            ,x_klnv_rec.price_uom
            ,x_klnv_rec.tax_amount
            ,x_klnv_rec.tax_inclusive_yn
            ,x_klnv_rec.tax_status
            ,x_klnv_rec.tax_code
            ,x_klnv_rec.tax_exemption_id
            ,x_klnv_rec.ib_trans_type
            ,x_klnv_rec.ib_trans_date
            ,x_klnv_rec.prod_price
            ,x_klnv_rec.service_price
            ,x_klnv_rec.clvl_list_price
            ,x_klnv_rec.clvl_quantity
            ,x_klnv_rec.clvl_extended_amt
            ,x_klnv_rec.clvl_uom_code
            ,x_klnv_rec.toplvl_operand_code
            ,x_klnv_rec.toplvl_operand_val
            ,x_klnv_rec.toplvl_quantity
            ,x_klnv_rec.toplvl_uom_code
            ,x_klnv_rec.toplvl_adj_price
            ,x_klnv_rec.toplvl_price_qty
            ,x_klnv_rec.averaging_interval
            ,x_klnv_rec.settlement_interval
            ,x_klnv_rec.minimum_quantity
            ,x_klnv_rec.default_quantity
            ,x_klnv_rec.amcv_flag
            ,x_klnv_rec.fixed_quantity
            ,x_klnv_rec.usage_duration
            ,x_klnv_rec.usage_period
            ,x_klnv_rec.level_yn
            ,x_klnv_rec.usage_type
            ,x_klnv_rec.uom_quantified
            ,x_klnv_rec.base_reading
            ,x_klnv_rec.billing_schedule_type
            ,x_klnv_rec.full_credit
            ,x_klnv_rec.locked_price_list_line_id
            ,x_klnv_rec.break_uom
            ,x_klnv_rec.prorate
            ,x_klnv_rec.coverage_type
            ,x_klnv_rec.exception_cov_id
            ,x_klnv_rec.limit_uom_quantified
            ,x_klnv_rec.discount_amount
            ,x_klnv_rec.discount_percent
            ,x_klnv_rec.offset_duration
            ,x_klnv_rec.offset_period
            ,x_klnv_rec.incident_severity_id
            ,x_klnv_rec.pdf_id
            ,x_klnv_rec.work_thru_yn
            ,x_klnv_rec.react_active_yn
            ,x_klnv_rec.transfer_option
            ,x_klnv_rec.prod_upgrade_yn
            ,x_klnv_rec.inheritance_type
            ,x_klnv_rec.pm_program_id
            ,x_klnv_rec.pm_conf_req_yn
            ,x_klnv_rec.pm_sch_exists_yn
            ,x_klnv_rec.allow_bt_discount
            ,x_klnv_rec.apply_default_timezone
            ,x_klnv_rec.sync_date_install
            ,x_klnv_rec.sfwt_flag
            ,x_klnv_rec.invoice_text
            ,x_klnv_rec.ib_trx_details
            ,x_klnv_rec.status_text
            ,x_klnv_rec.react_time_name
            ,x_klnv_rec.object_version_number
            ,x_klnv_rec.security_group_id
            ,x_klnv_rec.request_id
            ,x_klnv_rec.created_by
            ,x_klnv_rec.creation_date
            ,x_klnv_rec.last_updated_by
            ,x_klnv_rec.last_update_date
            ,x_klnv_rec.last_update_login
            ,x_klnv_rec.trxn_extension_id
            ,x_klnv_rec.tax_classification_code
            ,x_klnv_rec.exempt_certificate_number
            ,x_klnv_rec.exempt_reason_code
            ,x_klnv_rec.coverage_id
            ,x_klnv_rec.standard_cov_yn
            ,x_klnv_rec.orig_system_id1
            ,x_klnv_rec.orig_system_reference1
            ,x_klnv_rec.orig_system_source_code;

        l_no_data_found := c_klnv_rec%NOTFOUND;

        CLOSE c_klnv_rec;

        IF l_no_data_found THEN
            l_return_status := OKC_API.G_RET_STS_ERROR;
            RETURN(l_return_status);
        ELSE
            RETURN(l_return_status);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
        -- notify caller of an UNEXPECTED error
            l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            RETURN(l_return_status);
    END get_klnv_rec;
  ----------------------------------------------------------------------------
  --Function to populate the lines record to be copied.
  ----------------------------------------------------------------------------
    FUNCTION    get_clev_rec(p_cle_id IN NUMBER,
                             x_clev_rec OUT NOCOPY clev_rec_type)
    RETURN  VARCHAR2 IS
    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_no_data_found BOOLEAN := TRUE;


    CURSOR c_clev_rec IS
        SELECT
        id
        ,object_version_number
        ,sfwt_flag
        ,chr_id
        ,cle_id
        ,cle_id_renewed
        ,cle_id_renewed_to
        ,lse_id
        ,line_number
        ,sts_code
        ,display_sequence
        ,trn_code
        ,dnz_chr_id
        ,comments
        ,item_description
        ,oke_boe_description
        ,cognomen
        ,hidden_ind
        ,price_unit
        ,price_unit_percent
        ,price_negotiated
        ,price_negotiated_renewed
        ,price_level_ind
        ,invoice_line_level_ind
        ,dpas_rating
        ,block23text
        ,exception_yn
        ,template_used
        ,date_terminated
        ,name
        ,start_date
        ,end_date
        ,date_renewed
        ,upg_orig_system_ref
        ,upg_orig_system_ref_id
        ,orig_system_source_code
        ,orig_system_id1
        ,orig_system_reference1
        ,attribute_category
        ,attribute1
        ,attribute2
        ,attribute3
        ,attribute4
        ,attribute5
        ,attribute6
        ,attribute7
        ,attribute8
        ,attribute9
        ,attribute10
        ,attribute11
        ,attribute12
        ,attribute13
        ,attribute14
        ,attribute15
        ,created_by
        ,creation_date
        ,last_updated_by
        ,last_update_date
        ,price_type
        ,currency_code
        ,currency_code_renewed
        ,last_update_login
        ,request_id
        ,program_application_id
        ,program_id
        ,program_update_date
        ,price_list_id
        ,pricing_date
        ,price_list_line_id
        ,line_list_price
        ,item_to_price_yn
        ,price_basis_yn
        ,config_header_id
        ,config_revision_number
        ,config_complete_yn
        ,config_valid_yn
        ,config_top_model_line_id
        ,config_item_type
        ,CONFIG_ITEM_ID
        ,service_item_yn
        ,ph_pricing_type
        ,ph_price_break_basis
        ,ph_min_qty
        ,ph_min_amt
        ,ph_qp_reference_id
        ,ph_value
        ,ph_enforce_price_list_yn
        ,ph_adjustment
        ,ph_integrated_with_qp
        ,cust_acct_id
        ,bill_to_site_use_id
        ,inv_rule_id
        ,line_renewal_type_code
        ,ship_to_site_use_id
        ,payment_term_id
        ,date_cancelled
        ,term_cancel_source
        ,cancelled_amount
        ,annualized_factor
        ,payment_instruction_type
        FROM	OKC_K_LINES_V
        WHERE	id = p_cle_id;

    BEGIN

        OPEN c_clev_rec;
        FETCH c_clev_rec INTO
        x_clev_rec.id
        ,x_clev_rec.object_version_number
        ,x_clev_rec.sfwt_flag
        ,x_clev_rec.chr_id
        ,x_clev_rec.cle_id
        ,x_clev_rec.cle_id_renewed
        ,x_clev_rec.cle_id_renewed_to
        ,x_clev_rec.lse_id
        ,x_clev_rec.line_number
        ,x_clev_rec.sts_code
        ,x_clev_rec.display_sequence
        ,x_clev_rec.trn_code
        ,x_clev_rec.dnz_chr_id
        ,x_clev_rec.comments
        ,x_clev_rec.item_description
        ,x_clev_rec.oke_boe_description
        ,x_clev_rec.cognomen
        ,x_clev_rec.hidden_ind
        ,x_clev_rec.price_unit
        ,x_clev_rec.price_unit_percent
        ,x_clev_rec.price_negotiated
        ,x_clev_rec.price_negotiated_renewed
        ,x_clev_rec.price_level_ind
        ,x_clev_rec.invoice_line_level_ind
        ,x_clev_rec.dpas_rating
        ,x_clev_rec.block23text
        ,x_clev_rec.exception_yn
        ,x_clev_rec.template_used
        ,x_clev_rec.date_terminated
        ,x_clev_rec.name
        ,x_clev_rec.start_date
        ,x_clev_rec.end_date
        ,x_clev_rec.date_renewed
        ,x_clev_rec.upg_orig_system_ref
        ,x_clev_rec.upg_orig_system_ref_id
        ,x_clev_rec.orig_system_source_code
        ,x_clev_rec.orig_system_id1
        ,x_clev_rec.orig_system_reference1
        ,x_clev_rec.attribute_category
        ,x_clev_rec.attribute1
        ,x_clev_rec.attribute2
        ,x_clev_rec.attribute3
        ,x_clev_rec.attribute4
        ,x_clev_rec.attribute5
        ,x_clev_rec.attribute6
        ,x_clev_rec.attribute7
        ,x_clev_rec.attribute8
        ,x_clev_rec.attribute9
        ,x_clev_rec.attribute10
        ,x_clev_rec.attribute11
        ,x_clev_rec.attribute12
        ,x_clev_rec.attribute13
        ,x_clev_rec.attribute14
        ,x_clev_rec.attribute15
        ,x_clev_rec.created_by
        ,x_clev_rec.creation_date
        ,x_clev_rec.last_updated_by
        ,x_clev_rec.last_update_date
        ,x_clev_rec.price_type
        ,x_clev_rec.currency_code
        ,x_clev_rec.currency_code_renewed
        ,x_clev_rec.last_update_login
        ,x_clev_rec.request_id
        ,x_clev_rec.program_application_id
        ,x_clev_rec.program_id
        ,x_clev_rec.program_update_date
        ,x_clev_rec.price_list_id
        ,x_clev_rec.pricing_date
        ,x_clev_rec.price_list_line_id
        ,x_clev_rec.line_list_price
        ,x_clev_rec.item_to_price_yn
        ,x_clev_rec.price_basis_yn
        ,x_clev_rec.config_header_id
        ,x_clev_rec.config_revision_number
        ,x_clev_rec.config_complete_yn
        ,x_clev_rec.config_valid_yn
        ,x_clev_rec.config_top_model_line_id
        ,x_clev_rec.config_item_type
        ,x_clev_rec.CONFIG_ITEM_ID
        ,x_clev_rec.service_item_yn
        ,x_clev_rec.ph_pricing_type
        ,x_clev_rec.ph_price_break_basis
        ,x_clev_rec.ph_min_qty
        ,x_clev_rec.ph_min_amt
        ,x_clev_rec.ph_qp_reference_id
        ,x_clev_rec.ph_value
        ,x_clev_rec.ph_enforce_price_list_yn
        ,x_clev_rec.ph_adjustment
        ,x_clev_rec.ph_integrated_with_qp
        ,x_clev_rec.cust_acct_id
        ,x_clev_rec.bill_to_site_use_id
        ,x_clev_rec.inv_rule_id
        ,x_clev_rec.line_renewal_type_code
        ,x_clev_rec.ship_to_site_use_id
        ,x_clev_rec.payment_term_id
        ,x_clev_rec.date_cancelled
        ,x_clev_rec.term_cancel_source
        ,x_clev_rec.cancelled_amount
        ,x_clev_rec.annualized_factor
        ,x_clev_rec.payment_instruction_type;

        l_no_data_found := c_clev_rec%NOTFOUND;
        CLOSE c_clev_rec;
        IF l_no_data_found THEN
            l_return_status := OKC_API.G_RET_STS_ERROR;
            RETURN(l_return_status);
        ELSE
            RETURN(l_return_status);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
        -- notify caller of an UNEXPECTED error
            l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            RETURN(l_return_status);
    END get_clev_rec;


   ----------------------------------------------------------------------------
  --Function to populate the sections record to be copied.
  ----------------------------------------------------------------------------

    FUNCTION    get_scnv_rec(p_scn_id IN NUMBER,
                             x_scnv_rec OUT NOCOPY scnv_rec_type) RETURN  VARCHAR2 IS

    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_no_data_found BOOLEAN := TRUE;

    CURSOR c_scnv_rec IS
        SELECT	 ID,
                  SCN_TYPE,
                  CHR_ID,
                  SAT_CODE,
                  SECTION_SEQUENCE,
                  LABEL,
                  HEADING,
                  SCN_ID,
                  SFWT_FLAG,
                  ATTRIBUTE_CATEGORY,
                  ATTRIBUTE1,
                  ATTRIBUTE2,
                  ATTRIBUTE3,
                  ATTRIBUTE4,
                  ATTRIBUTE5,
                  ATTRIBUTE6,
                  ATTRIBUTE7,
                  ATTRIBUTE8,
                  ATTRIBUTE9,
                  ATTRIBUTE10,
                  ATTRIBUTE11,
                  ATTRIBUTE12,
                  ATTRIBUTE13,
                  ATTRIBUTE14,
                  ATTRIBUTE15
      FROM    OKC_SECTIONS_V
      WHERE 	ID = p_scn_id;
    BEGIN
        OPEN c_scnv_rec;
        FETCH c_scnv_rec
        INTO	 x_scnv_rec.ID,
        x_scnv_rec.SCN_TYPE,
        x_scnv_rec.CHR_ID,
        x_scnv_rec.SAT_CODE,
        x_scnv_rec.SECTION_SEQUENCE,
        x_scnv_rec.LABEL,
        x_scnv_rec.HEADING,
        x_scnv_rec.SCN_ID,
        x_scnv_rec.SFWT_FLAG,
        x_scnv_rec.ATTRIBUTE_CATEGORY,
        x_scnv_rec.ATTRIBUTE1,
        x_scnv_rec.ATTRIBUTE2,
        x_scnv_rec.ATTRIBUTE3,
        x_scnv_rec.ATTRIBUTE4,
        x_scnv_rec.ATTRIBUTE5,
        x_scnv_rec.ATTRIBUTE6,
        x_scnv_rec.ATTRIBUTE7,
        x_scnv_rec.ATTRIBUTE8,
        x_scnv_rec.ATTRIBUTE9,
        x_scnv_rec.ATTRIBUTE10,
        x_scnv_rec.ATTRIBUTE11,
        x_scnv_rec.ATTRIBUTE12,
        x_scnv_rec.ATTRIBUTE13,
        x_scnv_rec.ATTRIBUTE14,
        x_scnv_rec.ATTRIBUTE15;

        l_no_data_found := c_scnv_rec%NOTFOUND;
        CLOSE c_scnv_rec;
        IF l_no_data_found THEN
            l_return_status := OKC_API.G_RET_STS_ERROR;
            RETURN(l_return_status);
        ELSE
            RETURN(l_return_status);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
        -- notify caller of an UNEXPECTED error
            l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            RETURN(l_return_status);

    END get_scnv_rec;

  ----------------------------------------------------------------------------
  --Function to populate the section contents record to be copied.
  ----------------------------------------------------------------------------

    FUNCTION    get_sccv_rec(p_scc_id IN NUMBER,
                             x_sccv_rec OUT NOCOPY sccv_rec_type) RETURN  VARCHAR2 IS

    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_no_data_found BOOLEAN := TRUE;

    CURSOR c_sccv_rec IS
        SELECT	 ID,
                  SCN_ID,
                  LABEL,
                  CAT_ID,
                  CLE_ID,
                  SAE_ID,
                  CONTENT_SEQUENCE,
                  ATTRIBUTE_CATEGORY,
                  ATTRIBUTE1,
                  ATTRIBUTE2,
                  ATTRIBUTE3,
                  ATTRIBUTE4,
                  ATTRIBUTE5,
                  ATTRIBUTE6,
                  ATTRIBUTE7,
                  ATTRIBUTE8,
                  ATTRIBUTE9,
                  ATTRIBUTE10,
                  ATTRIBUTE11,
                  ATTRIBUTE12,
                  ATTRIBUTE13,
                  ATTRIBUTE14,
                  ATTRIBUTE15
      FROM    OKC_SECTION_CONTENTS_V
      WHERE 	ID = p_scc_id;
    BEGIN
        OPEN c_sccv_rec;
        FETCH c_sccv_rec
        INTO	 x_sccv_rec.ID,
        x_sccv_rec.SCN_ID,
        x_sccv_rec.LABEL,
        x_sccv_rec.CAT_ID,
        x_sccv_rec.CLE_ID,
        x_sccv_rec.SAE_ID,
        x_sccv_rec.CONTENT_SEQUENCE,
        x_sccv_rec.ATTRIBUTE_CATEGORY,
        x_sccv_rec.ATTRIBUTE1,
        x_sccv_rec.ATTRIBUTE2,
        x_sccv_rec.ATTRIBUTE3,
        x_sccv_rec.ATTRIBUTE4,
        x_sccv_rec.ATTRIBUTE5,
        x_sccv_rec.ATTRIBUTE6,
        x_sccv_rec.ATTRIBUTE7,
        x_sccv_rec.ATTRIBUTE8,
        x_sccv_rec.ATTRIBUTE9,
        x_sccv_rec.ATTRIBUTE10,
        x_sccv_rec.ATTRIBUTE11,
        x_sccv_rec.ATTRIBUTE12,
        x_sccv_rec.ATTRIBUTE13,
        x_sccv_rec.ATTRIBUTE14,
        x_sccv_rec.ATTRIBUTE15;

        l_no_data_found := c_sccv_rec%NOTFOUND;
        CLOSE c_sccv_rec;
        IF l_no_data_found THEN
            l_return_status := OKC_API.G_RET_STS_ERROR;
            RETURN(l_return_status);
        ELSE
            RETURN(l_return_status);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
        -- notify caller of an UNEXPECTED error
            l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            RETURN(l_return_status);

    END get_sccv_rec;

  ----------------------------------------------------------------------------
  --Function to populate the price_attributes record to be copied.
  ----------------------------------------------------------------------------

    FUNCTION    get_pavv_rec(p_pav_id IN NUMBER,
                             x_pavv_rec OUT NOCOPY pavv_rec_type) RETURN  VARCHAR2 IS

    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_no_data_found BOOLEAN := TRUE;

    CURSOR c_pavv_rec IS
        SELECT	ID,
                  CHR_ID,
                  CLE_ID,
                  FLEX_TITLE,
                  PRICING_CONTEXT,
                  PRICING_ATTRIBUTE1,
                  PRICING_ATTRIBUTE2,
                  PRICING_ATTRIBUTE3,
                  PRICING_ATTRIBUTE4,
                  PRICING_ATTRIBUTE5,
                  PRICING_ATTRIBUTE6,
                  PRICING_ATTRIBUTE7,
                  PRICING_ATTRIBUTE8,
                  PRICING_ATTRIBUTE9,
                  PRICING_ATTRIBUTE10,
                  PRICING_ATTRIBUTE11,
                  PRICING_ATTRIBUTE12,
                  PRICING_ATTRIBUTE13,
                  PRICING_ATTRIBUTE14,
                  PRICING_ATTRIBUTE15,
                  PRICING_ATTRIBUTE16,
                  PRICING_ATTRIBUTE17,
                  PRICING_ATTRIBUTE18,
                  PRICING_ATTRIBUTE19,
                  PRICING_ATTRIBUTE20,
                  PRICING_ATTRIBUTE21,
                  PRICING_ATTRIBUTE22,
                  PRICING_ATTRIBUTE23,
                  PRICING_ATTRIBUTE24,
                  PRICING_ATTRIBUTE25,
                  PRICING_ATTRIBUTE26,
                  PRICING_ATTRIBUTE27,
                  PRICING_ATTRIBUTE28,
                  PRICING_ATTRIBUTE29,
                  PRICING_ATTRIBUTE30,
                  PRICING_ATTRIBUTE31,
                  PRICING_ATTRIBUTE32,
                  PRICING_ATTRIBUTE33,
                  PRICING_ATTRIBUTE34,
                  PRICING_ATTRIBUTE35,
                  PRICING_ATTRIBUTE36,
                  PRICING_ATTRIBUTE37,
                  PRICING_ATTRIBUTE38,
                  PRICING_ATTRIBUTE39,
                  PRICING_ATTRIBUTE40,
                  PRICING_ATTRIBUTE41,
                  PRICING_ATTRIBUTE42,
                  PRICING_ATTRIBUTE43,
                  PRICING_ATTRIBUTE44,
                  PRICING_ATTRIBUTE45,
                  PRICING_ATTRIBUTE46,
                  PRICING_ATTRIBUTE47,
                  PRICING_ATTRIBUTE48,
                  PRICING_ATTRIBUTE49,
                  PRICING_ATTRIBUTE50,
                  PRICING_ATTRIBUTE51,
                  PRICING_ATTRIBUTE52,
                  PRICING_ATTRIBUTE53,
                  PRICING_ATTRIBUTE54,
                  PRICING_ATTRIBUTE55,
                  PRICING_ATTRIBUTE56,
                  PRICING_ATTRIBUTE57,
                  PRICING_ATTRIBUTE58,
                  PRICING_ATTRIBUTE59,
                  PRICING_ATTRIBUTE60,
                  PRICING_ATTRIBUTE61,
                  PRICING_ATTRIBUTE62,
                  PRICING_ATTRIBUTE63,
                  PRICING_ATTRIBUTE64,
                  PRICING_ATTRIBUTE65,
                  PRICING_ATTRIBUTE66,
                  PRICING_ATTRIBUTE67,
                  PRICING_ATTRIBUTE68,
                  PRICING_ATTRIBUTE69,
                  PRICING_ATTRIBUTE70,
                  PRICING_ATTRIBUTE71,
                  PRICING_ATTRIBUTE72,
                  PRICING_ATTRIBUTE73,
                  PRICING_ATTRIBUTE74,
                  PRICING_ATTRIBUTE75,
                  PRICING_ATTRIBUTE76,
                  PRICING_ATTRIBUTE77,
                  PRICING_ATTRIBUTE78,
                  PRICING_ATTRIBUTE79,
                  PRICING_ATTRIBUTE80,
                  PRICING_ATTRIBUTE81,
                  PRICING_ATTRIBUTE82,
                  PRICING_ATTRIBUTE83,
                  PRICING_ATTRIBUTE84,
                  PRICING_ATTRIBUTE85,
                  PRICING_ATTRIBUTE86,
                  PRICING_ATTRIBUTE87,
                  PRICING_ATTRIBUTE88,
                  PRICING_ATTRIBUTE89,
                  PRICING_ATTRIBUTE90,
                  PRICING_ATTRIBUTE91,
                  PRICING_ATTRIBUTE92,
                  PRICING_ATTRIBUTE93,
                  PRICING_ATTRIBUTE94,
                  PRICING_ATTRIBUTE95,
                  PRICING_ATTRIBUTE96,
                  PRICING_ATTRIBUTE97,
                  PRICING_ATTRIBUTE98,
                  PRICING_ATTRIBUTE99,
                  PRICING_ATTRIBUTE100,
                  QUALIFIER_CONTEXT,
                  QUALIFIER_ATTRIBUTE1,
                  QUALIFIER_ATTRIBUTE2,
                  QUALIFIER_ATTRIBUTE3,
                  QUALIFIER_ATTRIBUTE4,
                  QUALIFIER_ATTRIBUTE5,
                  QUALIFIER_ATTRIBUTE6,
                  QUALIFIER_ATTRIBUTE7,
                  QUALIFIER_ATTRIBUTE8,
                  QUALIFIER_ATTRIBUTE9,
                  QUALIFIER_ATTRIBUTE10,
                  QUALIFIER_ATTRIBUTE11,
                  QUALIFIER_ATTRIBUTE12,
                  QUALIFIER_ATTRIBUTE13,
                  QUALIFIER_ATTRIBUTE14,
                  QUALIFIER_ATTRIBUTE15,
                  QUALIFIER_ATTRIBUTE16,
                  QUALIFIER_ATTRIBUTE17,
                  QUALIFIER_ATTRIBUTE18,
                  QUALIFIER_ATTRIBUTE19,
                  QUALIFIER_ATTRIBUTE20,
                  QUALIFIER_ATTRIBUTE21,
                  QUALIFIER_ATTRIBUTE22,
                  QUALIFIER_ATTRIBUTE23,
                  QUALIFIER_ATTRIBUTE24,
                  QUALIFIER_ATTRIBUTE25,
                  QUALIFIER_ATTRIBUTE26,
                  QUALIFIER_ATTRIBUTE27,
                  QUALIFIER_ATTRIBUTE28,
                  QUALIFIER_ATTRIBUTE29,
                  QUALIFIER_ATTRIBUTE30,
                  QUALIFIER_ATTRIBUTE31,
                  QUALIFIER_ATTRIBUTE32,
                  QUALIFIER_ATTRIBUTE33,
                  QUALIFIER_ATTRIBUTE34,
                  QUALIFIER_ATTRIBUTE35,
                  QUALIFIER_ATTRIBUTE36,
                  QUALIFIER_ATTRIBUTE37,
                  QUALIFIER_ATTRIBUTE38,
                  QUALIFIER_ATTRIBUTE39,
                  QUALIFIER_ATTRIBUTE40,
                  QUALIFIER_ATTRIBUTE41,
                  QUALIFIER_ATTRIBUTE42,
                  QUALIFIER_ATTRIBUTE43,
                  QUALIFIER_ATTRIBUTE44,
                  QUALIFIER_ATTRIBUTE45,
                  QUALIFIER_ATTRIBUTE46,
                  QUALIFIER_ATTRIBUTE47,
                  QUALIFIER_ATTRIBUTE48,
                  QUALIFIER_ATTRIBUTE49,
                  QUALIFIER_ATTRIBUTE50,
                  QUALIFIER_ATTRIBUTE51,
                  QUALIFIER_ATTRIBUTE52,
                  QUALIFIER_ATTRIBUTE53,
                  QUALIFIER_ATTRIBUTE54,
                  QUALIFIER_ATTRIBUTE55,
                  QUALIFIER_ATTRIBUTE56,
                  QUALIFIER_ATTRIBUTE57,
                  QUALIFIER_ATTRIBUTE58,
                  QUALIFIER_ATTRIBUTE59,
                  QUALIFIER_ATTRIBUTE60,
                  QUALIFIER_ATTRIBUTE61,
                  QUALIFIER_ATTRIBUTE62,
                  QUALIFIER_ATTRIBUTE63,
                  QUALIFIER_ATTRIBUTE64,
                  QUALIFIER_ATTRIBUTE65,
                  QUALIFIER_ATTRIBUTE66,
                  QUALIFIER_ATTRIBUTE67,
                  QUALIFIER_ATTRIBUTE68,
                  QUALIFIER_ATTRIBUTE69,
                  QUALIFIER_ATTRIBUTE70,
                  QUALIFIER_ATTRIBUTE71,
                  QUALIFIER_ATTRIBUTE72,
                  QUALIFIER_ATTRIBUTE73,
                  QUALIFIER_ATTRIBUTE74,
                  QUALIFIER_ATTRIBUTE75,
                  QUALIFIER_ATTRIBUTE76,
                  QUALIFIER_ATTRIBUTE77,
                  QUALIFIER_ATTRIBUTE78,
                  QUALIFIER_ATTRIBUTE79,
                  QUALIFIER_ATTRIBUTE80,
                  QUALIFIER_ATTRIBUTE81,
                  QUALIFIER_ATTRIBUTE82,
                  QUALIFIER_ATTRIBUTE83,
                  QUALIFIER_ATTRIBUTE84,
                  QUALIFIER_ATTRIBUTE85,
                  QUALIFIER_ATTRIBUTE86,
                  QUALIFIER_ATTRIBUTE87,
                  QUALIFIER_ATTRIBUTE88,
                  QUALIFIER_ATTRIBUTE89,
                  QUALIFIER_ATTRIBUTE90,
                  QUALIFIER_ATTRIBUTE91,
                  QUALIFIER_ATTRIBUTE92,
                  QUALIFIER_ATTRIBUTE93,
                  QUALIFIER_ATTRIBUTE94,
                  QUALIFIER_ATTRIBUTE95,
                  QUALIFIER_ATTRIBUTE96,
                  QUALIFIER_ATTRIBUTE97,
                  QUALIFIER_ATTRIBUTE98,
                  QUALIFIER_ATTRIBUTE99,
                  QUALIFIER_ATTRIBUTE100
      FROM    OKC_PRICE_ATT_VALUES_V
             WHERE   ID = p_pav_id;
    BEGIN
        OPEN c_pavv_rec;
        FETCH c_pavv_rec
        INTO	x_pavv_rec.ID,
        x_pavv_rec.CHR_ID,
        x_pavv_rec.CLE_ID,
        x_pavv_rec.FLEX_TITLE,
        x_pavv_rec.PRICING_CONTEXT,
        x_pavv_rec.PRICING_ATTRIBUTE1,
        x_pavv_rec.PRICING_ATTRIBUTE2,
        x_pavv_rec.PRICING_ATTRIBUTE3,
        x_pavv_rec.PRICING_ATTRIBUTE4,
        x_pavv_rec.PRICING_ATTRIBUTE5,
        x_pavv_rec.PRICING_ATTRIBUTE6,
        x_pavv_rec.PRICING_ATTRIBUTE7,
        x_pavv_rec.PRICING_ATTRIBUTE8,
        x_pavv_rec.PRICING_ATTRIBUTE9,
        x_pavv_rec.PRICING_ATTRIBUTE10,
        x_pavv_rec.PRICING_ATTRIBUTE11,
        x_pavv_rec.PRICING_ATTRIBUTE12,
        x_pavv_rec.PRICING_ATTRIBUTE13,
        x_pavv_rec.PRICING_ATTRIBUTE14,
        x_pavv_rec.PRICING_ATTRIBUTE15,
        x_pavv_rec.PRICING_ATTRIBUTE16,
        x_pavv_rec.PRICING_ATTRIBUTE17,
        x_pavv_rec.PRICING_ATTRIBUTE18,
        x_pavv_rec.PRICING_ATTRIBUTE19,
        x_pavv_rec.PRICING_ATTRIBUTE20,
        x_pavv_rec.PRICING_ATTRIBUTE21,
        x_pavv_rec.PRICING_ATTRIBUTE22,
        x_pavv_rec.PRICING_ATTRIBUTE23,
        x_pavv_rec.PRICING_ATTRIBUTE24,
        x_pavv_rec.PRICING_ATTRIBUTE25,
        x_pavv_rec.PRICING_ATTRIBUTE26,
        x_pavv_rec.PRICING_ATTRIBUTE27,
        x_pavv_rec.PRICING_ATTRIBUTE28,
        x_pavv_rec.PRICING_ATTRIBUTE29,
        x_pavv_rec.PRICING_ATTRIBUTE30,
        x_pavv_rec.PRICING_ATTRIBUTE31,
        x_pavv_rec.PRICING_ATTRIBUTE32,
        x_pavv_rec.PRICING_ATTRIBUTE33,
        x_pavv_rec.PRICING_ATTRIBUTE34,
        x_pavv_rec.PRICING_ATTRIBUTE35,
        x_pavv_rec.PRICING_ATTRIBUTE36,
        x_pavv_rec.PRICING_ATTRIBUTE37,
        x_pavv_rec.PRICING_ATTRIBUTE38,
        x_pavv_rec.PRICING_ATTRIBUTE39,
        x_pavv_rec.PRICING_ATTRIBUTE40,
        x_pavv_rec.PRICING_ATTRIBUTE41,
        x_pavv_rec.PRICING_ATTRIBUTE42,
        x_pavv_rec.PRICING_ATTRIBUTE43,
        x_pavv_rec.PRICING_ATTRIBUTE44,
        x_pavv_rec.PRICING_ATTRIBUTE45,
        x_pavv_rec.PRICING_ATTRIBUTE46,
        x_pavv_rec.PRICING_ATTRIBUTE47,
        x_pavv_rec.PRICING_ATTRIBUTE48,
        x_pavv_rec.PRICING_ATTRIBUTE49,
        x_pavv_rec.PRICING_ATTRIBUTE50,
        x_pavv_rec.PRICING_ATTRIBUTE51,
        x_pavv_rec.PRICING_ATTRIBUTE52,
        x_pavv_rec.PRICING_ATTRIBUTE53,
        x_pavv_rec.PRICING_ATTRIBUTE54,
        x_pavv_rec.PRICING_ATTRIBUTE55,
        x_pavv_rec.PRICING_ATTRIBUTE56,
        x_pavv_rec.PRICING_ATTRIBUTE57,
        x_pavv_rec.PRICING_ATTRIBUTE58,
        x_pavv_rec.PRICING_ATTRIBUTE59,
        x_pavv_rec.PRICING_ATTRIBUTE60,
        x_pavv_rec.PRICING_ATTRIBUTE61,
        x_pavv_rec.PRICING_ATTRIBUTE62,
        x_pavv_rec.PRICING_ATTRIBUTE63,
        x_pavv_rec.PRICING_ATTRIBUTE64,
        x_pavv_rec.PRICING_ATTRIBUTE65,
        x_pavv_rec.PRICING_ATTRIBUTE66,
        x_pavv_rec.PRICING_ATTRIBUTE67,
        x_pavv_rec.PRICING_ATTRIBUTE68,
        x_pavv_rec.PRICING_ATTRIBUTE69,
        x_pavv_rec.PRICING_ATTRIBUTE70,
        x_pavv_rec.PRICING_ATTRIBUTE71,
        x_pavv_rec.PRICING_ATTRIBUTE72,
        x_pavv_rec.PRICING_ATTRIBUTE73,
        x_pavv_rec.PRICING_ATTRIBUTE74,
        x_pavv_rec.PRICING_ATTRIBUTE75,
        x_pavv_rec.PRICING_ATTRIBUTE76,
        x_pavv_rec.PRICING_ATTRIBUTE77,
        x_pavv_rec.PRICING_ATTRIBUTE78,
        x_pavv_rec.PRICING_ATTRIBUTE79,
        x_pavv_rec.PRICING_ATTRIBUTE80,
        x_pavv_rec.PRICING_ATTRIBUTE81,
        x_pavv_rec.PRICING_ATTRIBUTE82,
        x_pavv_rec.PRICING_ATTRIBUTE83,
        x_pavv_rec.PRICING_ATTRIBUTE84,
        x_pavv_rec.PRICING_ATTRIBUTE85,
        x_pavv_rec.PRICING_ATTRIBUTE86,
        x_pavv_rec.PRICING_ATTRIBUTE87,
        x_pavv_rec.PRICING_ATTRIBUTE88,
        x_pavv_rec.PRICING_ATTRIBUTE89,
        x_pavv_rec.PRICING_ATTRIBUTE90,
        x_pavv_rec.PRICING_ATTRIBUTE91,
        x_pavv_rec.PRICING_ATTRIBUTE92,
        x_pavv_rec.PRICING_ATTRIBUTE93,
        x_pavv_rec.PRICING_ATTRIBUTE94,
        x_pavv_rec.PRICING_ATTRIBUTE95,
        x_pavv_rec.PRICING_ATTRIBUTE96,
        x_pavv_rec.PRICING_ATTRIBUTE97,
        x_pavv_rec.PRICING_ATTRIBUTE98,
        x_pavv_rec.PRICING_ATTRIBUTE99,
        x_pavv_rec.PRICING_ATTRIBUTE100,
        x_pavv_rec.QUALIFIER_CONTEXT,
        x_pavv_rec.QUALIFIER_ATTRIBUTE1,
        x_pavv_rec.QUALIFIER_ATTRIBUTE2,
        x_pavv_rec.QUALIFIER_ATTRIBUTE3,
        x_pavv_rec.QUALIFIER_ATTRIBUTE4,
        x_pavv_rec.QUALIFIER_ATTRIBUTE5,
        x_pavv_rec.QUALIFIER_ATTRIBUTE6,
        x_pavv_rec.QUALIFIER_ATTRIBUTE7,
        x_pavv_rec.QUALIFIER_ATTRIBUTE8,
        x_pavv_rec.QUALIFIER_ATTRIBUTE9,
        x_pavv_rec.QUALIFIER_ATTRIBUTE10,
        x_pavv_rec.QUALIFIER_ATTRIBUTE11,
        x_pavv_rec.QUALIFIER_ATTRIBUTE12,
        x_pavv_rec.QUALIFIER_ATTRIBUTE13,
        x_pavv_rec.QUALIFIER_ATTRIBUTE14,
        x_pavv_rec.QUALIFIER_ATTRIBUTE15,
        x_pavv_rec.QUALIFIER_ATTRIBUTE16,
        x_pavv_rec.QUALIFIER_ATTRIBUTE17,
        x_pavv_rec.QUALIFIER_ATTRIBUTE18,
        x_pavv_rec.QUALIFIER_ATTRIBUTE19,
        x_pavv_rec.QUALIFIER_ATTRIBUTE20,
        x_pavv_rec.QUALIFIER_ATTRIBUTE21,
        x_pavv_rec.QUALIFIER_ATTRIBUTE22,
        x_pavv_rec.QUALIFIER_ATTRIBUTE23,
        x_pavv_rec.QUALIFIER_ATTRIBUTE24,
        x_pavv_rec.QUALIFIER_ATTRIBUTE25,
        x_pavv_rec.QUALIFIER_ATTRIBUTE26,
        x_pavv_rec.QUALIFIER_ATTRIBUTE27,
        x_pavv_rec.QUALIFIER_ATTRIBUTE28,
        x_pavv_rec.QUALIFIER_ATTRIBUTE29,
        x_pavv_rec.QUALIFIER_ATTRIBUTE30,
        x_pavv_rec.QUALIFIER_ATTRIBUTE31,
        x_pavv_rec.QUALIFIER_ATTRIBUTE32,
        x_pavv_rec.QUALIFIER_ATTRIBUTE33,
        x_pavv_rec.QUALIFIER_ATTRIBUTE34,
        x_pavv_rec.QUALIFIER_ATTRIBUTE35,
        x_pavv_rec.QUALIFIER_ATTRIBUTE36,
        x_pavv_rec.QUALIFIER_ATTRIBUTE37,
        x_pavv_rec.QUALIFIER_ATTRIBUTE38,
        x_pavv_rec.QUALIFIER_ATTRIBUTE39,
        x_pavv_rec.QUALIFIER_ATTRIBUTE40,
        x_pavv_rec.QUALIFIER_ATTRIBUTE41,
        x_pavv_rec.QUALIFIER_ATTRIBUTE42,
        x_pavv_rec.QUALIFIER_ATTRIBUTE43,
        x_pavv_rec.QUALIFIER_ATTRIBUTE44,
        x_pavv_rec.QUALIFIER_ATTRIBUTE45,
        x_pavv_rec.QUALIFIER_ATTRIBUTE46,
        x_pavv_rec.QUALIFIER_ATTRIBUTE47,
        x_pavv_rec.QUALIFIER_ATTRIBUTE48,
        x_pavv_rec.QUALIFIER_ATTRIBUTE49,
        x_pavv_rec.QUALIFIER_ATTRIBUTE50,
        x_pavv_rec.QUALIFIER_ATTRIBUTE51,
        x_pavv_rec.QUALIFIER_ATTRIBUTE52,
        x_pavv_rec.QUALIFIER_ATTRIBUTE53,
        x_pavv_rec.QUALIFIER_ATTRIBUTE54,
        x_pavv_rec.QUALIFIER_ATTRIBUTE55,
        x_pavv_rec.QUALIFIER_ATTRIBUTE56,
        x_pavv_rec.QUALIFIER_ATTRIBUTE57,
        x_pavv_rec.QUALIFIER_ATTRIBUTE58,
        x_pavv_rec.QUALIFIER_ATTRIBUTE59,
        x_pavv_rec.QUALIFIER_ATTRIBUTE60,
        x_pavv_rec.QUALIFIER_ATTRIBUTE61,
        x_pavv_rec.QUALIFIER_ATTRIBUTE62,
        x_pavv_rec.QUALIFIER_ATTRIBUTE63,
        x_pavv_rec.QUALIFIER_ATTRIBUTE64,
        x_pavv_rec.QUALIFIER_ATTRIBUTE65,
        x_pavv_rec.QUALIFIER_ATTRIBUTE66,
        x_pavv_rec.QUALIFIER_ATTRIBUTE67,
        x_pavv_rec.QUALIFIER_ATTRIBUTE68,
        x_pavv_rec.QUALIFIER_ATTRIBUTE69,
        x_pavv_rec.QUALIFIER_ATTRIBUTE70,
        x_pavv_rec.QUALIFIER_ATTRIBUTE71,
        x_pavv_rec.QUALIFIER_ATTRIBUTE72,
        x_pavv_rec.QUALIFIER_ATTRIBUTE73,
        x_pavv_rec.QUALIFIER_ATTRIBUTE74,
        x_pavv_rec.QUALIFIER_ATTRIBUTE75,
        x_pavv_rec.QUALIFIER_ATTRIBUTE76,
        x_pavv_rec.QUALIFIER_ATTRIBUTE77,
        x_pavv_rec.QUALIFIER_ATTRIBUTE78,
        x_pavv_rec.QUALIFIER_ATTRIBUTE79,
        x_pavv_rec.QUALIFIER_ATTRIBUTE80,
        x_pavv_rec.QUALIFIER_ATTRIBUTE81,
        x_pavv_rec.QUALIFIER_ATTRIBUTE82,
        x_pavv_rec.QUALIFIER_ATTRIBUTE83,
        x_pavv_rec.QUALIFIER_ATTRIBUTE84,
        x_pavv_rec.QUALIFIER_ATTRIBUTE85,
        x_pavv_rec.QUALIFIER_ATTRIBUTE86,
        x_pavv_rec.QUALIFIER_ATTRIBUTE87,
        x_pavv_rec.QUALIFIER_ATTRIBUTE88,
        x_pavv_rec.QUALIFIER_ATTRIBUTE89,
        x_pavv_rec.QUALIFIER_ATTRIBUTE90,
        x_pavv_rec.QUALIFIER_ATTRIBUTE91,
        x_pavv_rec.QUALIFIER_ATTRIBUTE92,
        x_pavv_rec.QUALIFIER_ATTRIBUTE93,
        x_pavv_rec.QUALIFIER_ATTRIBUTE94,
        x_pavv_rec.QUALIFIER_ATTRIBUTE95,
        x_pavv_rec.QUALIFIER_ATTRIBUTE96,
        x_pavv_rec.QUALIFIER_ATTRIBUTE97,
        x_pavv_rec.QUALIFIER_ATTRIBUTE98,
        x_pavv_rec.QUALIFIER_ATTRIBUTE99,
        x_pavv_rec.QUALIFIER_ATTRIBUTE100;

        l_no_data_found := c_pavv_rec%NOTFOUND;
        CLOSE c_pavv_rec;
        IF l_no_data_found THEN
            l_return_status := OKC_API.G_RET_STS_ERROR;
            RETURN(l_return_status);
        ELSE
            RETURN(l_return_status);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
        -- notify caller of an UNEXPECTED error
            l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            RETURN(l_return_status);

    END get_pavv_rec;

    PROCEDURE create_trxn_extn(
        p_api_version                   IN NUMBER,
        p_init_msg_list                 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                 OUT NOCOPY VARCHAR2,
        x_msg_count                     OUT NOCOPY NUMBER,
        x_msg_data                      OUT NOCOPY VARCHAR2,
        p_old_trx_ext_id                IN NUMBER,
        p_order_id                      IN NUMBER,
        p_cust_acct_id                  IN NUMBER,
        p_bill_to_site_use_id           IN NUMBER,
        x_trx_ext_id                    OUT NOCOPY NUMBER)
    IS
    l_api_name CONSTANT VARCHAR2(30) := 'CREATE_TRXN_EXTN';
    l_api_version CONSTANT NUMBER := 1;
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR2(512);

    CURSOR c_party_from_billto(cp_bill_to_site_use_id IN NUMBER) IS
        SELECT cas.cust_account_id cust_account_id, ca.party_id party_id
        FROM hz_cust_site_uses_all csu, hz_cust_acct_sites_all cas, hz_cust_accounts_all ca
        WHERE csu.site_use_id = cp_bill_to_site_use_id
        AND cas.cust_acct_site_id = csu.cust_acct_site_id
        AND ca.cust_account_id = cas.cust_account_id;

    CURSOR c_party_from_cust(cp_cust_acct_id IN NUMBER) IS
        SELECT ca.party_id party_id
        FROM hz_cust_accounts_all ca
        WHERE ca.cust_account_id = cp_cust_acct_id;

    CURSOR c_instr(cp_trx_ext_id IN NUMBER) IS
        SELECT instr_assignment_id
        FROM iby_trxn_extensions_v
        WHERE trxn_extension_id = cp_trx_ext_id;

    l_cust_account_id	    NUMBER;
    l_party_id	            NUMBER;
    l_instr_assignment      NUMBER;

    l_payer	                IBY_FNDCPT_COMMON_PUB.payercontext_rec_type;
    l_trxn_attribs          IBY_FNDCPT_TRXN_PUB.trxnextension_rec_type;
    l_response		        IBY_FNDCPT_COMMON_PUB.result_rec_type;

    BEGIN

        --log key input parameters
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_old_trx_ext_id='||p_old_trx_ext_id||' ,p_order_id='||p_order_id||' ,p_cust_acct_id='||p_cust_acct_id||' ,p_bill_to_site_use_id='||p_bill_to_site_use_id);
        END IF;

        --standard api initilization and checks
        SAVEPOINT create_trxn_extn_PVT;
        IF NOT FND_API.compatible_api_call (l_api_version, p_api_version, l_api_name, G_PKG_NAME)THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        IF FND_API.to_boolean(p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        --first get the payer info
        IF (p_cust_acct_id IS NOT NULL) THEN

            l_cust_account_id := p_cust_acct_id;
            OPEN c_party_from_cust(p_cust_acct_id);
            FETCH c_party_from_cust INTO l_party_id;
            CLOSE c_party_from_cust;

        ELSIF (p_bill_to_site_use_id IS NOT NULL) THEN

            OPEN c_party_from_billto(p_bill_to_site_use_id);
            FETCH c_party_from_billto INTO l_cust_account_id, l_party_id;
            CLOSE c_party_from_billto;

        ELSE

            FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, 'Either p_cust_acct_id or p_bill_to_site_use_id is mandatory');
            RAISE FND_API.g_exc_error;

        END IF;

        --get the credit card (instrument assignment) info
        OPEN c_instr(p_old_trx_ext_id);
        FETCH c_instr INTO l_instr_assignment;
        CLOSE c_instr;

        l_payer.payment_function := IBY_FNDCPT_COMMON_PUB.G_PMT_FUNCTION_CUST_PMT; --CUSTOMER_PAYMENT
        l_payer.party_id := l_party_id;
        l_payer.cust_account_id := l_cust_account_id;

        l_trxn_attribs.originating_application_id := 515; --service contracts OKS
        l_trxn_attribs.order_id := p_order_id; --contract id or line id
        l_trxn_attribs.trxn_ref_number1  := to_char(SYSDATE,'ddmmyyyyhhmmssss'); --to make order id and trx ref 1 unique

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.create_trxn_extn', 'calling IBY_FNDCPT_TRXN_PUB.create_transaction_extension, p_payer.party_id='||l_party_id||' ,p_payer.cust_account_id='||l_cust_account_id||
            ' ,p_instr_assignment='||l_instr_assignment||' ,p_trxn_attribs.originating_application_id=515'||' ,p_trxn_attribs.order_id='||p_order_id);
        END IF;


        IBY_FNDCPT_TRXN_PUB.create_transaction_extension(
            p_api_version       => 1.0,
            p_init_msg_list     => FND_API.G_FALSE,
            p_commit            => FND_API.G_FALSE,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_payer             => l_Payer,
            p_payer_equivalency => IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD, --UPWARD
            p_pmt_channel       => IBY_FNDCPT_SETUP_PUB.G_CHANNEL_CREDIT_CARD, --CREDIT_CARD
            p_instr_assignment  => l_instr_assignment,
            p_trxn_attribs      => l_trxn_attribs,
            x_entity_id         => x_trx_ext_id,
            x_response          => l_response);

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.create_trxn_extn', 'after call to IBY_FNDCPT_TRXN_PUB.create_transaction_extension, x_return_status='||x_return_status||' ,x_entity_id='||x_trx_ext_id||
            ' ,result_code='||l_response.result_code||' ,result_category='||l_response.result_category||' ,result_message='||l_response.result_message);
        END IF;

        IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
        ELSIF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        END IF;

        --also check the pmt api result code
        IF (l_response.result_code <> IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS) THEN
            FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_response.result_message||'('||l_response.result_code||':'||l_response.result_category||')');
            RAISE FND_API.g_exc_error;
        END IF;

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end', 'x_return_status='|| x_return_status||' ,x_trx_ext_id='||x_trx_ext_id);
        END IF;
        FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

    EXCEPTION
        WHEN FND_API.g_exc_error THEN
            ROLLBACK TO create_trxn_extn_PVT;
            x_return_status := FND_API.g_ret_sts_error ;

            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

            IF (c_party_from_billto%isopen) THEN
                CLOSE c_party_from_billto;
            END IF;
            IF (c_party_from_cust%isopen) THEN
                CLOSE c_party_from_cust;
            END IF;
            IF (c_instr%isopen) THEN
                CLOSE c_instr;
            END IF;

        WHEN FND_API.g_exc_unexpected_error THEN
            ROLLBACK TO create_trxn_extn_PVT;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_unexpected_error', 'x_return_status=' || x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

            IF (c_party_from_billto%isopen) THEN
                CLOSE c_party_from_billto;
            END IF;
            IF (c_party_from_cust%isopen) THEN
                CLOSE c_party_from_cust;
            END IF;
            IF (c_instr%isopen) THEN
                CLOSE c_instr;
            END IF;

        WHEN OTHERS THEN
            ROLLBACK TO create_trxn_extn_PVT;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

            IF (c_party_from_billto%isopen) THEN
                CLOSE c_party_from_billto;
            END IF;
            IF (c_party_from_cust%isopen) THEN
                CLOSE c_party_from_cust;
            END IF;
            IF (c_instr%isopen) THEN
                CLOSE c_instr;
            END IF;

    END create_trxn_extn;

END OKS_RENCPY_PVT ;



/
