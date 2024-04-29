--------------------------------------------------------
--  DDL for Package Body POS_SUPP_CLASSIFICATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_SUPP_CLASSIFICATION_PKG" AS
/*$Header: POSSBCB.pls 120.6.12010000.6 2012/10/09 12:03:28 pneralla ship $ */


PROCEDURE add_bus_class_attr
(
p_party_id in number,
p_vendor_id in number,
p_lookup_code in varchar2,
p_exp_date    in date,
p_cert_num  in varchar2,
p_cert_agency in varchar2,
p_ext_attr_1 in varchar2,
p_class_status in varchar2,
p_request_id in number,
x_classification_id out nocopy number,
x_status    out nocopy varchar2,
x_exception_msg out nocopy varchar2
)
IS
l_mapping_id number;
l_count number;
BEGIN

    x_status := 'S';

    if ( p_class_status = 'APPROVED' ) THEN

        insert into pos_bus_class_attr
        (
                classification_id, certificate_number,
                certifying_agency, expiration_date,
                class_status, status, created_by, creation_date,
                ext_attr_1, attribute1, attribute2, attribute3,
                attribute4, attribute5, last_updated_by,
                last_update_date, last_update_login,
                party_id, lookup_type, lookup_code, start_date_active,
                vendor_id
        )
        values
        ( POS_BUS_CLASS_ATTR_S.NEXTVAL , p_cert_num,
          p_cert_agency, p_exp_date,
          'APPROVED', 'A', fnd_global.user_id, sysdate,
          p_ext_attr_1, null, null, null,
          null, null, fnd_global.user_id,
          sysdate, fnd_global.login_id,
          p_party_id, BUSINESS_CLASSIFICATION, p_lookup_code,sysdate,
          p_vendor_id
        );
    ELSE
        select count(mapping_id)
        into l_count
        from pos_supplier_mappings
        where party_id = p_party_id;

        if ( l_count = 0 ) then
            insert into pos_supplier_mappings
            (
                mapping_id, party_id , vendor_id ,
                created_by, creation_date,
                last_updated_by, last_update_date, last_update_login
            )
            values
            (
                pos_supplier_mapping_s.nextval, p_party_id, p_vendor_id,
                fnd_global.user_id, sysdate,
                fnd_global.user_id, sysdate, fnd_global.login_id
            );
        end if;

        select mapping_id
        into l_mapping_id
        from pos_supplier_mappings
        where party_id = p_party_id;

        insert into pos_bus_class_reqs
        (
                bus_class_request_id, mapping_id,
                request_type, request_status,
                classification_id, lookup_type, lookup_code,
                ext_attr_1, certification_no, certification_agency,
                expiration_date, created_by, creation_date,
                last_updated_by, last_update_date, last_update_login
        )
        values
        (
          POS_BUS_CLASS_REQUEST_S.NEXTVAL, l_mapping_id ,
          'ADD', 'PENDING',
          null,  BUSINESS_CLASSIFICATION, p_lookup_code,
          p_ext_attr_1, p_cert_num , p_cert_agency,
          p_exp_date, fnd_global.user_id, sysdate,
          fnd_global.user_id, sysdate, fnd_global.login_id
        );

    END IF;

END;


PROCEDURE update_bus_class_attr
(
p_party_id in number,
p_vendor_id in number,
p_selected  in varchar2,
p_classification_id in number,
p_request_id in number,
p_lookup_code in varchar2,
p_exp_date    in date,
p_cert_num  in varchar2,
p_cert_agency in varchar2,
p_ext_attr_1 in varchar2,
p_class_status in varchar2,
x_classification_id out nocopy number,
x_request_id  out nocopy number,
x_status    out nocopy varchar2,
x_exception_msg out nocopy varchar2
)
IS
l_class_id number;
l_mapping_id number;
l_count number;
BEGIN
    x_status := 'S';

    IF ( p_selected = 'N' ) then
        if (p_classification_id is not null and p_classification_id > 0 ) then
            update pos_bus_class_attr
            set status='I', last_update_date = sysdate,
            last_updated_by = fnd_global.user_id,
            end_date_active = sysdate
            where classification_id = p_classification_id;
            /*
	     * Adding the condition to reject the pending request, if the 'Applicable Flag'
	     * is unchecked. Please refer the bug 7415073 for more information.
	     **/
	    update pos_bus_class_reqs
            set request_status = 'REJECTED',
            last_update_date = sysdate,
            last_updated_by = fnd_global.user_id,
            last_update_login = fnd_global.login_id
            where bus_class_request_id = p_request_id;

        else
            update pos_bus_class_reqs
            set request_status = 'REJECTED',
            last_update_date = sysdate,
            last_updated_by = fnd_global.user_id,
            last_update_login = fnd_global.login_id
            where bus_class_request_id = p_request_id;
        end if;
        return;
    END IF;
    --ELSE

       if ( p_class_status = 'APPROVED' ) then
           -- Approved.
           if (p_classification_id is not null and p_classification_id > 0 ) then
                -- updating an already approved data
                update pos_bus_class_attr
                set certificate_number = p_cert_num,
                    certifying_agency = p_cert_agency,
                    expiration_date = p_exp_date,
                    class_status = 'APPROVED',
                    status = 'A',
                    ext_attr_1= p_ext_attr_1,
                    last_updated_by = fnd_global.user_id,
                    last_update_date = sysdate,
                    last_update_login= fnd_global.login_id
                where classification_id = p_classification_id;

                -- If a request exists, make it approved.
                if (p_request_id is not null and p_request_id > 0) then
                    update pos_bus_class_reqs
                        set request_status = 'APPROVED',
                        classification_id = l_class_id,
                        last_updated_by = fnd_global.user_id,
                        last_update_login = fnd_global.login_id,
                        last_update_date = sysdate
                    where  bus_class_request_id = p_request_id;
                end if;
            else
                select pos_bus_class_attr_s.nextval
                into l_class_id
                from dual;

                -- approving pending data
                insert into pos_bus_class_attr
                (
                    classification_id, certificate_number,
                    certifying_agency, expiration_date,
                    class_status, status, created_by, creation_date,
                    ext_attr_1, attribute1, attribute2, attribute3,
                    attribute4, attribute5, last_updated_by,
                    last_update_date, last_update_login,
                    party_id, lookup_type, lookup_code, start_date_active,
                    vendor_id
                )
                values
                ( l_class_id, p_cert_num,
                  p_cert_agency, p_exp_date,
                  'APPROVED', 'A', fnd_global.user_id, sysdate,
                  p_ext_attr_1, null, null, null,
                  null, null, fnd_global.user_id,
                  sysdate, -1,
                  p_party_id, BUSINESS_CLASSIFICATION, p_lookup_code,sysdate
                  , p_vendor_id
                );

                update pos_bus_class_reqs
                    set request_status = 'APPROVED',
                    classification_id = l_class_id,
                    last_updated_by = fnd_global.user_id,
                    last_update_login = fnd_global.login_id,
                    last_update_date = sysdate
                where  bus_class_request_id = p_request_id;
           end if;
       else
            -- Class status is not in APPROVED STATUS
            if (p_classification_id is not null and p_classification_id > 0 ) then

                /* Not needed.

                update pos_bus_class_attr
                set status='I', last_update_date = sysdate,
                last_updated_by = fnd_global.user_id,
                last_update_login = fnd_global.login_id
                where classification_id = p_classification_id;*/

                select count(mapping_id)
                into l_count
                from pos_supplier_mappings
                where party_id = p_party_id;

                if ( l_count = 0 ) then
                insert into pos_supplier_mappings
                    (
                        mapping_id, party_id , vendor_id ,
                        created_by, creation_date,
                        last_updated_by, last_update_date, last_update_login
                    )
                    values
                    (
                        pos_supplier_mapping_s.nextval, p_party_id, p_vendor_id,
                        fnd_global.user_id, sysdate,
                        fnd_global.user_id, sysdate, fnd_global.login_id
                    );
                end if;

                select mapping_id
                into l_mapping_id
                from pos_supplier_mappings
                where party_id = p_party_id;

                -- bug 11803346 - rejecting all other existing pending requests for the same lookup code
                UPDATE pos_bus_class_reqs
                SET request_status = 'REJECTED'
                WHERE mapping_id = l_mapping_id
                AND lookup_type = BUSINESS_CLASSIFICATION
                AND lookup_code = p_lookup_code;

                insert into pos_bus_class_reqs
                (
                    bus_class_request_id, mapping_id,
                    request_type, request_status,
                    classification_id, lookup_type, lookup_code,
                    ext_attr_1, certification_no, certification_agency,
                    expiration_date, created_by, creation_date,
                    last_updated_by, last_update_date, last_update_login
                )
                values
                (
                  POS_BUS_CLASS_REQUEST_S.NEXTVAL, l_mapping_id ,
                  'ADD', 'PENDING',
                  p_classification_id,  BUSINESS_CLASSIFICATION, p_lookup_code,
                  p_ext_attr_1, p_cert_num , p_cert_agency,
                  p_exp_date, fnd_global.user_id, sysdate,
                  fnd_global.user_id, sysdate, fnd_global.login_id
                );
            else
                update pos_bus_class_reqs
                set
                    request_type = 'ADD',
                    request_status = 'PENDING',
                    certification_no= p_cert_num,
                    certification_agency = p_cert_agency,
                    expiration_date = p_exp_date,
                    ext_attr_1= p_ext_attr_1,
                    last_updated_by = fnd_global.user_id,
                    last_update_date = sysdate,
                    last_update_login= fnd_global.login_id
                where bus_class_request_id = p_request_id;
            end if;
       end if;
    --END IF;

END;


--Start for Bug 6620664 - Controlling concurrent updates to Business Classification screen

PROCEDURE validate_bus_class_concurrency
(     p_party_id        IN  NUMBER,
      p_class_id_tbl        IN  po_tbl_number,
      p_req_id_tbl        IN  po_tbl_number,
      p_last_upd_date_tbl        IN  po_tbl_date,
      p_lkp_type_tbl        IN  po_tbl_varchar30,
      p_lkp_code_tbl        IN  po_tbl_varchar30,
      x_return_status     OUT nocopy VARCHAR2,
      x_error_msg          OUT nocopy VARCHAR2
)
IS

rec_count NUMBER;
l_last_upd_date DATE;
l_class_id NUMBER;
req_status VARCHAR2(30);
l_map_id NUMBER;

BEGIN

    x_return_status := 'S';

    for i in 1..p_req_id_tbl.COUNT LOOP

        IF (p_req_id_tbl(i) IS NOT NULL) THEN

            SELECT mapping_id INTO l_map_id
              FROM pos_supplier_mappings psm
             WHERE psm.party_id = p_party_id;

            SELECT request_status INTO req_status
              FROM pos_bus_class_reqs
             WHERE lookup_type = p_lkp_type_tbl(i)
               AND lookup_code = p_lkp_code_tbl(i)
               AND mapping_id = l_map_id
               AND last_update_date = (SELECT Max(last_update_date)
                                         FROM pos_bus_class_reqs
                                        WHERE lookup_type = p_lkp_type_tbl(i)
                                          AND lookup_code = p_lkp_code_tbl(i)
                                          AND mapping_id = l_map_id);

            IF (req_status <> 'PENDING') THEN

                x_error_msg :=  fnd_message.get_string('POS','POS_LOCK_SUPPLIER_ROW');
                x_return_status := 'E';
                RETURN;

            END IF;

        ELSIF(p_class_id_tbl(i) IS NOT NULL) THEN

            SELECT Max(classification_id) INTO l_class_id
              FROM pos_bus_class_attr
             WHERE party_id = p_party_id
               AND lookup_type = p_lkp_type_tbl(i)
               AND lookup_code = p_lkp_code_tbl(i)
               AND ( end_date_active is null or trunc(end_date_active) > sysdate )
               AND status='A'
               AND class_status = 'APPROVED'
               AND classification_id not in ( select classification_id
                                              from pos_bus_class_reqs pbcr,
                                                   pos_supplier_mappings psm
                                             where psm.party_id = p_party_id
                                               and psm.mapping_id = pbcr.mapping_id
                                               and pbcr.request_status = 'PENDING'
                                               and pbcr.request_type in ( 'ADD', 'UPDATE' )
                                               and pbcr.classification_id is not null
                                            );

            IF (l_class_id IS NULL OR l_class_id <> p_class_id_tbl(i)) THEN

                x_error_msg :=  fnd_message.get_string('POS','POS_LOCK_SUPPLIER_ROW');
                x_return_status := 'E';
                return;

            END IF;

        ELSE

            SELECT Count(*) INTO rec_count
            FROM (SELECT lookup_code
                    FROM pos_bus_class_attr pca1
                    WHERE status = 'A'
                      AND ( pca1.end_date_active is null or trunc(pca1.end_date_active) > sysdate )
                      AND lookup_type = p_lkp_type_tbl(i)
                      AND lookup_code = p_lkp_code_tbl(i)
                      and party_id = p_party_id
                      AND class_status in ('APPROVED')

                  UNION

                  SELECT lookup_code
                    FROM pos_bus_class_reqs pbcr, pos_supplier_mappings psm
                   WHERE psm.party_id = p_party_id
                     AND psm.mapping_id = pbcr.mapping_id
                     AND pbcr.lookup_type = p_lkp_type_tbl(i)
                     AND pbcr.lookup_code = p_lkp_code_tbl(i)
                     AND pbcr.request_status = 'PENDING'
                     AND pbcr.request_type in ('ADD', 'UPDATE')
                  )tbl_all;

            IF (rec_count > 0) THEN

                x_error_msg :=  fnd_message.get_string('POS','POS_LOCK_SUPPLIER_ROW');
                x_return_status := 'E';
                return;

            END IF;

        END IF;

    END LOOP;

END validate_bus_class_concurrency;

--End for Bug 6620664 - Controlling concurrent updates to Business Classification screen



/* Added as part of bug 5154822
 */


PROCEDURE SYNCHRONIZE_CLASS_TCA_TO_PO
( pPartyId in Number,
  pVendorId in Number
)
IS
l_women varchar2(1);
l_women_status varchar2(1);
l_women_update_date date;
l_minority_owned varchar2(100);
l_minority varchar2( 100 );
l_minority_status varchar2( 100 );
l_minority_type PO_VENDORS.MINORITY_GROUP_LOOKUP_CODE%TYPE;
l_minority_update_date date;
l_small_business varchar2( 1);
l_small_buss_update_date date;
l_small_business_status varchar2( 1);
x_exception_msg varchar2(1000);
BEGIN

    select decode(WOMEN_OWNED_FLAG, 'Y', 'Y','N'),
    decode(SMALL_BUSINESS_FLAG,'Y','Y','N'), MINORITY_GROUP_LOOKUP_CODE
    into l_women, l_small_business, l_minority
    from ap_suppliers
    where vendor_id = pVendorId;

    if (l_minority is null) then
        l_minority := '__te_st__';
    end if;

    BEGIN
    -- if the Status is A then returns Y else return N
        select decode(pca.status, 'A', 'Y', 'N')
        , pca.last_update_date
        into l_women_status, l_women_update_date
        from pos_bus_class_attr pca
        where pca.lookup_type='POS_BUSINESS_CLASSIFICATIONS'
        and pca.lookup_code='WOMEN_OWNED'
        and pca.start_date_active <= sysdate
        and (pca.end_date_active is null or pca.end_date_active > sysdate)
        and pca.party_id = pPartyId
        and pca.status = 'A'
        and pca.class_status = 'APPROVED';

        exception
            when NO_DATA_FOUND then
                l_women_status := 'N';
                l_women_update_date := sysdate ;
    END;

    if ( l_women <> l_women_status ) then
    begin
        --dbms_output.put_line('updating women owned status');
        update ap_suppliers
        set women_owned_flag = l_women_status
        , last_update_date = l_women_update_date
        where vendor_id = pVendorId;
    end;
    end if;

    BEGIN
    -- if the Status is A then returns Y else return N
        select decode(pca.status, 'A', 'Y', 'N')
        , pca.last_update_date
        into l_small_business_status, l_small_buss_update_date
        from pos_bus_class_attr pca
        where pca.lookup_type='POS_BUSINESS_CLASSIFICATIONS'
        and pca.lookup_code='SMALL_BUSINESS'
        and pca.start_date_active <= sysdate
        and (pca.end_date_active is null or pca.end_date_active > sysdate)
        and pca.party_id = pPartyId
        and pca.status = 'A'
        and pca.class_status = 'APPROVED';

        exception
            when NO_DATA_FOUND then
                l_small_business_status := 'N';
                l_small_buss_update_date := sysdate;
    END;

    if ( l_small_business <> l_small_business_status ) then
    begin
        update ap_suppliers
        set small_business_flag = l_small_business_status
        , last_update_date = l_small_buss_update_date
        where vendor_id = pVendorId;
    end;
    end if;

    BEGIN
    -- if the Status is A then returns Y else return N
        select decode(pca.status, 'A', 'Y', 'N')
        , pca.last_update_date, pca.ext_attr_1
        into l_minority_status
        , l_minority_update_date, l_minority_type
        from pos_bus_class_attr pca
        where pca.lookup_type='POS_BUSINESS_CLASSIFICATIONS'
        and pca.lookup_code='MINORITY_OWNED'
        and pca.start_date_active <= sysdate
        and (pca.end_date_active is null or pca.end_date_active > sysdate)
        and pca.party_id = pPartyId
        and pca.status = 'A'
        and pca.class_status = 'APPROVED';

        exception
            when NO_DATA_FOUND then
                l_minority_status := 'N';
                l_minority_update_date := sysdate;
                l_minority_type := null;
    END;

    if ( l_minority <> l_minority_type ) and (l_minority_type is not null) then
    begin
        --dbms_output.put_line('updating minority owned status');
        update ap_suppliers
        set MINORITY_GROUP_LOOKUP_CODE = l_minority_type
        , last_update_date = l_minority_update_date
        where vendor_id = pVendorId;
    end;
    end if;

END SYNCHRONIZE_CLASS_TCA_TO_PO;

/* Added as part of bug 5154822
 */
PROCEDURE CHECK_AND_MV_CLASS
(
    pPartyId in Number,
    pVendorId in Number,
    p_class_category in varchar2,
    p_class_code in varchar2,
    p_status in varchar2 ,
    x_classification_id out nocopy number,
    x_modified out nocopy varchar2
)
IS
l_po_status varchar2(1);
l_pos_status varchar2(1);
l_status varchar2(100);
l_exception_msg varchar2(1000);
l_id number;
l_temp_id number;
l_approval_status varchar2(100);
BEGIN
    l_po_status := p_status;
    BEGIN
        select decode(pca.status, 'A', 'Y', 'N'), pca.classification_id,
        -- if the Status is A then returns Y else return N
        pca.class_status
        into l_pos_status, x_classification_id
        ,l_approval_status
        from  pos_bus_class_attr pca
        where pca.lookup_type=p_class_category
        and pca.lookup_code=p_class_code
        and pca.start_date_active <= sysdate
        and (pca.end_date_active is null or pca.end_date_active > sysdate)
        and pca.party_id = pPartyId
	and pca.status = 'A';

        exception
            when NO_DATA_FOUND then
             l_pos_status := 'N';
             x_classification_id := -1;
    END;

    if ( l_po_status <> l_pos_status ) then
        if( l_po_status = 'Y' ) then
            x_modified := 'Y';
            select POS_BUS_CLASS_ATTR_S.NEXTVAL
            into l_id
            from dual;

            insert into pos_bus_class_attr
                (
                classification_id, certificate_number,
                certifying_agency, expiration_date,
                class_status, status, created_by, creation_date,
                attribute1, attribute2, attribute3,
                attribute4, attribute5, last_updated_by,
                last_update_date, last_update_login,
                party_id, lookup_type, lookup_code, start_date_active, vendor_id
                )
                values
                (l_id, null, null, null,
                 'APPROVED', 'A', -1, sysdate, null, null, null, null, null,
                 -1, sysdate, -1,
                 pPartyId, p_class_category, p_class_code,sysdate, pVendorId);
                 x_classification_id := l_id;
        else
         IF (l_approval_status = 'APPROVED' ) THEN
            x_modified := 'Y';
         -- end date the record only if the classification is approved,
         -- if not it might simply be in pending stage, which shouldn not
         -- be disturbed.
            update pos_bus_class_attr
            set status='I' , end_date_active = sysdate
            where classification_id = x_classification_id;
         END IF;
        end if;
    else
        if(l_approval_status <> 'APPROVED' ) then
            x_modified := 'Y';
            update pos_bus_class_attr
            set class_status = 'APPROVED'
            where classification_id = x_classification_id;
        end if;
    end if;
END;

/* Added as part of bug 5154822
 */
PROCEDURE CHECK_AND_MV_CLASS
(
    pPartyId in Number,
    pVendorId in Number,
    p_class_category in varchar2,
    p_class_code in varchar2,
    p_status in varchar2 ,
    x_classification_id out nocopy number
)
IS
l_modified varchar2(100);
BEGIN
    CHECK_AND_MV_CLASS(pPartyId, pVendorId, p_class_category,
            p_class_code, p_status, x_classification_id,
            l_modified);
END;

/* Added as part of bug 5154822
 */
PROCEDURE SYNCHRONIZE_CLASS_PO_TO_TCA
( pPartyId in Number,
  pVendorId in Number
)
IS
l_women varchar2(1);
l_minority varchar2( 100 );
l_minority_owned varchar2( 1);
l_small_business varchar2( 1);
l_small_business_status varchar2( 1);
l_last_update_date date;
l_exception_msg varchar2(1000);
l_status varchar2(100);
l_classification_id number;
l_test_id number;
l_updated varchar2(100);
BEGIN
    select decode(WOMEN_OWNED_FLAG, 'Y', 'Y','N'), decode (SMALL_BUSINESS_FLAG, 'Y','Y','N'),
    MINORITY_GROUP_LOOKUP_CODE, last_update_date
    into l_women, l_small_business, l_minority, l_last_update_date
    from ap_suppliers
    where vendor_id = pVendorId;

    CHECK_AND_MV_CLASS
        (
            pPartyId,
            pVendorId,
            BUSINESS_CLASSIFICATION,
            WOMEN_OWNED,
            l_women,
            l_classification_id
        );

    CHECK_AND_MV_CLASS
        (
            pPartyId,
            pVendorId,
            BUSINESS_CLASSIFICATION,
            SMALL_BUSINESS,
            l_small_business,
            l_classification_id
        );

    if( l_minority is not null ) then
        l_minority_owned := 'Y';
        CHECK_AND_MV_CLASS
        (
            pPartyId,
            pVendorId,
            BUSINESS_CLASSIFICATION,
            MINORITY_OWNED,
            l_minority_owned,
            l_classification_id
        );

        if(l_classification_id is not null ) then
            update pos_bus_class_attr
            set ext_attr_1 = l_minority
            where classification_id = l_classification_id;
        end if;
    else
        l_minority_owned := 'N';
        CHECK_AND_MV_CLASS
        (
            pPartyId,
            pVendorId,
            BUSINESS_CLASSIFICATION,
            MINORITY_OWNED,
            l_minority_owned,
            l_classification_id,
            l_updated
        );
         if(l_classification_id is not null AND l_updated ='Y') then
            update pos_bus_class_attr
            set ext_attr_1 = l_minority
            where classification_id = l_classification_id;
        end if;
    end if;

END SYNCHRONIZE_CLASS_PO_TO_TCA;

PROCEDURE remove_classification( pClassificationId in number)
IS
BEGIN
        update pos_bus_class_attr
            set status='I', last_update_date = sysdate,
            last_updated_by = fnd_global.user_id,
            end_date_active = sysdate
            where classification_id = pClassificationId;
END;

END POS_SUPP_CLASSIFICATION_PKG;

/
