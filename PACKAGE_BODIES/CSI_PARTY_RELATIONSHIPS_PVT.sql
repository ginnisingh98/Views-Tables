--------------------------------------------------------
--  DDL for Package Body CSI_PARTY_RELATIONSHIPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_PARTY_RELATIONSHIPS_PVT" AS
/* $Header: csivipb.pls 120.12.12010000.4 2010/03/17 00:26:14 hyonlee ship $ */


g_pkg_name     CONSTANT VARCHAR2(30)  := 'CSI_PARTY_RELATIONSHIPS_PVT';
g_expire_party_flag      VARCHAR2(1)  := 'N';
--g_expire_account_flag    VARCHAR2(1)  := 'N'; -- Commented by sguthiva for bug 2307804
--g_force_expire_flag      VARCHAR2(1)  := 'N'; -- Commented by sguthiva for bug 2307804
--g_contract_event_type    VARCHAR2(30) := NULL;-- Commented by sguthiva for bug 2307804


/*----------------------------------------------------------*/
/* Procedure name:  Initialize_acct_rec_no_dump             */
/* Description : This procudure gets the first record       */
/*                 from the history                         */
/*----------------------------------------------------------*/

PROCEDURE Initialize_acct_rec_no_dump
(
  x_party_account_rec       IN OUT NOCOPY   csi_datastructures_pub.party_account_header_rec,
  p_ip_account_id           IN NUMBER ,
  x_first_no_dump           IN OUT NOCOPY   DATE
  ) IS

CURSOR Int_first_no_dump(i_ip_acct_id IN NUMBER ) IS
SELECT
    CREATION_DATE                   ,
    NEW_RELATIONSHIP_TYPE_CODE      ,
    NEW_ACTIVE_START_DATE           ,
    NEW_ACTIVE_END_DATE             ,
    NEW_CONTEXT                     ,
    NEW_ATTRIBUTE1                  ,
    NEW_ATTRIBUTE2                  ,
    NEW_ATTRIBUTE3                  ,
    NEW_ATTRIBUTE4                  ,
    NEW_ATTRIBUTE5                  ,
    NEW_ATTRIBUTE6                  ,
    NEW_ATTRIBUTE7                  ,
    NEW_ATTRIBUTE8                  ,
    NEW_ATTRIBUTE9                  ,
    NEW_ATTRIBUTE10                 ,
    NEW_ATTRIBUTE11                 ,
    NEW_ATTRIBUTE12                 ,
    NEW_ATTRIBUTE13                 ,
    NEW_ATTRIBUTE14                 ,
    NEW_ATTRIBUTE15                 ,
    NEW_BILL_TO_ADDRESS             ,
    NEW_SHIP_TO_ADDRESS
 FROM CSI_IP_ACCOUNTS_H
WHERE ip_account_id = i_ip_acct_id
  --and  full_dump_flag = 'N'
  --and  creation_date < x_first_no_dump
  order by creation_date;

BEGIN

  FOR C1 IN Int_first_no_dump(p_ip_account_id  ) LOOP
   IF Int_first_no_dump%ROWCOUNT = 1 THEN
     x_first_no_dump            :=  C1.creation_date;
     x_party_account_rec.RELATIONSHIP_TYPE_CODE := C1.NEW_RELATIONSHIP_TYPE_CODE;
     x_party_account_rec.ACTIVE_START_DATE  := C1.NEW_ACTIVE_START_DATE;
     x_party_account_rec.ACTIVE_END_DATE    := C1.NEW_ACTIVE_END_DATE;
     x_party_account_rec.CONTEXT            := C1.NEW_CONTEXT;
     x_party_account_rec.ATTRIBUTE1         := C1.NEW_ATTRIBUTE1;
     x_party_account_rec.ATTRIBUTE2         := C1.NEW_ATTRIBUTE2;
     x_party_account_rec.ATTRIBUTE3         := C1.NEW_ATTRIBUTE3;
     x_party_account_rec.ATTRIBUTE4         := C1.NEW_ATTRIBUTE4;
     x_party_account_rec.ATTRIBUTE5         := C1.NEW_ATTRIBUTE5;
     x_party_account_rec.ATTRIBUTE6         := C1.NEW_ATTRIBUTE6;
     x_party_account_rec.ATTRIBUTE7         := C1.NEW_ATTRIBUTE7;
     x_party_account_rec.ATTRIBUTE8         := C1.NEW_ATTRIBUTE8;
     x_party_account_rec.ATTRIBUTE9         := C1.NEW_ATTRIBUTE9;
     x_party_account_rec.ATTRIBUTE10        := C1.NEW_ATTRIBUTE10;
     x_party_account_rec.ATTRIBUTE11        := C1.NEW_ATTRIBUTE11;
     x_party_account_rec.ATTRIBUTE12        := C1.NEW_ATTRIBUTE12;
     x_party_account_rec.ATTRIBUTE13        := C1.NEW_ATTRIBUTE13;
     x_party_account_rec.ATTRIBUTE14        := C1.NEW_ATTRIBUTE14;
     x_party_account_rec.ATTRIBUTE15        := C1.NEW_ATTRIBUTE15;
     x_party_account_rec.BILL_TO_ADDRESS    := C1.NEW_BILL_TO_ADDRESS;
     x_party_account_rec.SHIP_TO_ADDRESS    := C1.NEW_SHIP_TO_ADDRESS;
   ELSE
     EXIT;
   END IF;

  END LOOP;
END Initialize_acct_rec_no_dump;

/*----------------------------------------------------------*/
/* Procedure name:  Initialize_acct_rec                     */
/* Description : This procudure recontructs the record      */
/*                 from the history                         */
/*----------------------------------------------------------*/

PROCEDURE Initialize_acct_rec
(
  x_party_account_rec           IN OUT NOCOPY  csi_datastructures_pub.party_account_header_rec,
  p_ip_account_hist_id          IN NUMBER ,
  x_nearest_full_dump           IN OUT NOCOPY  DATE
  ) IS

CURSOR Int_nearest_full_dump(p_ip_acct_hist_id IN NUMBER ) IS
SELECT
    CREATION_DATE                   ,
    NEW_RELATIONSHIP_TYPE_CODE      ,
    NEW_ACTIVE_START_DATE           ,
    NEW_ACTIVE_END_DATE             ,
    NEW_CONTEXT                     ,
    NEW_ATTRIBUTE1                  ,
    NEW_ATTRIBUTE2                  ,
    NEW_ATTRIBUTE3                  ,
    NEW_ATTRIBUTE4                  ,
    NEW_ATTRIBUTE5                  ,
    NEW_ATTRIBUTE6                  ,
    NEW_ATTRIBUTE7                  ,
    NEW_ATTRIBUTE8                  ,
    NEW_ATTRIBUTE9                  ,
    NEW_ATTRIBUTE10                 ,
    NEW_ATTRIBUTE11                 ,
    NEW_ATTRIBUTE12                 ,
    NEW_ATTRIBUTE13                 ,
    NEW_ATTRIBUTE14                 ,
    NEW_ATTRIBUTE15                 ,
    NEW_BILL_TO_ADDRESS             ,
    NEW_SHIP_TO_ADDRESS
 FROM CSI_IP_ACCOUNTS_H
WHERE ip_account_history_id = p_ip_acct_hist_id
  and  full_dump_flag = 'Y';

BEGIN

  FOR C1 IN Int_nearest_full_dump(p_ip_account_hist_id  ) LOOP
     x_nearest_full_dump            := C1.creation_date;
     x_party_account_rec.RELATIONSHIP_TYPE_CODE := C1.NEW_RELATIONSHIP_TYPE_CODE;
     x_party_account_rec.ACTIVE_START_DATE  := C1.NEW_ACTIVE_START_DATE;
     x_party_account_rec.ACTIVE_END_DATE    := C1.NEW_ACTIVE_END_DATE;
     x_party_account_rec.CONTEXT            := C1.NEW_CONTEXT;
     x_party_account_rec.ATTRIBUTE1         := C1.NEW_ATTRIBUTE1;
     x_party_account_rec.ATTRIBUTE2         := C1.NEW_ATTRIBUTE2;
     x_party_account_rec.ATTRIBUTE3         := C1.NEW_ATTRIBUTE3;
     x_party_account_rec.ATTRIBUTE4         := C1.NEW_ATTRIBUTE4;
     x_party_account_rec.ATTRIBUTE5         := C1.NEW_ATTRIBUTE5;
     x_party_account_rec.ATTRIBUTE6         := C1.NEW_ATTRIBUTE6;
     x_party_account_rec.ATTRIBUTE7         := C1.NEW_ATTRIBUTE7;
     x_party_account_rec.ATTRIBUTE8         := C1.NEW_ATTRIBUTE8;
     x_party_account_rec.ATTRIBUTE9         := C1.NEW_ATTRIBUTE9;
     x_party_account_rec.ATTRIBUTE10        := C1.NEW_ATTRIBUTE10;
     x_party_account_rec.ATTRIBUTE11        := C1.NEW_ATTRIBUTE11;
     x_party_account_rec.ATTRIBUTE12        := C1.NEW_ATTRIBUTE12;
     x_party_account_rec.ATTRIBUTE13        := C1.NEW_ATTRIBUTE13;
     x_party_account_rec.ATTRIBUTE14        := C1.NEW_ATTRIBUTE14;
     x_party_account_rec.ATTRIBUTE15        := C1.NEW_ATTRIBUTE15;
     x_party_account_rec.BILL_TO_ADDRESS    := C1.NEW_BILL_TO_ADDRESS;
     x_party_account_rec.SHIP_TO_ADDRESS    := C1.NEW_SHIP_TO_ADDRESS;

  END LOOP;
END Initialize_acct_rec ;


/*----------------------------------------------------------*/
/* Procedure name:  Construct_acct_from_hist                */
/* Description : This procudure recontructs the record      */
/*                 from the history                         */
/*----------------------------------------------------------*/

PROCEDURE Construct_acct_from_hist
(
  x_party_account_tbl      IN OUT NOCOPY  csi_datastructures_pub.party_account_header_tbl,
  p_time_stamp             IN DATE
   ) IS

 l_nearest_full_dump      DATE := sysdate;
 l_ip_account_hist_id     NUMBER;
 l_party_account_tbl      csi_datastructures_pub.party_account_header_tbl;
 l_acct_count             NUMBER := 0;
 --
 Process_next             EXCEPTION;

CURSOR get_nearest_full_dump(p_ip_acct_id IN NUMBER ,p_time IN DATE) IS
SELECT
  MAX(ip_account_history_id)
FROM CSI_IP_ACCOUNTS_H
WHERE creation_date <= p_time
  and ip_account_id = p_ip_acct_id
  and  full_dump_flag = 'Y' ;


CURSOR get_ip_acct_hist (p_ip_account_id IN NUMBER ,
                         p_nearest_full_dump IN DATE,
                         p_time IN DATE ) IS
SELECT
    OLD_PARTY_ACCOUNT_ID            ,
    NEW_PARTY_ACCOUNT_ID            ,
    OLD_RELATIONSHIP_TYPE_CODE      ,
    NEW_RELATIONSHIP_TYPE_CODE      ,
    OLD_ACTIVE_START_DATE           ,
    NEW_ACTIVE_START_DATE           ,
    OLD_ACTIVE_END_DATE             ,
    NEW_ACTIVE_END_DATE             ,
    OLD_CONTEXT                     ,
    NEW_CONTEXT                     ,
    OLD_ATTRIBUTE1                  ,
    NEW_ATTRIBUTE1                  ,
    OLD_ATTRIBUTE2                  ,
    NEW_ATTRIBUTE2                  ,
    OLD_ATTRIBUTE3                  ,
    NEW_ATTRIBUTE3                  ,
    OLD_ATTRIBUTE4                  ,
    NEW_ATTRIBUTE4                  ,
    OLD_ATTRIBUTE5                  ,
    NEW_ATTRIBUTE5                  ,
    OLD_ATTRIBUTE6                  ,
    NEW_ATTRIBUTE6                  ,
    OLD_ATTRIBUTE7                  ,
    NEW_ATTRIBUTE7                  ,
    OLD_ATTRIBUTE8                  ,
    NEW_ATTRIBUTE8                  ,
    OLD_ATTRIBUTE9                  ,
    NEW_ATTRIBUTE9                  ,
    OLD_ATTRIBUTE10                 ,
    NEW_ATTRIBUTE10                 ,
    OLD_ATTRIBUTE11                 ,
    NEW_ATTRIBUTE11                 ,
    OLD_ATTRIBUTE12                 ,
    NEW_ATTRIBUTE12                 ,
    OLD_ATTRIBUTE13                 ,
    NEW_ATTRIBUTE13                 ,
    OLD_ATTRIBUTE14                 ,
    NEW_ATTRIBUTE14                 ,
    OLD_ATTRIBUTE15                 ,
    NEW_ATTRIBUTE15                 ,
    OLD_BILL_TO_ADDRESS             ,
    NEW_BILL_TO_ADDRESS             ,
    OLD_SHIP_TO_ADDRESS             ,
    NEW_SHIP_TO_ADDRESS
 FROM CSI_IP_ACCOUNTS_H
WHERE creation_date <= p_time
  and creation_date >= p_nearest_full_dump
  and ip_account_id = p_ip_account_id
  ORDER BY creation_date;

  l_time_stamp  DATE := p_time_stamp;

BEGIN
l_party_account_tbl := x_party_account_tbl;
IF  l_party_account_tbl.count > 0 THEN
  FOR i IN l_party_account_tbl.FIRST..l_party_account_tbl.LAST LOOP
  BEGIN
    OPEN get_nearest_full_dump(l_party_account_tbl(i).ip_account_id,p_time_stamp);
    FETCH get_nearest_full_dump INTO l_ip_account_hist_id;
    CLOSE get_nearest_full_dump;

    IF l_ip_account_hist_id IS NOT NULL THEN
      Initialize_acct_rec( l_party_account_tbl(i), l_ip_account_hist_id ,l_nearest_full_dump);
    ELSE
       Initialize_acct_rec_no_dump(l_party_account_tbl(i), l_party_account_tbl(i).ip_account_id, l_time_stamp);
           l_nearest_full_dump :=  l_time_stamp;
           -- If the user chooses a date before the creation date of the instance
           -- then raise an error
           IF p_time_stamp < l_time_stamp THEN
              -- Messages Commented for bug 2423342. Records that do not qualify should get deleted.
              -- FND_MESSAGE.SET_NAME('CSI','CSI_H_DATE_BEFORE_CRE_DATE');
              -- FND_MESSAGE.SET_TOKEN('CREATION_DATE',to_char(l_time_stamp, 'DD-MON-YYYY HH24:MI:SS'));
              -- FND_MESSAGE.SET_TOKEN('USER_DATE',to_char(p_time_stamp, 'DD-MON-YYYY HH24:MI:SS'));
              -- FND_MSG_PUB.Add;
              -- RAISE FND_API.G_EXC_ERROR;
              l_party_account_tbl.DELETE(i);
              RAISE Process_next;
           END IF;
    END IF;


    FOR C2 IN get_ip_acct_hist(l_party_account_tbl(i).ip_account_id ,l_nearest_full_dump,p_time_stamp ) LOOP

       IF (C2.OLD_RELATIONSHIP_TYPE_CODE IS NULL AND C2.NEW_RELATIONSHIP_TYPE_CODE IS NOT NULL)
       OR (C2.OLD_RELATIONSHIP_TYPE_CODE IS NOT NULL AND C2.NEW_RELATIONSHIP_TYPE_CODE IS NULL)
       OR (C2.OLD_RELATIONSHIP_TYPE_CODE <> C2.NEW_RELATIONSHIP_TYPE_CODE) THEN
         l_party_account_tbl(i).RELATIONSHIP_TYPE_CODE := C2.NEW_RELATIONSHIP_TYPE_CODE;
       END IF;

       IF (C2.OLD_PARTY_ACCOUNT_ID IS NULL AND C2.NEW_PARTY_ACCOUNT_ID IS NOT NULL)
       OR (C2.OLD_PARTY_ACCOUNT_ID IS NOT NULL AND C2.NEW_PARTY_ACCOUNT_ID IS NULL)
       OR (C2.OLD_PARTY_ACCOUNT_ID <> C2.NEW_PARTY_ACCOUNT_ID) THEN
            l_party_account_tbl(i).PARTY_ACCOUNT_ID := C2.NEW_PARTY_ACCOUNT_ID;
       END IF;


       IF (C2.OLD_ACTIVE_START_DATE IS NULL AND C2.NEW_ACTIVE_START_DATE IS NOT NULL)
       OR (C2.OLD_ACTIVE_START_DATE IS NOT NULL AND C2.NEW_ACTIVE_START_DATE IS NULL)
       OR (C2.OLD_ACTIVE_START_DATE <> C2.NEW_ACTIVE_START_DATE) THEN
            l_party_account_tbl(i).ACTIVE_START_DATE := C2.NEW_ACTIVE_START_DATE;
       END IF;


       IF (C2.OLD_ACTIVE_END_DATE IS NULL AND C2.NEW_ACTIVE_END_DATE IS NOT NULL)
       OR (C2.OLD_ACTIVE_END_DATE IS NOT NULL AND C2.NEW_ACTIVE_END_DATE IS NULL)
       OR (C2.OLD_ACTIVE_END_DATE <> C2.NEW_ACTIVE_END_DATE) THEN
            l_party_account_tbl(i).ACTIVE_END_DATE := C2.NEW_ACTIVE_END_DATE;
       END IF;


       IF (C2.OLD_CONTEXT IS NULL AND C2.NEW_CONTEXT IS NOT NULL)
       OR (C2.OLD_CONTEXT IS NOT NULL AND C2.NEW_CONTEXT IS NULL)
       OR (C2.OLD_CONTEXT <> C2.NEW_CONTEXT) THEN
            l_party_account_tbl(i).CONTEXT := C2.NEW_CONTEXT;
       END IF;

       IF (C2.OLD_ATTRIBUTE1 IS NULL AND C2.NEW_ATTRIBUTE1 IS NOT NULL)
       OR (C2.OLD_ATTRIBUTE1 IS NOT NULL AND C2.NEW_ATTRIBUTE1 IS NULL)
       OR (C2.OLD_ATTRIBUTE1 <> C2.NEW_ATTRIBUTE1) THEN
            l_party_account_tbl(i).ATTRIBUTE1 := C2.NEW_ATTRIBUTE1;
       END IF;

       IF (C2.OLD_ATTRIBUTE2 IS NULL AND C2.NEW_ATTRIBUTE2 IS NOT NULL)
       OR (C2.OLD_ATTRIBUTE2 IS NOT NULL AND C2.NEW_ATTRIBUTE2 IS NULL)
       OR (C2.OLD_ATTRIBUTE2 <> C2.NEW_ATTRIBUTE2) THEN
            l_party_account_tbl(i).ATTRIBUTE2 := C2.NEW_ATTRIBUTE2;
       END IF;

       IF (C2.OLD_ATTRIBUTE3 IS NULL AND C2.NEW_ATTRIBUTE3 IS NOT NULL)
       OR (C2.OLD_ATTRIBUTE3 IS NOT NULL AND C2.NEW_ATTRIBUTE3 IS NULL)
       OR (C2.OLD_ATTRIBUTE3 <> C2.NEW_ATTRIBUTE3) THEN
            l_party_account_tbl(i).ATTRIBUTE3 := C2.NEW_ATTRIBUTE3;
       END IF;

       IF (C2.OLD_ATTRIBUTE4 IS NULL AND C2.NEW_ATTRIBUTE4 IS NOT NULL)
       OR (C2.OLD_ATTRIBUTE4 IS NOT NULL AND C2.NEW_ATTRIBUTE4 IS NULL)
       OR (C2.OLD_ATTRIBUTE4 <> C2.NEW_ATTRIBUTE4) THEN
            l_party_account_tbl(i).ATTRIBUTE4 := C2.NEW_ATTRIBUTE4;
       END IF;


       IF (C2.OLD_ATTRIBUTE5 IS NULL AND C2.NEW_ATTRIBUTE5 IS NOT NULL)
       OR (C2.OLD_ATTRIBUTE5 IS NOT NULL AND C2.NEW_ATTRIBUTE5 IS NULL)
       OR (C2.OLD_ATTRIBUTE5 <> C2.NEW_ATTRIBUTE5) THEN
            l_party_account_tbl(i).ATTRIBUTE5 := C2.NEW_ATTRIBUTE5;
       END IF;


       IF (C2.OLD_ATTRIBUTE6 IS NULL AND C2.NEW_ATTRIBUTE6 IS NOT NULL)
       OR (C2.OLD_ATTRIBUTE6 IS NOT NULL AND C2.NEW_ATTRIBUTE6 IS NULL)
       OR (C2.OLD_ATTRIBUTE6 <> C2.NEW_ATTRIBUTE6) THEN
            l_party_account_tbl(i).ATTRIBUTE6 := C2.NEW_ATTRIBUTE6;
       END IF;

       IF (C2.OLD_ATTRIBUTE7 IS NULL AND C2.NEW_ATTRIBUTE7 IS NOT NULL)
       OR (C2.OLD_ATTRIBUTE7 IS NOT NULL AND C2.NEW_ATTRIBUTE7 IS NULL)
       OR (C2.OLD_ATTRIBUTE7 <> C2.NEW_ATTRIBUTE7) THEN
            l_party_account_tbl(i).ATTRIBUTE7 := C2.NEW_ATTRIBUTE7;
       END IF;

       IF (C2.OLD_ATTRIBUTE8 IS NULL AND C2.NEW_ATTRIBUTE8 IS NOT NULL)
       OR (C2.OLD_ATTRIBUTE8 IS NOT NULL AND C2.NEW_ATTRIBUTE8 IS NULL)
       OR (C2.OLD_ATTRIBUTE8 <> C2.NEW_ATTRIBUTE8) THEN
            l_party_account_tbl(i).ATTRIBUTE8 := C2.NEW_ATTRIBUTE8;
       END IF;

       IF (C2.OLD_ATTRIBUTE9 IS NULL AND C2.NEW_ATTRIBUTE9 IS NOT NULL)
       OR (C2.OLD_ATTRIBUTE9 IS NOT NULL AND C2.NEW_ATTRIBUTE9 IS NULL)
       OR (C2.OLD_ATTRIBUTE9 <> C2.NEW_ATTRIBUTE9) THEN
            l_party_account_tbl(i).ATTRIBUTE3 := C2.NEW_ATTRIBUTE3;
       END IF;


       IF (C2.OLD_ATTRIBUTE10 IS NULL AND C2.NEW_ATTRIBUTE10 IS NOT NULL)
       OR (C2.OLD_ATTRIBUTE10 IS NOT NULL AND C2.NEW_ATTRIBUTE10 IS NULL)
       OR (C2.OLD_ATTRIBUTE10 <> C2.NEW_ATTRIBUTE10) THEN
            l_party_account_tbl(i).ATTRIBUTE10 := C2.NEW_ATTRIBUTE10;
       END IF;



       IF (C2.OLD_ATTRIBUTE11 IS NULL AND C2.NEW_ATTRIBUTE11 IS NOT NULL)
       OR (C2.OLD_ATTRIBUTE11 IS NOT NULL AND C2.NEW_ATTRIBUTE11 IS NULL)
       OR (C2.OLD_ATTRIBUTE11 <> C2.NEW_ATTRIBUTE11) THEN
            l_party_account_tbl(i).ATTRIBUTE11 := C2.NEW_ATTRIBUTE11;
       END IF;

       IF (C2.OLD_ATTRIBUTE12 IS NULL AND C2.NEW_ATTRIBUTE12 IS NOT NULL)
       OR (C2.OLD_ATTRIBUTE12 IS NOT NULL AND C2.NEW_ATTRIBUTE12 IS NULL)
       OR (C2.OLD_ATTRIBUTE12 <> C2.NEW_ATTRIBUTE12) THEN
            l_party_account_tbl(i).ATTRIBUTE12 := C2.NEW_ATTRIBUTE12;
       END IF;


       IF (C2.OLD_ATTRIBUTE13 IS NULL AND C2.NEW_ATTRIBUTE13 IS NOT NULL)
       OR (C2.OLD_ATTRIBUTE13 IS NOT NULL AND C2.NEW_ATTRIBUTE13 IS NULL)
       OR (C2.OLD_ATTRIBUTE13 <> C2.NEW_ATTRIBUTE13) THEN
            l_party_account_tbl(i).ATTRIBUTE13 := C2.NEW_ATTRIBUTE13;
       END IF;


       IF (C2.OLD_ATTRIBUTE14 IS NULL AND C2.NEW_ATTRIBUTE14 IS NOT NULL)
       OR (C2.OLD_ATTRIBUTE14 IS NOT NULL AND C2.NEW_ATTRIBUTE14 IS NULL)
       OR (C2.OLD_ATTRIBUTE14 <> C2.NEW_ATTRIBUTE14) THEN
            l_party_account_tbl(i).ATTRIBUTE14 := C2.NEW_ATTRIBUTE14;
       END IF;

       IF (C2.OLD_ATTRIBUTE15 IS NULL AND C2.NEW_ATTRIBUTE15 IS NOT NULL)
       OR (C2.OLD_ATTRIBUTE15 IS NOT NULL AND C2.NEW_ATTRIBUTE15 IS NULL)
       OR (C2.OLD_ATTRIBUTE15 <> C2.NEW_ATTRIBUTE15) THEN
            l_party_account_tbl(i).ATTRIBUTE15 := C2.NEW_ATTRIBUTE15;
       END IF;

       IF (C2.OLD_BILL_TO_ADDRESS IS NULL AND C2.NEW_BILL_TO_ADDRESS IS NOT NULL)
       OR (C2.OLD_BILL_TO_ADDRESS IS NOT NULL AND C2.NEW_BILL_TO_ADDRESS IS NULL)
       OR (C2.OLD_BILL_TO_ADDRESS <> C2.NEW_BILL_TO_ADDRESS) THEN
            l_party_account_tbl(i).BILL_TO_ADDRESS := C2.NEW_BILL_TO_ADDRESS;
       END IF;

       IF (C2.OLD_SHIP_TO_ADDRESS IS NULL AND C2.NEW_SHIP_TO_ADDRESS IS NOT NULL)
       OR (C2.OLD_SHIP_TO_ADDRESS IS NOT NULL AND C2.NEW_SHIP_TO_ADDRESS IS NULL)
       OR (C2.OLD_SHIP_TO_ADDRESS <> C2.NEW_SHIP_TO_ADDRESS) THEN
            l_party_account_tbl(i).SHIP_TO_ADDRESS := C2.NEW_SHIP_TO_ADDRESS;
       END IF;

     END LOOP;
   EXCEPTION
      WHEN Process_next THEN
         NULL;
   END;
 END LOOP;
 x_party_account_tbl.DELETE;
 IF l_party_account_tbl.count > 0 THEN
    FOR acct_row in l_party_account_tbl.FIRST .. l_party_account_tbl.LAST
    LOOP
       IF l_party_account_tbl.EXISTS(acct_row) THEN
          l_acct_count := l_acct_count + 1;
          x_party_account_tbl(l_acct_count) := l_party_account_tbl(acct_row);
       END IF;
    END LOOP;
 END IF;
END IF;
END Construct_acct_from_hist;

/*----------------------------------------------------------*/
/* Procedure name:  Resolve_id_columns                      */
/* Description : This procudure gets the descriptions for   */
/*               id columns                                 */
/*----------------------------------------------------------*/

PROCEDURE  Resolve_id_columns
            (p_account_header_tbl  IN OUT NOCOPY    csi_datastructures_pub.party_account_header_tbl)

IS

   BEGIN

        FOR tab_row in p_account_header_tbl.FIRST..p_account_header_tbl.LAST
           LOOP

             BEGIN
               SELECT account_number,
                      account_name
               INTO   p_account_header_tbl(tab_row).party_account_number,
                      p_account_header_tbl(tab_row).party_account_name
               FROM   hz_cust_accounts
               WHERE  cust_account_id = p_account_header_tbl(tab_row).party_account_id;
             EXCEPTION
               WHEN no_data_found THEN
                   NULL;
             END;

    -- Added for bug 2670371
             BEGIN
               SELECT hl.address1
                     ,hl.address2
                     ,hl.address3
                     ,hl.address4
                     ,hl.city
                     ,hl.state
                     ,hl.postal_code
                     ,hl.country
               INTO   p_account_header_tbl(tab_row).bill_to_address1
                     ,p_account_header_tbl(tab_row).bill_to_address2
                     ,p_account_header_tbl(tab_row).bill_to_address3
                     ,p_account_header_tbl(tab_row).bill_to_address4
                     ,p_account_header_tbl(tab_row).bill_to_city
                     ,p_account_header_tbl(tab_row).bill_to_state
                     ,p_account_header_tbl(tab_row).bill_to_postal_code
                     ,p_account_header_tbl(tab_row).bill_to_country
               FROM   hz_cust_site_uses_all hcs
                     ,hz_cust_acct_sites_all hca
                     ,hz_party_sites hps
                     ,hz_locations hl
               WHERE hcs.cust_acct_site_id=hca.cust_acct_site_id
               AND   hca.party_site_id=hps.party_site_id
               AND   hps.location_id=hl.location_id
               AND   hcs.site_use_id=p_account_header_tbl(tab_row).bill_to_address
               AND   hcs.site_use_code = 'BILL_TO';
             EXCEPTION
               WHEN no_data_found THEN
                   NULL;
             END;

             BEGIN
               SELECT hl.address1
                     ,hl.address2
                     ,hl.address3
                     ,hl.address4
                     ,hl.city
                     ,hl.state
                     ,hl.postal_code
                     ,hl.country
               INTO   p_account_header_tbl(tab_row).ship_to_address1
                     ,p_account_header_tbl(tab_row).ship_to_address2
                     ,p_account_header_tbl(tab_row).ship_to_address3
                     ,p_account_header_tbl(tab_row).ship_to_address4
                     ,p_account_header_tbl(tab_row).ship_to_city
                     ,p_account_header_tbl(tab_row).ship_to_state
                     ,p_account_header_tbl(tab_row).ship_to_postal_code
                     ,p_account_header_tbl(tab_row).ship_to_country
               FROM   hz_cust_site_uses_all hcs
                     ,hz_cust_acct_sites_all hca
                     ,hz_party_sites hps
                     ,hz_locations hl
               WHERE hcs.cust_acct_site_id=hca.cust_acct_site_id
               AND   hca.party_site_id=hps.party_site_id
               AND   hps.location_id=hl.location_id
               AND   hcs.site_use_id=p_account_header_tbl(tab_row).ship_to_address
               AND   hcs.site_use_code = 'SHIP_TO';
             EXCEPTION
               WHEN no_data_found THEN
                   NULL;
             END;

-- End addition for bug 2670371
/* Commented for bug 2670371
             BEGIN
               SELECT location
               INTO   p_account_header_tbl(tab_row).bill_to_location
               FROM   hz_cust_site_uses_all
               WHERE  site_use_id   =  p_account_header_tbl(tab_row).bill_to_address
               AND    site_use_code = 'BILL_TO';
             EXCEPTION
               WHEN no_data_found THEN
                   NULL;
             END;

             BEGIN
               SELECT location
               INTO   p_account_header_tbl(tab_row).ship_to_location
               FROM   hz_cust_site_uses_all
               WHERE  site_use_id   =  p_account_header_tbl(tab_row).ship_to_address
               AND    site_use_code = 'SHIP_TO';
             EXCEPTION
               WHEN no_data_found THEN
                   NULL;
             END;
*/
--  End comment for bug 2670371
        END LOOP;

END Resolve_id_columns;

/*----------------------------------------------------------*/
/* Procedure name:  Get_acct_Column_Values                  */
/* Description : This procudure gets the column values      */
/*                        for the Dynamic SQL               */
/*----------------------------------------------------------*/

PROCEDURE Get_acct_Column_Values
(
    p_get_acct_cursor_id      IN   NUMBER      ,
    x_pty_acct_query_rec      OUT NOCOPY    csi_datastructures_pub.party_account_header_rec
    ) IS

BEGIN

 dbms_sql.column_value(p_get_acct_cursor_id, 1, x_pty_acct_query_rec.ip_account_id);
 dbms_sql.column_value(p_get_acct_cursor_id, 2, x_pty_acct_query_rec.instance_party_id);
 dbms_sql.column_value(p_get_acct_cursor_id, 3, x_pty_acct_query_rec.party_account_id);
 dbms_sql.column_value(p_get_acct_cursor_id, 4, x_pty_acct_query_rec.relationship_type_code );
 dbms_sql.column_value(p_get_acct_cursor_id, 5, x_pty_acct_query_rec.active_start_date);
 dbms_sql.column_value(p_get_acct_cursor_id, 6, x_pty_acct_query_rec.active_end_date);
 dbms_sql.column_value(p_get_acct_cursor_id, 7, x_pty_acct_query_rec.context);
 dbms_sql.column_value(p_get_acct_cursor_id, 8, x_pty_acct_query_rec.attribute1);
 dbms_sql.column_value(p_get_acct_cursor_id, 9, x_pty_acct_query_rec.attribute2);
 dbms_sql.column_value(p_get_acct_cursor_id, 10, x_pty_acct_query_rec.attribute3);
 dbms_sql.column_value(p_get_acct_cursor_id, 11, x_pty_acct_query_rec.attribute4);
 dbms_sql.column_value(p_get_acct_cursor_id, 12, x_pty_acct_query_rec.attribute5);
 dbms_sql.column_value(p_get_acct_cursor_id, 13, x_pty_acct_query_rec.attribute6);
 dbms_sql.column_value(p_get_acct_cursor_id, 14, x_pty_acct_query_rec.attribute7);
 dbms_sql.column_value(p_get_acct_cursor_id, 15, x_pty_acct_query_rec.attribute8);
 dbms_sql.column_value(p_get_acct_cursor_id, 16, x_pty_acct_query_rec.attribute9);
 dbms_sql.column_value(p_get_acct_cursor_id, 17, x_pty_acct_query_rec.attribute10);
 dbms_sql.column_value(p_get_acct_cursor_id, 18, x_pty_acct_query_rec.attribute11);
 dbms_sql.column_value(p_get_acct_cursor_id, 19, x_pty_acct_query_rec.attribute12);
 dbms_sql.column_value(p_get_acct_cursor_id, 20, x_pty_acct_query_rec.attribute13);
 dbms_sql.column_value(p_get_acct_cursor_id, 21, x_pty_acct_query_rec.attribute14);
 dbms_sql.column_value(p_get_acct_cursor_id, 22, x_pty_acct_query_rec.attribute15);
 dbms_sql.column_value(p_get_acct_cursor_id, 23, x_pty_acct_query_rec.object_version_number);
 dbms_sql.column_value(p_get_acct_cursor_id, 24, x_pty_acct_query_rec.bill_to_address);
 dbms_sql.column_value(p_get_acct_cursor_id, 25, x_pty_acct_query_rec.ship_to_address);

END Get_acct_Column_Values;

/*----------------------------------------------------------*/
/* Procedure name:  Define_Acct_Columns                     */
/* Description : This procudure defines the columns         */
/*                        for the Dynamic SQL               */
/*----------------------------------------------------------*/

PROCEDURE Define_Acct_Columns
(
  p_get_acct_cursor_id      IN   NUMBER
  ) IS
  l_party_acct_rec       csi_datastructures_pub.party_account_header_rec;
BEGIN

 dbms_sql.define_column(p_get_acct_cursor_id, 1, l_party_acct_rec.ip_account_id);
 dbms_sql.define_column(p_get_acct_cursor_id, 2, l_party_acct_rec.instance_party_id);
 dbms_sql.define_column(p_get_acct_cursor_id, 3, l_party_acct_rec.party_account_id);
 dbms_sql.define_column(p_get_acct_cursor_id, 4, l_party_acct_rec.relationship_type_code ,30);
 dbms_sql.define_column(p_get_acct_cursor_id, 5, l_party_acct_rec.active_start_date);
 dbms_sql.define_column(p_get_acct_cursor_id, 6, l_party_acct_rec.active_end_date);
 dbms_sql.define_column(p_get_acct_cursor_id, 7, l_party_acct_rec.context,30);
 dbms_sql.define_column(p_get_acct_cursor_id, 8, l_party_acct_rec.attribute1,150);
 dbms_sql.define_column(p_get_acct_cursor_id, 9, l_party_acct_rec.attribute2,150);
 dbms_sql.define_column(p_get_acct_cursor_id, 10, l_party_acct_rec.attribute3,150);
 dbms_sql.define_column(p_get_acct_cursor_id, 11, l_party_acct_rec.attribute4,150);
 dbms_sql.define_column(p_get_acct_cursor_id, 12, l_party_acct_rec.attribute5,150);
 dbms_sql.define_column(p_get_acct_cursor_id, 13, l_party_acct_rec.attribute6,150);
 dbms_sql.define_column(p_get_acct_cursor_id, 14, l_party_acct_rec.attribute7,150);
 dbms_sql.define_column(p_get_acct_cursor_id, 15, l_party_acct_rec.attribute8,150);
 dbms_sql.define_column(p_get_acct_cursor_id, 16, l_party_acct_rec.attribute9,150);
 dbms_sql.define_column(p_get_acct_cursor_id, 17, l_party_acct_rec.attribute10,150);
 dbms_sql.define_column(p_get_acct_cursor_id, 18, l_party_acct_rec.attribute11,150);
 dbms_sql.define_column(p_get_acct_cursor_id, 19, l_party_acct_rec.attribute12,150);
 dbms_sql.define_column(p_get_acct_cursor_id, 20, l_party_acct_rec.attribute13,150);
 dbms_sql.define_column(p_get_acct_cursor_id, 21, l_party_acct_rec.attribute14,150);
 dbms_sql.define_column(p_get_acct_cursor_id, 22, l_party_acct_rec.attribute15,150);
 dbms_sql.define_column(p_get_acct_cursor_id, 23, l_party_acct_rec.object_version_number);
 dbms_sql.define_column(p_get_acct_cursor_id, 24, l_party_acct_rec.bill_to_address);
 dbms_sql.define_column(p_get_acct_cursor_id, 25, l_party_acct_rec.ship_to_address);

END Define_Acct_Columns;


/*----------------------------------------------------------*/
/* Procedure name:  Bind_Acct_variable                      */
/* Description : Procedure used to  generate the where      */
/*                cluase  for Party relationship            */
/*----------------------------------------------------------*/

PROCEDURE Bind_Acct_variable
(
    p_pty_acct_query_rec   IN    csi_datastructures_pub.party_account_query_rec,
    p_get_acct_cursor_id   IN    NUMBER
    ) IS

BEGIN
 IF( (p_pty_acct_query_rec.ip_account_id IS NOT NULL)
                  AND (p_pty_acct_query_rec.ip_account_id <> FND_API.G_MISS_NUM))  THEN
    DBMS_SQL.BIND_VARIABLE(p_get_acct_cursor_id, ':ip_account_id', p_pty_acct_query_rec.ip_account_id);
 END IF;

 IF( (p_pty_acct_query_rec.instance_party_id IS NOT NULL)
                  AND (p_pty_acct_query_rec.instance_party_id <> FND_API.G_MISS_NUM))  THEN
    DBMS_SQL.BIND_VARIABLE(p_get_acct_cursor_id, ':instance_party_id', p_pty_acct_query_rec.instance_party_id);
 END IF;

 IF( (p_pty_acct_query_rec.party_account_id IS NOT NULL)
                  AND (p_pty_acct_query_rec.party_account_id <> FND_API.G_MISS_NUM))  THEN
    DBMS_SQL.BIND_VARIABLE(p_get_acct_cursor_id, ':party_account_id', p_pty_acct_query_rec.party_account_id);
 END IF;

 IF( (p_pty_acct_query_rec.relationship_type_code IS NOT NULL)
                  AND (p_pty_acct_query_rec.relationship_type_code <> FND_API.G_MISS_CHAR))  THEN
    DBMS_SQL.BIND_VARIABLE(p_get_acct_cursor_id, ':relationship_type_code', p_pty_acct_query_rec.relationship_type_code);
 END IF;

END ;


/*----------------------------------------------------------*/
/* Procedure name:  Gen_Acct_Where_Clause                   */
/* Description : Procedure used to  generate the where      */
/*                cluase  for Party relationship            */
/*----------------------------------------------------------*/

PROCEDURE Gen_Acct_Where_Clause
(
    p_pty_acct_query_rec      IN    csi_datastructures_pub.party_account_query_rec
   ,x_where_clause            OUT NOCOPY    VARCHAR2
    ) IS

BEGIN

 -- Assign null at the start
 x_where_clause := '';

IF (( p_pty_acct_query_rec.ip_account_id  IS NOT NULL)  AND
         ( p_pty_acct_query_rec.ip_account_id  <> FND_API.G_MISS_NUM)) THEN
     x_where_clause := ' ip_account_id = :ip_account_id ';
ELSIF ( p_pty_acct_query_rec.ip_account_id  IS NULL) THEN
     x_where_clause := ' ip_account_id IS NULL ';
END IF;

IF ((p_pty_acct_query_rec.instance_party_id IS NOT NULL) AND
       (p_pty_acct_query_rec.instance_party_id <> FND_API.G_MISS_NUM))   THEN
        IF x_where_clause IS NULL THEN
            x_where_clause := ' instance_party_id = :instance_party_id ';
        ELSE
            x_where_clause := x_where_clause||' AND '||' instance_party_id = :instance_party_id ';
        END IF;
ELSIF (p_pty_acct_query_rec.instance_party_id IS  NULL)  THEN
        IF x_where_clause IS NULL THEN
            x_where_clause := ' instance_party_id IS NULL ';
        ELSE
            x_where_clause := x_where_clause||' AND '||' instance_party_id IS NULL ';
        END IF;
END IF;

IF ((p_pty_acct_query_rec.party_account_id  IS NOT NULL)         AND
        (p_pty_acct_query_rec.party_account_id  <> FND_API.G_MISS_NUM)) THEN
        IF x_where_clause IS NULL THEN
            x_where_clause := ' party_account_id = :party_account_id ';
        ELSE
            x_where_clause := x_where_clause||' AND '||' party_account_id = :party_account_id ';
        END IF;
ELSIF (p_pty_acct_query_rec.party_account_id  IS NULL) THEN
        IF x_where_clause IS NULL THEN
            x_where_clause := ' party_account_id IS NULL';
        ELSE
            x_where_clause := x_where_clause||' AND '||' party_account_id IS NULL ';
        END IF;
END IF ;

IF  ((p_pty_acct_query_rec.relationship_type_code IS NOT NULL) AND
        (p_pty_acct_query_rec.relationship_type_code <> FND_API.G_MISS_CHAR)) THEN
        IF x_where_clause IS NULL THEN
            x_where_clause := '  relationship_type_code = :relationship_type_code ';
        ELSE
            x_where_clause := x_where_clause||' AND '||
                   '  relationship_type_code = :relationship_type_code ';
        END IF;
ELSIF (p_pty_acct_query_rec.relationship_type_code IS  NULL) THEN
        IF x_where_clause IS NULL THEN
            x_where_clause := '  relationship_type_code IS NULL ';
        ELSE
            x_where_clause := x_where_clause||' AND '||
                   '  relationship_type_code IS NULL ';
        END IF;
END IF;

END Gen_Acct_Where_Clause;

/*----------------------------------------------------------*/
/* Procedure name:  Initialize_pty_rec_no_dump              */
/* Description : This procudure returns the first record    */
/*                 from history                             */
/*----------------------------------------------------------*/

PROCEDURE Initialize_pty_rec_no_dump
(
  x_party_rec           IN OUT NOCOPY  csi_datastructures_pub.party_header_rec,
  p_inst_party_id       IN NUMBER,
  x_first_no_dump       IN OUT NOCOPY  DATE
   ) IS


CURSOR Int_first_no_dump(p_inst_pty_id IN NUMBER ) IS
SELECT
    CREATION_DATE                   ,
    NEW_PARTY_SOURCE_TABLE          ,
    NEW_PARTY_ID                    ,
    NEW_RELATIONSHIP_TYPE_CODE      ,
    NEW_CONTACT_FLAG                ,
    NEW_CONTACT_IP_ID               ,
    NEW_ACTIVE_START_DATE           ,
    NEW_ACTIVE_END_DATE             ,
    NEW_CONTEXT                     ,
    NEW_ATTRIBUTE1                  ,
    NEW_ATTRIBUTE2                  ,
    NEW_ATTRIBUTE3                  ,
    NEW_ATTRIBUTE4                  ,
    NEW_ATTRIBUTE5                  ,
    NEW_ATTRIBUTE6                  ,
    NEW_ATTRIBUTE7                  ,
    NEW_ATTRIBUTE8                  ,
    NEW_ATTRIBUTE9                  ,
    NEW_ATTRIBUTE10                 ,
    NEW_ATTRIBUTE11                 ,
    NEW_ATTRIBUTE12                 ,
    NEW_ATTRIBUTE13                 ,
    NEW_ATTRIBUTE14                 ,
    NEW_ATTRIBUTE15                 ,
    NEW_PRIMARY_FLAG                ,
    NEW_PREFERRED_FLAG
 FROM CSI_I_PARTIES_H
WHERE instance_party_id = p_inst_pty_id
--  and creation_date < x_first_no_dump
  -- and  full_dump_flag = 'N'
  order by creation_date;

BEGIN

  FOR C1 IN Int_first_no_dump(p_inst_party_id  ) LOOP
   IF Int_first_no_dump%ROWCOUNT = 1 THEN
     x_first_no_dump            := C1.creation_date;
     x_party_rec.PARTY_SOURCE_TABLE := C1.NEW_PARTY_SOURCE_TABLE;
     x_party_rec.PARTY_ID           := C1.NEW_PARTY_ID;
     x_party_rec.RELATIONSHIP_TYPE_CODE := C1.NEW_RELATIONSHIP_TYPE_CODE;
     x_party_rec.CONTACT_FLAG       := C1.NEW_CONTACT_FLAG;
     x_party_rec.CONTACT_IP_ID      := C1.NEW_CONTACT_IP_ID;
     x_party_rec.ACTIVE_START_DATE  := C1.NEW_ACTIVE_START_DATE;
     x_party_rec.ACTIVE_END_DATE    := C1.NEW_ACTIVE_END_DATE;
     x_party_rec.CONTEXT            := C1.NEW_CONTEXT;
     x_party_rec.ATTRIBUTE1         := C1.NEW_ATTRIBUTE1;
     x_party_rec.ATTRIBUTE2         := C1.NEW_ATTRIBUTE2;
     x_party_rec.ATTRIBUTE3         := C1.NEW_ATTRIBUTE3;
     x_party_rec.ATTRIBUTE4         := C1.NEW_ATTRIBUTE4;
     x_party_rec.ATTRIBUTE5         := C1.NEW_ATTRIBUTE5;
     x_party_rec.ATTRIBUTE6         := C1.NEW_ATTRIBUTE6;
     x_party_rec.ATTRIBUTE7         := C1.NEW_ATTRIBUTE7;
     x_party_rec.ATTRIBUTE8         := C1.NEW_ATTRIBUTE8;
     x_party_rec.ATTRIBUTE9         := C1.NEW_ATTRIBUTE9;
     x_party_rec.ATTRIBUTE10        := C1.NEW_ATTRIBUTE10;
     x_party_rec.ATTRIBUTE11        := C1.NEW_ATTRIBUTE11;
     x_party_rec.ATTRIBUTE12        := C1.NEW_ATTRIBUTE12;
     x_party_rec.ATTRIBUTE13        := C1.NEW_ATTRIBUTE13;
     x_party_rec.ATTRIBUTE14        := C1.NEW_ATTRIBUTE14;
     x_party_rec.ATTRIBUTE15        := C1.NEW_ATTRIBUTE15;
     x_party_rec.PRIMARY_FLAG       := C1.NEW_PRIMARY_FLAG;
     x_party_rec.PREFERRED_FLAG     := C1.NEW_PREFERRED_FLAG;
   ELSE
     EXIT;
   END IF;

  END LOOP;
END Initialize_pty_rec_no_dump;


/*----------------------------------------------------------*/
/* Procedure name:  Initialize_pty_rec                      */
/* Description : This procudure recontructs the record      */
/*                 from the history                         */
/*----------------------------------------------------------*/

PROCEDURE Initialize_pty_rec
(
  x_party_rec           IN OUT NOCOPY  csi_datastructures_pub.party_header_rec,
  p_inst_party_hist_id  IN NUMBER,
  x_nearest_full_dump   IN OUT NOCOPY  DATE
   ) IS


CURSOR Int_nearest_full_dump(p_inst_pty_hist_id IN NUMBER ) IS
SELECT
    CREATION_DATE                   ,
    NEW_PARTY_SOURCE_TABLE          ,
    NEW_PARTY_ID                    ,
    NEW_RELATIONSHIP_TYPE_CODE      ,
    NEW_CONTACT_FLAG                ,
    NEW_CONTACT_IP_ID               ,
    NEW_ACTIVE_START_DATE           ,
    NEW_ACTIVE_END_DATE             ,
    NEW_CONTEXT                     ,
    NEW_ATTRIBUTE1                  ,
    NEW_ATTRIBUTE2                  ,
    NEW_ATTRIBUTE3                  ,
    NEW_ATTRIBUTE4                  ,
    NEW_ATTRIBUTE5                  ,
    NEW_ATTRIBUTE6                  ,
    NEW_ATTRIBUTE7                  ,
    NEW_ATTRIBUTE8                  ,
    NEW_ATTRIBUTE9                  ,
    NEW_ATTRIBUTE10                 ,
    NEW_ATTRIBUTE11                 ,
    NEW_ATTRIBUTE12                 ,
    NEW_ATTRIBUTE13                 ,
    NEW_ATTRIBUTE14                 ,
    NEW_ATTRIBUTE15                 ,
    NEW_PRIMARY_FLAG                ,
    NEW_PREFERRED_FLAG
 FROM CSI_I_PARTIES_H
WHERE instance_party_history_id = p_inst_pty_hist_id
  and  full_dump_flag = 'Y' ;

BEGIN

  FOR C1 IN Int_nearest_full_dump(p_inst_party_hist_id  ) LOOP
     x_nearest_full_dump            := C1.creation_date;
     x_party_rec.PARTY_SOURCE_TABLE := C1.NEW_PARTY_SOURCE_TABLE;
     x_party_rec.PARTY_ID           := C1.NEW_PARTY_ID;
     x_party_rec.RELATIONSHIP_TYPE_CODE := C1.NEW_RELATIONSHIP_TYPE_CODE;
     x_party_rec.CONTACT_FLAG       := C1.NEW_CONTACT_FLAG;
     x_party_rec.CONTACT_IP_ID      := C1.NEW_CONTACT_IP_ID;
     x_party_rec.ACTIVE_START_DATE  := C1.NEW_ACTIVE_START_DATE;
     x_party_rec.ACTIVE_END_DATE    := C1.NEW_ACTIVE_END_DATE;
     x_party_rec.CONTEXT            := C1.NEW_CONTEXT;
     x_party_rec.ATTRIBUTE1         := C1.NEW_ATTRIBUTE1;
     x_party_rec.ATTRIBUTE2         := C1.NEW_ATTRIBUTE2;
     x_party_rec.ATTRIBUTE3         := C1.NEW_ATTRIBUTE3;
     x_party_rec.ATTRIBUTE4         := C1.NEW_ATTRIBUTE4;
     x_party_rec.ATTRIBUTE5         := C1.NEW_ATTRIBUTE5;
     x_party_rec.ATTRIBUTE6         := C1.NEW_ATTRIBUTE6;
     x_party_rec.ATTRIBUTE7         := C1.NEW_ATTRIBUTE7;
     x_party_rec.ATTRIBUTE8         := C1.NEW_ATTRIBUTE8;
     x_party_rec.ATTRIBUTE9         := C1.NEW_ATTRIBUTE9;
     x_party_rec.ATTRIBUTE10        := C1.NEW_ATTRIBUTE10;
     x_party_rec.ATTRIBUTE11        := C1.NEW_ATTRIBUTE11;
     x_party_rec.ATTRIBUTE12        := C1.NEW_ATTRIBUTE12;
     x_party_rec.ATTRIBUTE13        := C1.NEW_ATTRIBUTE13;
     x_party_rec.ATTRIBUTE14        := C1.NEW_ATTRIBUTE14;
     x_party_rec.ATTRIBUTE15        := C1.NEW_ATTRIBUTE15;
     x_party_rec.PRIMARY_FLAG       := C1.NEW_PRIMARY_FLAG;
     x_party_rec.PREFERRED_FLAG     := C1.NEW_PREFERRED_FLAG;

  END LOOP;
END Initialize_pty_rec ;


/*----------------------------------------------------------*/
/* Procedure name:  Construct_pty_from_hist                 */
/* Description : This procudure recontructs the record      */
/*                 from the history                         */
/*----------------------------------------------------------*/

PROCEDURE Construct_pty_from_hist
(
  x_party_tbl      IN OUT NOCOPY  csi_datastructures_pub.party_header_tbl,
  p_time_stamp     IN DATE
  ) IS

l_nearest_full_dump      DATE := sysdate;
l_inst_party_hist_id     NUMBER;
l_party_tbl              csi_datastructures_pub.party_header_tbl;
l_pty_count              NUMBER := 0;
--
Process_next             EXCEPTION;

CURSOR get_nearest_full_dump(p_inst_party_id IN NUMBER ,p_time IN DATE) IS
SELECT
  MAX(instance_party_history_id)
FROM CSI_I_PARTIES_H
WHERE creation_date <= p_time
  and instance_party_id = p_inst_party_id
  and  full_dump_flag = 'Y' ;

CURSOR get_inst_party_hist (p_inst_party_id IN NUMBER ,
                            p_nearest_full_dump IN DATE,
                            p_time IN DATE ) IS
SELECT
    INSTANCE_PARTY_HISTORY_ID       ,
    OLD_PARTY_SOURCE_TABLE          ,
    NEW_PARTY_SOURCE_TABLE          ,
    OLD_PARTY_ID                    ,
    NEW_PARTY_ID                    ,
    OLD_RELATIONSHIP_TYPE_CODE      ,
    NEW_RELATIONSHIP_TYPE_CODE      ,
    OLD_CONTACT_FLAG                ,
    NEW_CONTACT_FLAG                ,
    OLD_CONTACT_IP_ID               ,
    NEW_CONTACT_IP_ID               ,
    OLD_ACTIVE_START_DATE           ,
    NEW_ACTIVE_START_DATE           ,
    OLD_ACTIVE_END_DATE             ,
    NEW_ACTIVE_END_DATE             ,
    OLD_CONTEXT                     ,
    NEW_CONTEXT                     ,
    OLD_ATTRIBUTE1                  ,
    NEW_ATTRIBUTE1                  ,
    OLD_ATTRIBUTE2                  ,
    NEW_ATTRIBUTE2                  ,
    OLD_ATTRIBUTE3                  ,
    NEW_ATTRIBUTE3                  ,
    OLD_ATTRIBUTE4                  ,
    NEW_ATTRIBUTE4                  ,
    OLD_ATTRIBUTE5                  ,
    NEW_ATTRIBUTE5                  ,
    OLD_ATTRIBUTE6                  ,
    NEW_ATTRIBUTE6                  ,
    OLD_ATTRIBUTE7                  ,
    NEW_ATTRIBUTE7                  ,
    OLD_ATTRIBUTE8                  ,
    NEW_ATTRIBUTE8                  ,
    OLD_ATTRIBUTE9                  ,
    NEW_ATTRIBUTE9                  ,
    OLD_ATTRIBUTE10                 ,
    NEW_ATTRIBUTE10                 ,
    OLD_ATTRIBUTE11                 ,
    NEW_ATTRIBUTE11                 ,
    OLD_ATTRIBUTE12                 ,
    NEW_ATTRIBUTE12                 ,
    OLD_ATTRIBUTE13                 ,
    NEW_ATTRIBUTE13                 ,
    OLD_ATTRIBUTE14                 ,
    NEW_ATTRIBUTE14                 ,
    OLD_ATTRIBUTE15                 ,
    NEW_ATTRIBUTE15                 ,
    OLD_PRIMARY_FLAG                ,
    NEW_PRIMARY_FLAG                ,
    OLD_PREFERRED_FLAG              ,
    NEW_PREFERRED_FLAG
 FROM CSI_I_PARTIES_H
WHERE creation_date <= p_time
  and creation_date >= p_nearest_full_dump
  and instance_party_id = p_inst_party_id
  and  full_dump_flag = 'N'
  ORDER BY creation_date;

  l_time_stamp  DATE := p_time_stamp;

BEGIN
l_party_tbl := x_party_tbl;
IF l_party_tbl.count > 0 THEN
  FOR i IN l_party_tbl.FIRST..l_party_tbl.LAST LOOP
  BEGIN
     OPEN get_nearest_full_dump(l_party_tbl(i).instance_party_id,p_time_stamp);
     FETCH get_nearest_full_dump INTO l_inst_party_hist_id;
     CLOSE get_nearest_full_dump;

     IF l_inst_party_hist_id IS NOT NULL THEN
       Initialize_pty_rec( l_party_tbl(i), l_inst_party_hist_id ,l_nearest_full_dump);
     ELSE

       Initialize_pty_rec_no_dump(l_party_tbl(i), l_party_tbl(i).instance_party_id, l_time_stamp);
            l_nearest_full_dump :=  l_time_stamp;
         -- If the user chooses a date before the creation date of the instance
         -- then raise an error
           IF p_time_stamp < l_time_stamp THEN
              -- Messages Commented for bug 2423342. Records that do not qualify should get deleted.
              -- FND_MESSAGE.SET_NAME('CSI','CSI_H_DATE_BEFORE_CRE_DATE');
              -- FND_MESSAGE.SET_TOKEN('CREATION_DATE',to_char(l_time_stamp, 'DD-MON-YYYY HH24:MI:SS'));
              -- FND_MESSAGE.SET_TOKEN('USER_DATE',to_char(p_time_stamp, 'DD-MON-YYYY HH24:MI:SS'));
              -- FND_MSG_PUB.Add;
              -- RAISE FND_API.G_EXC_ERROR;
              l_party_tbl.DELETE(i);
              RAISE Process_next;
           END IF;

     END IF;

    FOR C2 IN get_inst_party_hist(l_party_tbl(i).instance_party_id ,l_nearest_full_dump,p_time_stamp ) LOOP

      IF (C2.OLD_PARTY_SOURCE_TABLE IS NULL AND C2.NEW_PARTY_SOURCE_TABLE IS NOT NULL)
      OR (C2.OLD_PARTY_SOURCE_TABLE IS NOT NULL AND C2.NEW_PARTY_SOURCE_TABLE IS NULL)
      OR (C2.OLD_PARTY_SOURCE_TABLE <> C2.NEW_PARTY_SOURCE_TABLE) THEN
                 l_party_tbl(i).PARTY_SOURCE_TABLE := C2.NEW_PARTY_SOURCE_TABLE;
      END IF;

      IF (C2.OLD_PARTY_ID IS NULL AND C2.NEW_PARTY_ID IS NOT NULL)
      OR (C2.OLD_PARTY_ID IS NOT NULL AND C2.NEW_PARTY_ID IS NULL)
      OR (C2.OLD_PARTY_ID <> C2.NEW_PARTY_ID) THEN
                l_party_tbl(i).PARTY_ID := C2.NEW_PARTY_ID;
      END IF;

      IF (C2.OLD_RELATIONSHIP_TYPE_CODE IS NULL AND C2.NEW_RELATIONSHIP_TYPE_CODE IS NOT NULL)
      OR (C2.OLD_RELATIONSHIP_TYPE_CODE IS NOT NULL AND C2.NEW_RELATIONSHIP_TYPE_CODE IS NULL)
      OR (C2.OLD_RELATIONSHIP_TYPE_CODE <> C2.NEW_RELATIONSHIP_TYPE_CODE) THEN
                l_party_tbl(i).RELATIONSHIP_TYPE_CODE := C2.NEW_RELATIONSHIP_TYPE_CODE;
      END IF;

      IF (C2.OLD_CONTACT_FLAG IS NULL AND C2.NEW_CONTACT_FLAG IS NOT NULL)
      OR (C2.OLD_CONTACT_FLAG IS NOT NULL AND C2.NEW_CONTACT_FLAG IS NULL)
      OR (C2.OLD_CONTACT_FLAG <> C2.NEW_CONTACT_FLAG) THEN
                l_party_tbl(i).CONTACT_FLAG := C2.NEW_CONTACT_FLAG;
      END IF;

      IF (C2.OLD_CONTACT_IP_ID IS NULL AND C2.NEW_CONTACT_IP_ID IS NOT NULL)
      OR (C2.OLD_CONTACT_IP_ID IS NOT NULL AND C2.NEW_CONTACT_IP_ID IS NULL)
      OR (C2.OLD_CONTACT_IP_ID <> C2.NEW_CONTACT_IP_ID) THEN
                l_party_tbl(i).CONTACT_IP_ID := C2.NEW_CONTACT_IP_ID;
      END IF;

      IF (C2.OLD_ACTIVE_START_DATE IS NULL AND C2.NEW_ACTIVE_START_DATE IS NOT NULL)
      OR (C2.OLD_ACTIVE_START_DATE IS NOT NULL AND C2.NEW_ACTIVE_START_DATE IS NULL)
      OR (C2.OLD_ACTIVE_START_DATE <> C2.NEW_ACTIVE_START_DATE) THEN
           l_party_tbl(i).ACTIVE_START_DATE := C2.NEW_ACTIVE_START_DATE;
      END IF;


      IF (C2.OLD_ACTIVE_END_DATE IS NULL AND C2.NEW_ACTIVE_END_DATE IS NOT NULL)
      OR (C2.OLD_ACTIVE_END_DATE IS NOT NULL AND C2.NEW_ACTIVE_END_DATE IS NULL)
      OR (C2.OLD_ACTIVE_END_DATE <> C2.NEW_ACTIVE_END_DATE) THEN
           l_party_tbl(i).ACTIVE_END_DATE := C2.NEW_ACTIVE_END_DATE;
      END IF;


      IF (C2.OLD_CONTEXT IS NULL AND C2.NEW_CONTEXT IS NOT NULL)
      OR (C2.OLD_CONTEXT IS NOT NULL AND C2.NEW_CONTEXT IS NULL)
      OR (C2.OLD_CONTEXT <> C2.NEW_CONTEXT) THEN
           l_party_tbl(i).CONTEXT := C2.NEW_CONTEXT;
      END IF;

      IF (C2.OLD_ATTRIBUTE1 IS NULL AND C2.NEW_ATTRIBUTE1 IS NOT NULL)
      OR (C2.OLD_ATTRIBUTE1 IS NOT NULL AND C2.NEW_ATTRIBUTE1 IS NULL)
      OR (C2.OLD_ATTRIBUTE1 <> C2.NEW_ATTRIBUTE1) THEN
           l_party_tbl(i).ATTRIBUTE1 := C2.NEW_ATTRIBUTE1;
      END IF;

      IF (C2.OLD_ATTRIBUTE2 IS NULL AND C2.NEW_ATTRIBUTE2 IS NOT NULL)
      OR (C2.OLD_ATTRIBUTE2 IS NOT NULL AND C2.NEW_ATTRIBUTE2 IS NULL)
      OR (C2.OLD_ATTRIBUTE2 <> C2.NEW_ATTRIBUTE2) THEN
           l_party_tbl(i).ATTRIBUTE2 := C2.NEW_ATTRIBUTE2;
      END IF;

      IF (C2.OLD_ATTRIBUTE3 IS NULL AND C2.NEW_ATTRIBUTE3 IS NOT NULL)
      OR (C2.OLD_ATTRIBUTE3 IS NOT NULL AND C2.NEW_ATTRIBUTE3 IS NULL)
      OR (C2.OLD_ATTRIBUTE3 <> C2.NEW_ATTRIBUTE3) THEN
           l_party_tbl(i).ATTRIBUTE3 := C2.NEW_ATTRIBUTE3;
      END IF;

      IF (C2.OLD_ATTRIBUTE4 IS NULL AND C2.NEW_ATTRIBUTE4 IS NOT NULL)
      OR (C2.OLD_ATTRIBUTE4 IS NOT NULL AND C2.NEW_ATTRIBUTE4 IS NULL)
      OR (C2.OLD_ATTRIBUTE4 <> C2.NEW_ATTRIBUTE4) THEN
           l_party_tbl(i).ATTRIBUTE4 := C2.NEW_ATTRIBUTE4;
      END IF;


      IF (C2.OLD_ATTRIBUTE5 IS NULL AND C2.NEW_ATTRIBUTE5 IS NOT NULL)
      OR (C2.OLD_ATTRIBUTE5 IS NOT NULL AND C2.NEW_ATTRIBUTE5 IS NULL)
      OR (C2.OLD_ATTRIBUTE5 <> C2.NEW_ATTRIBUTE5) THEN
           l_party_tbl(i).ATTRIBUTE5 := C2.NEW_ATTRIBUTE5;
      END IF;


      IF (C2.OLD_ATTRIBUTE6 IS NULL AND C2.NEW_ATTRIBUTE6 IS NOT NULL)
      OR (C2.OLD_ATTRIBUTE6 IS NOT NULL AND C2.NEW_ATTRIBUTE6 IS NULL)
      OR (C2.OLD_ATTRIBUTE6 <> C2.NEW_ATTRIBUTE6) THEN
           l_party_tbl(i).ATTRIBUTE6 := C2.NEW_ATTRIBUTE6;
      END IF;

      IF (C2.OLD_ATTRIBUTE7 IS NULL AND C2.NEW_ATTRIBUTE7 IS NOT NULL)
      OR (C2.OLD_ATTRIBUTE7 IS NOT NULL AND C2.NEW_ATTRIBUTE7 IS NULL)
      OR (C2.OLD_ATTRIBUTE7 <> C2.NEW_ATTRIBUTE7) THEN
           l_party_tbl(i).ATTRIBUTE7 := C2.NEW_ATTRIBUTE7;
      END IF;

      IF (C2.OLD_ATTRIBUTE8 IS NULL AND C2.NEW_ATTRIBUTE8 IS NOT NULL)
      OR (C2.OLD_ATTRIBUTE8 IS NOT NULL AND C2.NEW_ATTRIBUTE8 IS NULL)
      OR (C2.OLD_ATTRIBUTE8 <> C2.NEW_ATTRIBUTE8) THEN
           l_party_tbl(i).ATTRIBUTE8 := C2.NEW_ATTRIBUTE8;
      END IF;

      IF (C2.OLD_ATTRIBUTE9 IS NULL AND C2.NEW_ATTRIBUTE9 IS NOT NULL)
      OR (C2.OLD_ATTRIBUTE9 IS NOT NULL AND C2.NEW_ATTRIBUTE9 IS NULL)
      OR (C2.OLD_ATTRIBUTE9 <> C2.NEW_ATTRIBUTE9) THEN
           l_party_tbl(i).ATTRIBUTE3 := C2.NEW_ATTRIBUTE3;
      END IF;


      IF (C2.OLD_ATTRIBUTE10 IS NULL AND C2.NEW_ATTRIBUTE10 IS NOT NULL)
      OR (C2.OLD_ATTRIBUTE10 IS NOT NULL AND C2.NEW_ATTRIBUTE10 IS NULL)
      OR (C2.OLD_ATTRIBUTE10 <> C2.NEW_ATTRIBUTE10) THEN
           l_party_tbl(i).ATTRIBUTE10 := C2.NEW_ATTRIBUTE10;
      END IF;



      IF (C2.OLD_ATTRIBUTE11 IS NULL AND C2.NEW_ATTRIBUTE11 IS NOT NULL)
      OR (C2.OLD_ATTRIBUTE11 IS NOT NULL AND C2.NEW_ATTRIBUTE11 IS NULL)
      OR (C2.OLD_ATTRIBUTE11 <> C2.NEW_ATTRIBUTE11) THEN
           l_party_tbl(i).ATTRIBUTE11 := C2.NEW_ATTRIBUTE11;
      END IF;

      IF (C2.OLD_ATTRIBUTE12 IS NULL AND C2.NEW_ATTRIBUTE12 IS NOT NULL)
      OR (C2.OLD_ATTRIBUTE12 IS NOT NULL AND C2.NEW_ATTRIBUTE12 IS NULL)
      OR (C2.OLD_ATTRIBUTE12 <> C2.NEW_ATTRIBUTE12) THEN
           l_party_tbl(i).ATTRIBUTE12 := C2.NEW_ATTRIBUTE12;
      END IF;


      IF (C2.OLD_ATTRIBUTE13 IS NULL AND C2.NEW_ATTRIBUTE13 IS NOT NULL)
      OR (C2.OLD_ATTRIBUTE13 IS NOT NULL AND C2.NEW_ATTRIBUTE13 IS NULL)
      OR (C2.OLD_ATTRIBUTE13 <> C2.NEW_ATTRIBUTE13) THEN
           l_party_tbl(i).ATTRIBUTE13 := C2.NEW_ATTRIBUTE13;
      END IF;


      IF (C2.OLD_ATTRIBUTE14 IS NULL AND C2.NEW_ATTRIBUTE14 IS NOT NULL)
      OR (C2.OLD_ATTRIBUTE14 IS NOT NULL AND C2.NEW_ATTRIBUTE14 IS NULL)
      OR (C2.OLD_ATTRIBUTE14 <> C2.NEW_ATTRIBUTE14) THEN
           l_party_tbl(i).ATTRIBUTE14 := C2.NEW_ATTRIBUTE14;
      END IF;

      IF (C2.OLD_ATTRIBUTE15 IS NULL AND C2.NEW_ATTRIBUTE15 IS NOT NULL)
      OR (C2.OLD_ATTRIBUTE15 IS NOT NULL AND C2.NEW_ATTRIBUTE15 IS NULL)
      OR (C2.OLD_ATTRIBUTE15 <> C2.NEW_ATTRIBUTE15) THEN
           l_party_tbl(i).ATTRIBUTE15 := C2.NEW_ATTRIBUTE15;
      END IF;

      IF (C2.OLD_PRIMARY_FLAG IS NULL AND C2.NEW_PRIMARY_FLAG IS NOT NULL)
      OR (C2.OLD_PRIMARY_FLAG IS NOT NULL AND C2.NEW_PRIMARY_FLAG IS NULL)
      OR (C2.OLD_PRIMARY_FLAG <> C2.NEW_PRIMARY_FLAG) THEN
                l_party_tbl(i).PRIMARY_FLAG := C2.NEW_PRIMARY_FLAG;
      END IF;

      IF (C2.OLD_PREFERRED_FLAG IS NULL AND C2.NEW_PREFERRED_FLAG IS NOT NULL)
      OR (C2.OLD_PREFERRED_FLAG IS NOT NULL AND C2.NEW_PREFERRED_FLAG IS NULL)
      OR (C2.OLD_PREFERRED_FLAG <> C2.NEW_PREFERRED_FLAG) THEN
                l_party_tbl(i).PREFERRED_FLAG := C2.NEW_PREFERRED_FLAG;
      END IF;

    END LOOP;
   EXCEPTION
      WHEN Process_next THEN
         NULL;
   END;
 END LOOP;
 x_party_tbl.DELETE;
 IF l_party_tbl.count > 0 THEN
    FOR pty_row in l_party_tbl.FIRST .. l_party_tbl.LAST
    LOOP
       IF l_party_tbl.EXISTS(pty_row) THEN
          l_pty_count := l_pty_count + 1;
          x_party_tbl(l_pty_count) := l_party_tbl(pty_row);
       END IF;
    END LOOP;
 END IF;
END IF;
END Construct_pty_from_hist;


/*----------------------------------------------------------*/
/* Procedure name:  Get_Pty_Column_Values                   */
/* Description : This procudure gets the column values      */
/*                        for the Dynamic SQL               */
/*----------------------------------------------------------*/

PROCEDURE Get_Pty_Column_Values
(
    p_get_pty_cursor_id      IN   NUMBER      ,
    x_party_rec            OUT NOCOPY   csi_datastructures_pub.party_header_rec
    ) IS

BEGIN

 dbms_sql.column_value(p_get_pty_cursor_id, 1, x_party_rec.instance_party_id);
 dbms_sql.column_value(p_get_pty_cursor_id, 2, x_party_rec.instance_id);
 dbms_sql.column_value(p_get_pty_cursor_id, 3, x_party_rec.party_source_table);
 dbms_sql.column_value(p_get_pty_cursor_id, 4, x_party_rec.party_id);
 dbms_sql.column_value(p_get_pty_cursor_id, 5, x_party_rec.relationship_type_code);
 dbms_sql.column_value(p_get_pty_cursor_id, 6, x_party_rec.contact_flag);
 dbms_sql.column_value(p_get_pty_cursor_id, 7, x_party_rec.contact_ip_id);
 dbms_sql.column_value(p_get_pty_cursor_id, 8, x_party_rec.active_start_date);
 dbms_sql.column_value(p_get_pty_cursor_id, 9, x_party_rec.active_end_date);
 dbms_sql.column_value(p_get_pty_cursor_id, 10, x_party_rec.context);
 dbms_sql.column_value(p_get_pty_cursor_id, 11, x_party_rec.attribute1);
 dbms_sql.column_value(p_get_pty_cursor_id, 12, x_party_rec.attribute2);
 dbms_sql.column_value(p_get_pty_cursor_id, 13, x_party_rec.attribute3);
 dbms_sql.column_value(p_get_pty_cursor_id, 14, x_party_rec.attribute4);
 dbms_sql.column_value(p_get_pty_cursor_id, 15, x_party_rec.attribute5);
 dbms_sql.column_value(p_get_pty_cursor_id, 16, x_party_rec.attribute6);
 dbms_sql.column_value(p_get_pty_cursor_id, 17, x_party_rec.attribute7);
 dbms_sql.column_value(p_get_pty_cursor_id, 18, x_party_rec.attribute8);
 dbms_sql.column_value(p_get_pty_cursor_id, 19, x_party_rec.attribute9);
 dbms_sql.column_value(p_get_pty_cursor_id, 20, x_party_rec.attribute10);
 dbms_sql.column_value(p_get_pty_cursor_id, 21, x_party_rec.attribute11);
 dbms_sql.column_value(p_get_pty_cursor_id, 22, x_party_rec.attribute12);
 dbms_sql.column_value(p_get_pty_cursor_id, 23, x_party_rec.attribute13);
 dbms_sql.column_value(p_get_pty_cursor_id, 24, x_party_rec.attribute14);
 dbms_sql.column_value(p_get_pty_cursor_id, 25, x_party_rec.attribute15);
 dbms_sql.column_value(p_get_pty_cursor_id, 26, x_party_rec.object_version_number);
 dbms_sql.column_value(p_get_pty_cursor_id, 27, x_party_rec.primary_flag);
 dbms_sql.column_value(p_get_pty_cursor_id, 28, x_party_rec.preferred_flag);

END Get_Pty_Column_Values;

/*----------------------------------------------------------*/
/* Procedure name:  Define_Pty_Columns                      */
/* Description : This procudure defines the columns         */
/*                        for the Dynamic SQL               */
/*----------------------------------------------------------*/

PROCEDURE Define_Pty_Columns
(
  p_get_pty_cursor_id      IN   NUMBER
  ) IS
  l_party_rec            csi_datastructures_pub.party_header_rec;
BEGIN

 dbms_sql.define_column(p_get_pty_cursor_id, 1, l_party_rec.instance_party_id);
 dbms_sql.define_column(p_get_pty_cursor_id, 2, l_party_rec.instance_id);
 dbms_sql.define_column(p_get_pty_cursor_id, 3, l_party_rec.party_source_table ,30);
 dbms_sql.define_column(p_get_pty_cursor_id, 4, l_party_rec.party_id);
 dbms_sql.define_column(p_get_pty_cursor_id, 5, l_party_rec.relationship_type_code ,30);
 dbms_sql.define_column(p_get_pty_cursor_id, 6, l_party_rec.contact_flag,1);
 dbms_sql.define_column(p_get_pty_cursor_id, 7, l_party_rec.contact_ip_id);
 dbms_sql.define_column(p_get_pty_cursor_id, 8, l_party_rec.active_start_date);
 dbms_sql.define_column(p_get_pty_cursor_id, 9, l_party_rec.active_end_date);
 dbms_sql.define_column(p_get_pty_cursor_id, 10, l_party_rec.context,30);
 dbms_sql.define_column(p_get_pty_cursor_id, 11, l_party_rec.attribute1,150);
 dbms_sql.define_column(p_get_pty_cursor_id, 12, l_party_rec.attribute2,150);
 dbms_sql.define_column(p_get_pty_cursor_id, 13, l_party_rec.attribute3,150);
 dbms_sql.define_column(p_get_pty_cursor_id, 14, l_party_rec.attribute4,150);
 dbms_sql.define_column(p_get_pty_cursor_id, 15, l_party_rec.attribute5,150);
 dbms_sql.define_column(p_get_pty_cursor_id, 16, l_party_rec.attribute6,150);
 dbms_sql.define_column(p_get_pty_cursor_id, 17, l_party_rec.attribute7,150);
 dbms_sql.define_column(p_get_pty_cursor_id, 18, l_party_rec.attribute8,150);
 dbms_sql.define_column(p_get_pty_cursor_id, 19, l_party_rec.attribute9,150);
 dbms_sql.define_column(p_get_pty_cursor_id, 20, l_party_rec.attribute10,150);
 dbms_sql.define_column(p_get_pty_cursor_id, 21, l_party_rec.attribute11,150);
 dbms_sql.define_column(p_get_pty_cursor_id, 22, l_party_rec.attribute12,150);
 dbms_sql.define_column(p_get_pty_cursor_id, 23, l_party_rec.attribute13,150);
 dbms_sql.define_column(p_get_pty_cursor_id, 24, l_party_rec.attribute14,150);
 dbms_sql.define_column(p_get_pty_cursor_id, 25, l_party_rec.attribute15,150);
 dbms_sql.define_column(p_get_pty_cursor_id, 26, l_party_rec.object_version_number);
 dbms_sql.define_column(p_get_pty_cursor_id, 27, l_party_rec.primary_flag,1);
 dbms_sql.define_column(p_get_pty_cursor_id, 28, l_party_rec.preferred_flag,1);

END Define_Pty_Columns;


/*----------------------------------------------------------*/
/* Procedure name:  Bind_Pty_variable                       */
/* Description : Procedure used to  generate the where      */
/*                cluase  for Party relationship            */
/*----------------------------------------------------------*/

PROCEDURE Bind_Pty_variable
(
    p_party_query_rec      IN    csi_datastructures_pub.party_query_rec,
    p_cur_get_pty_rel      IN   NUMBER
   ) IS

BEGIN

 IF( (p_party_query_rec.instance_party_id IS NOT NULL)
                  AND (p_party_query_rec.instance_party_id <> FND_API.G_MISS_NUM))  THEN
    DBMS_SQL.BIND_VARIABLE(p_cur_get_pty_rel, ':instance_party_id', p_party_query_rec.instance_party_id);
 END IF;

 IF( (p_party_query_rec.instance_id IS NOT NULL)
                  AND (p_party_query_rec.instance_id <> FND_API.G_MISS_NUM))  THEN
    DBMS_SQL.BIND_VARIABLE(p_cur_get_pty_rel, ':instance_id', p_party_query_rec.instance_id);
 END IF;

 IF( (p_party_query_rec.party_id IS NOT NULL)
                  AND (p_party_query_rec.party_id <> FND_API.G_MISS_NUM))  THEN
    DBMS_SQL.BIND_VARIABLE(p_cur_get_pty_rel, ':party_id', p_party_query_rec.party_id);
 END IF;

 IF( (p_party_query_rec.relationship_type_code IS NOT NULL)
                  AND (p_party_query_rec.relationship_type_code <> FND_API.G_MISS_CHAR))  THEN
    DBMS_SQL.BIND_VARIABLE(p_cur_get_pty_rel, ':relationship_type_code', p_party_query_rec.relationship_type_code);
 END IF;

END Bind_Pty_variable;

/*----------------------------------------------------------*/
/* Procedure name:  Gen_Pty_Where_Clause                    */
/* Description : Procedure used to  generate the where      */
/*                clause  for Party relationship            */
/*----------------------------------------------------------*/

PROCEDURE Gen_Pty_Where_Clause
(
    p_party_query_rec      IN    csi_datastructures_pub.party_query_rec
   ,x_where_clause         OUT NOCOPY    VARCHAR2
 ) IS

BEGIN

 -- Assign null at the start
 x_where_clause := '';

IF (( p_party_query_rec.instance_party_id  IS NOT NULL)  AND
        ( p_party_query_rec.instance_party_id  <> FND_API.G_MISS_NUM)) THEN
        x_where_clause := ' instance_party_id = :instance_party_id ';
ELSIF ( p_party_query_rec.instance_party_id  IS  NULL) THEN
       x_where_clause := ' instance_party_id IS NULL ';
END IF;

IF ((p_party_query_rec.instance_id IS NOT NULL)       AND
        (p_party_query_rec.instance_id <> FND_API.G_MISS_NUM))   THEN
        IF x_where_clause IS NULL THEN
            x_where_clause := ' instance_id = :instance_id ';
        ELSE
            x_where_clause := x_where_clause||' AND '||' instance_id = :instance_id ';
        END IF;
ELSIF (p_party_query_rec.instance_id IS NULL) THEN
        IF x_where_clause IS NULL THEN
            x_where_clause := ' instance_id IS NULL ';
        ELSE
            x_where_clause := x_where_clause||' AND '||' instance_id IS NULL';
        END IF;
END IF;

IF ((p_party_query_rec.party_id  IS NOT NULL)   AND
            (p_party_query_rec.party_id  <> FND_API.G_MISS_NUM)) THEN
        IF x_where_clause IS NULL THEN
            x_where_clause := ' party_id = :party_id ';
        ELSE
            x_where_clause := x_where_clause||' AND '||' party_id = :party_id ';
        END IF;
ELSIF (p_party_query_rec.party_id  IS  NULL) THEN
        IF x_where_clause IS NULL THEN
            x_where_clause := ' party_id IS NULL ';
        ELSE
            x_where_clause := x_where_clause||' AND '||' party_id IS NULL ';
        END IF;
END IF ;

IF  ((p_party_query_rec.relationship_type_code IS NOT NULL) AND
        (p_party_query_rec.relationship_type_code <> FND_API.G_MISS_CHAR)) THEN
        IF x_where_clause IS NULL THEN
            x_where_clause := '  relationship_type_code = :relationship_type_code ';
        ELSE
            x_where_clause := x_where_clause||' AND '||
                   '  relationship_type_code = :relationship_type_code ';
        END IF;
ELSIF (p_party_query_rec.relationship_type_code IS  NULL) THEN
        IF x_where_clause IS NULL THEN
            x_where_clause := '  relationship_type_code IS NULL ';
        ELSE
            x_where_clause := x_where_clause||' AND '||
                   '  relationship_type_code IS NULL ';
        END IF;
END IF;

END Gen_Pty_Where_Clause;


/*-------------------------------------------------------------*/
/* Procedure name:Create_inst_party_realationships             */
/* Description : Procedure used to   create new instance-party */
/*                            relationships                    */
/*-------------------------------------------------------------*/

PROCEDURE create_inst_party_relationship
 (    p_api_version         IN  NUMBER
     ,p_commit              IN  VARCHAR2
     ,p_init_msg_list       IN  VARCHAR2
     ,p_validation_level    IN  NUMBER
     ,p_party_rec           IN OUT NOCOPY   csi_datastructures_pub.party_rec
     ,p_txn_rec             IN OUT NOCOPY   csi_datastructures_pub.transaction_rec
     ,x_return_status       OUT NOCOPY  VARCHAR2
     ,x_msg_count           OUT NOCOPY  NUMBER
     ,x_msg_data            OUT NOCOPY  VARCHAR2
     ,p_party_source_tbl    IN OUT NOCOPY   csi_party_relationships_pvt.party_source_tbl
     ,p_party_id_tbl        IN OUT NOCOPY   csi_party_relationships_pvt.party_id_tbl
     ,p_contact_tbl         IN OUT NOCOPY   csi_party_relationships_pvt.contact_tbl
     ,p_party_rel_type_tbl  IN OUT NOCOPY   csi_party_relationships_pvt.party_rel_type_tbl
     ,p_party_count_rec     IN OUT NOCOPY   csi_party_relationships_pvt.party_count_rec
     ,p_called_from_grp     IN     VARCHAR2

   ) IS

     l_api_name      CONSTANT VARCHAR2(30)   := 'CREATE_INST_PARTY_RELATIONSHIP';
     l_api_version   CONSTANT NUMBER         := 1.0;
     l_csi_debug_level        NUMBER;
     l_party_rec              csi_datastructures_pub.party_rec;
     l_msg_index              NUMBER;
     l_msg_count              NUMBER;
     l_process_flag           BOOLEAN := TRUE;
     l_inst_party_his_id      NUMBER;
     l_record_found           BOOLEAN := FALSE;
     l_exists_flag            VARCHAR2(1);
     l_valid_flag             VARCHAR2(1);
     l_exists                 VARCHAR2(1);

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT create_inst_party_rel_pvt;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (    l_api_version   ,
                                                p_api_version   ,
                                                l_api_name      ,
                                                g_pkg_name      )
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Check the profile option CSI_DEBUG_LEVEL for debug message reporting
        l_csi_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

        -- If CSI_DEBUG_LEVEL = 1 then dump the procedure name
        IF (l_csi_debug_level > 0) THEN
            csi_gen_utility_pvt.put_line( 'create_inst_party_relationship');
        END IF;

        -- If the debug level = 2 then dump all the parameters values.
        IF (l_csi_debug_level> 1) THEN
               csi_gen_utility_pvt.put_line( 'create_inst_party_relationship'||
                                                   p_api_version           ||'-'||
                                                   p_commit                ||'-'||
                                                   p_init_msg_list               );
               -- Dump the records in the log file
               csi_gen_utility_pvt.dump_party_rec(p_party_rec);
               csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);

        END IF;


        -- Start API body
        --
        -- Check if all the required parameters are passed
    	 CSI_Instance_parties_vld_pvt.Check_Reqd_Param_num
 	      (    p_party_rec.INSTANCE_ID ,
		    '  p_party_rec.INSTANCE_ID ',
		       l_api_name           );
    	 CSI_Instance_parties_vld_pvt.Check_Reqd_Param_char
 	      (    p_party_rec.PARTY_SOURCE_TABLE  ,
		    '  p_party_rec.PARTY_SOURCE_TABLE  ',
		       l_api_name           );
    	 CSI_Instance_parties_vld_pvt.Check_Reqd_Param_num
 	      (    p_party_rec.PARTY_ID ,
		    '  p_party_rec.PARTY_ID ',
		       l_api_name           );

         CSI_Instance_parties_vld_pvt.Check_Reqd_Param_char
 	      (    p_party_rec.RELATIONSHIP_TYPE_CODE,
		    '  p_party_rec.RELATIONSHIP_TYPE_CODE',
		       l_api_name           );

         CSI_Instance_parties_vld_pvt.Check_Reqd_Param_char
 	      (    p_party_rec.CONTACT_FLAG,
		    '  p_party_rec.CONTACT_FLAG',
		       l_api_name           );

       -- Initialize the count
       IF p_party_count_rec.party_source_count is NULL OR
          p_party_count_rec.party_source_count = FND_API.G_MISS_NUM THEN
          p_party_count_rec.party_source_count := 0;
       END IF;
       --
       IF p_party_count_rec.party_id_count is NULL OR
          p_party_count_rec.party_id_count = FND_API.G_MISS_NUM THEN
          p_party_count_rec.party_id_count := 0;
       END IF;
       --
       IF p_party_count_rec.contact_id_count is NULL OR
          p_party_count_rec.contact_id_count = FND_API.G_MISS_NUM THEN
          p_party_count_rec.contact_id_count := 0;
       END IF;
       --
       IF p_party_count_rec.rel_type_count is NULL OR
          p_party_count_rec.rel_type_count = FND_API.G_MISS_NUM THEN
          p_party_count_rec.rel_type_count := 0;
       END IF;
       --
       -- Check if the party is expired
       -- If so unexpire the instance party relationship
       -- Added by sk for bug 2232880
       l_record_found  := FALSE;
       IF ( (p_called_from_grp <> FND_API.G_TRUE) AND
            (p_party_rec.instance_party_id IS NULL OR
             p_party_rec.instance_party_id = fnd_api.g_miss_num) )
       THEN
          BEGIN
             SELECT instance_party_id,
                   object_version_number,
                   active_start_date
             INTO p_party_rec.instance_party_id,
                  p_party_rec.object_version_number,
                  p_party_rec.active_start_date
             FROM csi_i_parties
             WHERE instance_id          = p_party_rec.instance_id
             AND party_source_table     = p_party_rec.party_source_table
             AND party_id               = p_party_rec.party_id
             AND relationship_type_code = p_party_rec.relationship_type_code
             AND contact_flag           = p_party_rec.contact_flag
             AND nvl(contact_ip_id,fnd_api.g_miss_num) = nvl(p_party_rec.contact_ip_id,fnd_api.g_miss_num)
             AND active_end_date        < SYSDATE
             AND ROWNUM=1;
             l_record_found  := TRUE;
          EXCEPTION
             WHEN OTHERS THEN
                NULL;
          END;
       END IF;
       --
       IF l_record_found THEN
	  /* -- Commented by sk for bug 2232880
	  IF (CSI_Instance_parties_vld_pvt.Is_Party_Expired
                      (p_party_rec)) THEN
	     IF (p_party_rec.ACTIVE_END_DATE = FND_API.G_MISS_DATE) THEN
		 p_party_rec.ACTIVE_END_DATE := NULL;
	     END IF;
	    */ --End commentation by sk for bug 2232880
	     -- Unexpire the instance party relationship
	     -- Unexpire the instance party relationship
	     IF   p_party_rec.active_end_date = fnd_api.g_miss_date
	     THEN
                p_party_rec.active_end_date := NULL;
	     END IF;
	     update_inst_party_relationship
		    ( p_api_version      => p_api_version
		     ,p_commit           => p_commit
		     ,p_init_msg_list    => p_init_msg_list
		     ,p_validation_level => p_validation_level
		     ,p_party_rec        => p_party_rec
		     ,p_txn_rec          => p_txn_rec
		     ,x_return_status    => x_return_status
		     ,x_msg_count        => x_msg_count
		     ,x_msg_data         => x_msg_data  ) ;

             IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                l_msg_index := 1;
                l_msg_count := x_msg_count;
                WHILE l_msg_count > 0 LOOP
                   x_msg_data := FND_MSG_PUB.GET(
                                     l_msg_index,
                                     FND_API.G_FALSE );
                   csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
                   l_msg_index := l_msg_index + 1;
                   l_msg_count := l_msg_count - 1;
                END LOOP;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
          ELSE -- -- Added by sk for bug 2232880 l_record not found
	    --END IF; -- commented by sk for bug 2232880
	    -- Verify if the Party rel combination exists
               IF p_called_from_grp <> FND_API.G_TRUE THEN
	          IF (CSI_Instance_parties_vld_pvt.Is_Party_Rel_Comb_Exists
			    (p_party_rec.instance_id            ,
			     p_party_rec.party_source_table     ,
			     p_party_rec.party_id               ,
			     p_party_rec.relationship_type_code ,
			     p_party_rec.contact_flag           ,
			     p_party_rec.contact_ip_id          ,
			     TRUE           )) THEN
	      	      RAISE FND_API.G_EXC_ERROR;
	          END IF;
               END IF;
           --
           IF  p_party_rec.INSTANCE_PARTY_ID is  NULL OR
               p_party_rec.INSTANCE_PARTY_ID = FND_API.G_MISS_NUM THEN

           -- If the instance_party_id passed is null then generate from sequence
           -- and check if the value exists . If exists then generate
           -- again from the sequence till we get a value that does not exist
              while l_process_flag loop
               p_party_rec.INSTANCE_PARTY_ID := CSI_Instance_parties_vld_pvt.gen_inst_party_id;
               IF NOT(CSI_Instance_parties_vld_pvt.Is_Inst_PartyID_exists(p_party_rec.INSTANCE_PARTY_ID,
                                                                          FALSE                 )) THEN
                  l_process_flag := FALSE;
               END IF;
              end loop;
            ELSE
               -- Validate the instance_party_id if exist then raise CSI_API_INVALID_PRIMARY_KEY error
               IF CSI_Instance_parties_vld_pvt.Is_Inst_PartyID_exists(p_party_rec.INSTANCE_PARTY_ID,
                                                                   TRUE                ) THEN
                  RAISE FND_API.G_EXC_ERROR;
               END IF;
           END IF;

        -- Verify if the instance_id exists in csi_item_instances
        IF p_called_from_grp <> FND_API.G_TRUE THEN
           IF NOT(CSI_Instance_parties_vld_pvt.Is_InstanceID_Valid(p_party_rec.INSTANCE_ID)) THEN
               RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF;

        -- Verify if the party_source_table exists in CSI_LOOKUPS
        -- Check the cache before hitting the database.
        l_exists_flag := 'N';
        l_valid_flag := 'Y';
        IF p_party_source_tbl.count > 0 THEN
           FOR src_count in p_party_source_tbl.FIRST .. p_party_source_tbl.LAST
           LOOP
              IF p_party_source_tbl(src_count).party_source_table = p_party_rec.PARTY_SOURCE_TABLE THEN
                 l_valid_flag := p_party_source_tbl(src_count).valid_flag;
                 l_exists_flag := 'Y';
                 exit;
              END IF;
           END LOOP;
           --
           IF l_valid_flag <> 'Y' THEN
	      FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_PARTY_SOURCE');
	      FND_MESSAGE.SET_TOKEN('PARTY_SOURCE_TABLE',p_party_rec.PARTY_SOURCE_TABLE);
	      FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF;
        --
        IF l_exists_flag = 'N' THEN
           p_party_count_rec.party_source_count := p_party_count_rec.party_source_count + 1;
           p_party_source_tbl(p_party_count_rec.party_source_count).party_source_table := p_party_rec.PARTY_SOURCE_TABLE;
           IF NOT(CSI_Instance_parties_vld_pvt.Is_Pty_Source_tab_Valid(p_party_rec.PARTY_SOURCE_TABLE)) THEN
               p_party_source_tbl(p_party_count_rec.party_source_count).valid_flag := 'N';
               RAISE FND_API.G_EXC_ERROR;
           ELSE
              p_party_source_tbl(p_party_count_rec.party_source_count).valid_flag := 'Y';
           END IF;
        END IF;

        -- Verify if the party_id is valid from HZ_parties,PO_vendors and employee tables
        -- based on the value of party_source_table
        -- Check the cache before hitting the database.
        l_exists_flag := 'N';
        l_valid_flag := 'Y';
        IF p_party_id_tbl.count > 0 THEN
           For party_count IN p_party_id_tbl.FIRST .. p_party_id_tbl.LAST
           LOOP
              IF p_party_id_tbl(party_count).party_id = p_party_rec.PARTY_ID AND
                 p_party_id_tbl(party_count).party_source_table = p_party_rec.PARTY_SOURCE_TABLE AND
                 nvl(p_party_id_tbl(party_count).contact_flag,'*') = nvl(p_party_rec.CONTACT_FLAG,'*') THEN
                 l_valid_flag := p_party_id_tbl(party_count).valid_flag;
                 l_exists_flag := 'Y';
                 exit;
              END IF;
              --
              IF l_valid_flag <> 'Y' THEN
		 FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_PARTY_ID');
	 	 FND_MESSAGE.SET_TOKEN('PARTY_ID',p_party_rec.PARTY_ID);
		 FND_MSG_PUB.Add;
                 RAISE FND_API.G_EXC_ERROR;
              END IF;
           END LOOP;
        END IF;
        --
        IF l_exists_flag <> 'Y' THEN
           p_party_count_rec.party_id_count := p_party_count_rec.party_id_count + 1;
           p_party_id_tbl(p_party_count_rec.party_id_count).party_id := p_party_rec.PARTY_ID;
           p_party_id_tbl(p_party_count_rec.party_id_count).party_source_table := p_party_rec.PARTY_SOURCE_TABLE;
           p_party_id_tbl(p_party_count_rec.party_id_count).contact_flag := p_party_rec.CONTACT_FLAG;
           IF NOT(CSI_Instance_parties_vld_pvt.Is_Party_Valid
                        (p_party_rec.PARTY_SOURCE_TABLE ,
                         p_party_rec.PARTY_ID ,
                         p_party_rec.CONTACT_FLAG)) THEN
               p_party_id_tbl(p_party_count_rec.party_id_count).valid_flag := 'N';
               RAISE FND_API.G_EXC_ERROR;
           ELSE
               p_party_id_tbl(p_party_count_rec.party_id_count).valid_flag := 'Y';
           END IF;
        END IF;

        --
        --
        -- Added by rtalluri on 07/25/03 (Bug. 2990027)
        -- Contact_flag for the owner party should be 'N', if not then raise an error
        IF    ((p_party_rec.relationship_type_code = 'OWNER')
          AND  (p_party_rec.contact_flag = 'Y'))
        THEN
             FND_MESSAGE.SET_NAME('CSI', 'CSI_INVALID_OWNER_CONTACT');
             FND_MESSAGE.SET_TOKEN('CONTACT_FLAG', p_party_rec.CONTACT_FLAG);
             FND_MESSAGE.SET_TOKEN('RELATIONSHIP_TYPE_CODE', p_party_rec.RELATIONSHIP_TYPE_CODE);
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
        END IF;
        --
        -- Verify that the contact_ip_id is null, if the contact_flag is 'N'
        IF p_party_rec.CONTACT_FLAG = 'N'
        THEN
           IF  ((p_party_rec.CONTACT_IP_ID <> FND_API.G_MISS_NUM)
            AND (p_party_rec.CONTACT_IP_ID IS NOT NULL))
           THEN
              FND_MESSAGE.SET_NAME('CSI', 'CSI_CANNOT_CREATE_CONTACT');
              FND_MESSAGE.SET_TOKEN('CONTACT_FLAG', p_party_rec.CONTACT_FLAG);
              FND_MESSAGE.SET_TOKEN('CONTACT_IP_ID', p_party_rec.CONTACT_IP_ID);
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF;
        --
        -- Verify that the contact_ip_id used to create a contact
        -- is not used by any other instance
        IF p_called_from_grp <> FND_API.G_TRUE THEN
          IF p_party_rec.CONTACT_FLAG = 'Y'
          THEN
             IF  ((p_party_rec.CONTACT_IP_ID <> FND_API.G_MISS_NUM)
              AND (p_party_rec.CONTACT_IP_ID IS NOT NULL ))
             THEN
             l_exists := NULL;
               BEGIN
                 SELECT 'X'
                 INTO   l_exists
                 FROM   csi_i_parties
                 WHERE  instance_id <> p_party_rec.INSTANCE_ID
                 AND    instance_party_id = p_party_rec.CONTACT_IP_ID;

                 IF l_exists IS NOT NULL THEN
                    FND_MESSAGE.SET_NAME('CSI', 'CSI_INVALID_CONTACT_ID');
                    FND_MESSAGE.SET_TOKEN('CONTACT_FLAG', p_party_rec.CONTACT_FLAG);
                    FND_MESSAGE.SET_TOKEN('CONTACT_IP_ID', p_party_rec.CONTACT_IP_ID);
                    FND_MSG_PUB.Add;
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                  NULL;
               END;
             ELSE
                FND_MESSAGE.SET_NAME('CSI', 'CSI_INVALID_CONTACT_ID');
                FND_MESSAGE.SET_TOKEN('CONTACT_FLAG', p_party_rec.CONTACT_FLAG);
                FND_MESSAGE.SET_TOKEN('CONTACT_IP_ID', p_party_rec.CONTACT_IP_ID);
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
          END IF;
        END IF;
        --
        -- End of Addition by rtalluri on 07/25/03 (Bug. 2990027)
        --

        -- Verify the contact_ip_id is valid contact for Party if the contact_flag is 'Y'
        IF p_party_rec.contact_flag = 'Y' THEN
           IF p_called_from_grp <> FND_API.G_TRUE THEN
              -- Check the cache before hitting the database.
              l_exists_flag := 'N';
              l_valid_flag := 'Y';
              IF p_contact_tbl.count > 0 THEN
                 For  contact_count in p_contact_tbl.FIRST .. p_contact_tbl.LAST
                 LOOP
                    IF p_contact_tbl(contact_count).contact_party_id = p_party_rec.PARTY_ID AND
                       p_contact_tbl(contact_count).party_source_table = p_party_rec.PARTY_SOURCE_TABLE AND
                       p_contact_tbl(contact_count).contact_ip_id = p_party_rec.CONTACT_IP_ID THEN
                       l_valid_flag := p_contact_tbl(contact_count).valid_flag;
                       l_exists_flag := 'Y';
                       exit;
                    END IF;
                 END LOOP;
                 --
/*
                 IF l_valid_flag <> 'Y' THEN
	            FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_CONTACT_INFO');
	            FND_MESSAGE.SET_TOKEN('CONTACT_PARTY_ID',p_party_rec.PARTY_ID);
	            FND_MESSAGE.SET_TOKEN('CONTACT_SOURCE_TABLE',p_party_rec.PARTY_SOURCE_TABLE);
                    FND_MSG_PUB.Add;
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
*/ -- code commented by sguthiva for bug 2619247.
              END IF;
              --
              IF l_exists_flag <> 'Y' THEN
                 p_party_count_rec.contact_id_count := p_party_count_rec.contact_id_count + 1;
                 p_contact_tbl(p_party_count_rec.contact_id_count).contact_party_id := p_party_rec.PARTY_ID;
                 p_contact_tbl(p_party_count_rec.contact_id_count).party_source_table := p_party_rec.PARTY_SOURCE_TABLE;
                 p_contact_tbl(p_party_count_rec.contact_id_count).contact_ip_id := p_party_rec.CONTACT_IP_ID;
                /* code commented by sguthiva on 09-25-02 for bug 2377709
                 IF NOT(CSI_Instance_parties_vld_pvt.Is_Contact_Valid
                                                     (p_party_rec.PARTY_ID,
                                                      p_party_rec.PARTY_SOURCE_TABLE,
                                                      p_party_rec.CONTACT_IP_ID)) THEN
                    p_contact_tbl(p_party_count_rec.contact_id_count).valid_flag := 'N';
                    RAISE FND_API.G_EXC_ERROR;
                 ELSE
                    p_contact_tbl(p_party_count_rec.contact_id_count).valid_flag := 'Y';
	         END IF;
                end of code comment  */
              END IF;
           END IF; -- p_called_from_grp check
           -- Verify the relationship_type_code is valid
           -- Check the cache before hitting the database.
           l_exists_flag := 'N';
           l_valid_flag := 'Y';
           IF p_party_rel_type_tbl.count > 0 THEN
              For rel_type in p_party_rel_type_tbl.FIRST .. p_party_rel_type_tbl.LAST
              LOOP
                 IF p_party_rel_type_tbl(rel_type).rel_type_code = p_party_rec.RELATIONSHIP_TYPE_CODE AND
                    p_party_rel_type_tbl(rel_type).contact_flag = 'C' THEN
                    l_valid_flag := p_party_rel_type_tbl(rel_type).valid_flag;
                    l_exists_flag := 'Y';
                    exit;
                 END IF;
              END LOOP;
              --
              IF l_valid_flag <> 'Y' THEN
		 FND_MESSAGE.SET_NAME('CSI','CSI_API_INV_PARTY_TYPE_CODE');
		 FND_MESSAGE.SET_TOKEN('RELATIONSHIP_TYPE_CODE',p_party_rec.RELATIONSHIP_TYPE_CODE);
		 FND_MSG_PUB.Add;
                 RAISE FND_API.G_EXC_ERROR;
              END IF;
           END IF;
           --
           IF l_exists_flag <> 'Y' THEN
              p_party_count_rec.rel_type_count := p_party_count_rec.rel_type_count + 1;
              p_party_rel_type_tbl(p_party_count_rec.rel_type_count).rel_type_code := p_party_rec.RELATIONSHIP_TYPE_CODE;
              p_party_rel_type_tbl(p_party_count_rec.rel_type_count).contact_flag := 'C';
              IF NOT(CSI_Instance_parties_vld_pvt.Is_Pty_Rel_type_Valid
                                                  (p_party_rec.RELATIONSHIP_TYPE_CODE,
                                                   'C'    )) THEN
                 p_party_rel_type_tbl(p_party_count_rec.rel_type_count).valid_flag := 'N';
                 RAISE FND_API.G_EXC_ERROR;
              ELSE
                 p_party_rel_type_tbl(p_party_count_rec.rel_type_count).valid_flag := 'Y';
              END IF;
           END IF;
        ELSE
           -- Verify the relationship_type_code is valid
           -- Check the cache before hitting the database.
           l_exists_flag := 'N';
           l_valid_flag := 'Y';
           IF p_party_rel_type_tbl.count > 0 THEN
              For rel_type in p_party_rel_type_tbl.FIRST .. p_party_rel_type_tbl.LAST
              LOOP
                 IF p_party_rel_type_tbl(rel_type).rel_type_code = p_party_rec.RELATIONSHIP_TYPE_CODE AND
                    p_party_rel_type_tbl(rel_type).contact_flag = 'P' THEN
                    l_valid_flag := p_party_rel_type_tbl(rel_type).valid_flag;
                    l_exists_flag := 'Y';
                    exit;
                 END IF;
              END LOOP;
              --
              IF l_valid_flag <> 'Y' THEN
		 FND_MESSAGE.SET_NAME('CSI','CSI_API_INV_PARTY_TYPE_CODE');
		 FND_MESSAGE.SET_TOKEN('RELATIONSHIP_TYPE_CODE',p_party_rec.RELATIONSHIP_TYPE_CODE);
		 FND_MSG_PUB.Add;
                 RAISE FND_API.G_EXC_ERROR;
              END IF;
           END IF;
           --
           IF l_exists_flag <> 'Y' THEN
              p_party_count_rec.rel_type_count := p_party_count_rec.rel_type_count + 1;
              p_party_rel_type_tbl(p_party_count_rec.rel_type_count).rel_type_code := p_party_rec.RELATIONSHIP_TYPE_CODE;
              p_party_rel_type_tbl(p_party_count_rec.rel_type_count).contact_flag := 'P';
              IF NOT(CSI_Instance_parties_vld_pvt.Is_Pty_Rel_type_Valid
                                                  (p_party_rec.RELATIONSHIP_TYPE_CODE,
                                                   'P'    )) THEN
                 p_party_rel_type_tbl(p_party_count_rec.rel_type_count).valid_flag := 'N';
                 RAISE FND_API.G_EXC_ERROR;
              ELSE
                 p_party_rel_type_tbl(p_party_count_rec.rel_type_count).valid_flag := 'Y';
              END IF;
           END IF;
        END IF;


        -- If active_start_date is null or G_MISS value then assign sysdate
        IF ((p_party_rec.ACTIVE_START_DATE IS NULL ) OR
           ( p_party_rec.ACTIVE_START_DATE = FND_API.G_MISS_DATE)) THEN
             p_party_rec.ACTIVE_START_DATE := SYSDATE;
        END IF;

        -- verify if the active_start_date is valid
        IF p_called_from_grp <> FND_API.G_TRUE THEN
           IF NOT(CSI_Instance_parties_vld_pvt.Is_StartDate_Valid
                                         (p_party_rec.ACTIVE_START_DATE,
                                          p_party_rec.ACTIVE_END_DATE ,
                                          p_party_rec.INSTANCE_ID  )) THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF;

        -- Verify if the active_end_date is valid
        IF p_called_from_grp <> FND_API.G_TRUE THEN
           IF ((p_party_rec.ACTIVE_END_DATE is NOT NULL) AND
              ( p_party_rec.ACTIVE_END_DATE <> FND_API.G_MISS_DATE)) THEN
                IF NOT(CSI_Instance_parties_vld_pvt.Is_EndDate_Valid(p_party_rec.ACTIVE_START_DATE,
                                  p_party_rec.ACTIVE_END_DATE ,
                                  p_party_rec.INSTANCE_ID,
                                  p_party_rec.INSTANCE_PARTY_ID,
			          p_txn_rec.TRANSACTION_ID))  THEN
                   RAISE FND_API.G_EXC_ERROR;
                END IF;
           END IF;
        END IF;

        -- Verify the instance owner exists already if exists then raise error
        IF p_called_from_grp <> FND_API.G_TRUE THEN
           IF p_party_rec.RELATIONSHIP_TYPE_CODE = 'OWNER' THEN
               IF CSI_Instance_parties_vld_pvt.Is_Inst_Owner_exists
                                     (p_instance_id => p_party_rec.INSTANCE_ID,
                                      p_instance_party_id => p_party_rec.instance_party_id ) THEN
                 RAISE FND_API.G_EXC_ERROR;
               END IF;
           END IF;
        END IF;

        -- Verify that there is only one Preferred Party for a
        -- given instance party relationship
        IF p_party_rec.PREFERRED_FLAG = 'Y' THEN
          IF p_party_rec.CONTACT_FLAG <> 'Y' THEN
             IF p_party_rec.PARTY_SOURCE_TABLE NOT IN ('GROUP','TEAM') THEN
               FND_MESSAGE.SET_NAME('CSI','CSI_PREFERRED_PTY_TYPE');
               FND_MESSAGE.SET_TOKEN('PARTY_TYPE',p_party_rec.PARTY_SOURCE_TABLE);
               FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_party_rec.INSTANCE_ID);
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
             END IF;
          END IF;
        END IF;

        -- Verify that there is only one Primary Party for a
        -- given instance party relationship
        IF p_called_from_grp <> FND_API.G_TRUE THEN
	   IF p_party_rec.PRIMARY_FLAG = 'Y' THEN
	     IF p_party_rec.CONTACT_FLAG = 'Y' THEN
	       IF CSI_Instance_parties_vld_pvt.Is_Primary_Contact_Pty
			    (p_party_rec.INSTANCE_ID,
			     p_party_rec.CONTACT_IP_ID,
			     p_party_rec.RELATIONSHIP_TYPE_CODE,
			     p_party_rec.ACTIVE_START_DATE,
			     p_party_rec.ACTIVE_END_DATE) THEN
		 RAISE FND_API.G_EXC_ERROR;
	       END IF;
	     ELSE
	       IF p_party_rec.PARTY_SOURCE_TABLE NOT IN ('GROUP','TEAM') THEN
		  FND_MESSAGE.SET_NAME('CSI','CSI_PRIMARY_PTY_TYPE');
		  FND_MESSAGE.SET_TOKEN('PARTY_TYPE',p_party_rec.PARTY_SOURCE_TABLE);
		  FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_party_rec.INSTANCE_ID);
		  FND_MSG_PUB.Add;
		  RAISE FND_API.G_EXC_ERROR;
	       ELSE
		 IF CSI_Instance_parties_vld_pvt.Is_Primary_Pty
			    (p_party_rec.INSTANCE_ID,
			     p_party_rec.RELATIONSHIP_TYPE_CODE,
			     p_party_rec.ACTIVE_START_DATE,
			     p_party_rec.ACTIVE_END_DATE) THEN
		    RAISE FND_API.G_EXC_ERROR;
		 END IF;
	       END IF;
	     END IF;
	   END IF;
        END IF;
      --
      IF p_called_from_grp <> fnd_api.g_true THEN
       -- If it is an owner party then update csi_item_instances
        IF p_party_rec.RELATIONSHIP_TYPE_CODE = 'OWNER' THEN
           update csi_item_instances
           set    owner_party_source_table = p_party_rec.party_source_table,
                  owner_party_id  = p_party_rec.party_id
           where  instance_id     = p_party_rec.instance_id;

        END IF;

       -- A contact marked as 'Primary' can also be marked as 'Preferred' or
       -- 'Non-Preferred' at the same time.
        IF p_party_rec.preferred_flag IS NULL OR
           p_party_rec.preferred_flag=fnd_api.g_miss_char
        THEN
           p_party_rec.preferred_flag:='N';
        END IF;

        IF (p_party_rec.preferred_flag='E' OR
            p_party_rec.preferred_flag='e' )
        THEN
            p_party_rec.preferred_flag:='E';
        END IF;

       -- A contact marked as Primary cannot be marked as 'Excluded'
        IF (p_party_rec.primary_flag IS NOT NULL AND
            p_party_rec.primary_flag <> fnd_api.g_miss_char AND
            p_party_rec.primary_flag = 'Y' ) AND
            p_party_rec.preferred_flag='E'
        THEN
		  fnd_message.set_name('CSI','CSI_PRIMARY_PTY_EXC');
		  fnd_msg_pub.Add;
		  RAISE fnd_api.g_exc_error;
        END IF;

        -- Possible values for preferred flag are
        -- 'N','Y' and 'E'.
        IF  p_party_rec.preferred_flag='Y' OR
            p_party_rec.preferred_flag='N' OR
            p_party_rec.preferred_flag='E'
        THEN
           NULL;
        ELSE
		  fnd_message.set_name('CSI','CSI_PREFERRED_VALUES');
          fnd_message.set_token('PREFERRED_FLAG',p_party_rec.preferred_flag);
		  fnd_msg_pub.Add;
		  RAISE fnd_api.g_exc_error;
        END IF;


        -- Call table handlers to insert into the csi_i_parties table
        CSI_I_PARTIES_PKG.Insert_Row(
          p_INSTANCE_PARTY_ID  =>  p_party_rec.INSTANCE_PARTY_ID      ,
          p_INSTANCE_ID        =>  p_party_rec.INSTANCE_ID            ,
          p_PARTY_SOURCE_TABLE =>  p_party_rec.PARTY_SOURCE_TABLE     ,
          p_PARTY_ID           =>   p_party_rec.PARTY_ID              ,
          p_RELATIONSHIP_TYPE_CODE =>  p_party_rec.RELATIONSHIP_TYPE_CODE,
          p_CONTACT_FLAG       =>   p_party_rec.CONTACT_FLAG          ,
          p_CONTACT_IP_ID      =>   p_party_rec.CONTACT_IP_ID         ,
          p_ACTIVE_START_DATE  =>  p_party_rec.ACTIVE_START_DATE       ,
          p_ACTIVE_END_DATE    =>  p_party_rec.ACTIVE_END_DATE         ,
          p_CONTEXT            =>  p_party_rec.CONTEXT                 ,
          p_ATTRIBUTE1         =>  p_party_rec.ATTRIBUTE1              ,
          p_ATTRIBUTE2         =>  p_party_rec.ATTRIBUTE2              ,
          p_ATTRIBUTE3         =>  p_party_rec.ATTRIBUTE3              ,
          p_ATTRIBUTE4         =>  p_party_rec.ATTRIBUTE4              ,
          p_ATTRIBUTE5         =>  p_party_rec.ATTRIBUTE5              ,
          p_ATTRIBUTE6         =>  p_party_rec.ATTRIBUTE6              ,
          p_ATTRIBUTE7         =>  p_party_rec.ATTRIBUTE7               ,
          p_ATTRIBUTE8         =>  p_party_rec.ATTRIBUTE8               ,
          p_ATTRIBUTE9         =>  p_party_rec.ATTRIBUTE9               ,
          p_ATTRIBUTE10        =>  p_party_rec.ATTRIBUTE10              ,
          p_ATTRIBUTE11        =>  p_party_rec.ATTRIBUTE11              ,
          p_ATTRIBUTE12        =>  p_party_rec.ATTRIBUTE12              ,
          p_ATTRIBUTE13        =>  p_party_rec.ATTRIBUTE13              ,
          p_ATTRIBUTE14        =>  p_party_rec.ATTRIBUTE14              ,
          p_ATTRIBUTE15        =>  p_party_rec.ATTRIBUTE15              ,
          p_CREATED_BY         =>  FND_GLOBAL.USER_ID                   ,
          p_CREATION_DATE      =>  SYSDATE                              ,
          p_LAST_UPDATED_BY    =>  FND_GLOBAL.USER_ID                   ,
          p_LAST_UPDATE_DATE   =>  SYSDATE                              ,
          p_LAST_UPDATE_LOGIN  =>  FND_GLOBAL.LOGIN_ID                  ,
          p_OBJECT_VERSION_NUMBER  => 1                                 ,
          p_PRIMARY_FLAG       =>   p_party_rec.PRIMARY_FLAG            ,
          p_PREFERRED_FLAG       =>   p_party_rec.PREFERRED_FLAG        );


        -- Call create_transaction to create txn log
        CSI_TRANSACTIONS_PVT.Create_transaction
          (
             p_api_version            => p_api_version
            ,p_commit                 => p_commit
            ,p_init_msg_list          => p_init_msg_list
            ,p_validation_level       => p_validation_level
            ,p_Success_If_Exists_Flag => 'Y'
            ,P_transaction_rec       => p_txn_rec
            ,x_return_status          => x_return_status
            ,x_msg_count              => x_msg_count
            ,x_msg_data               => x_msg_data          );

         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	     l_msg_index := 1;
             l_msg_count := x_msg_count;
    	     WHILE l_msg_count > 0 LOOP
     		       x_msg_data := FND_MSG_PUB.GET(
  	       			                 l_msg_index,
    	  		                     FND_API.G_FALSE	);
	               csi_gen_utility_pvt.put_line( 'message data = '||x_msg_data);
	    	       l_msg_index := l_msg_index + 1;
		           l_msg_count := l_msg_count - 1;
	      END LOOP;
              RAISE FND_API.G_EXC_ERROR;
         END IF;

      -- Generate a unique instance_party_history_id from the sequence
      l_inst_party_his_id := CSI_Instance_parties_vld_pvt.gen_inst_party_hist_id;

      -- Call table handlers to insert into csi_i_parties_h table
      CSI_I_PARTIES_H_PKG.Insert_Row
      (
          px_INSTANCE_PARTY_HISTORY_ID   => l_inst_party_his_id       ,
          p_INSTANCE_PARTY_ID            => p_party_rec.INSTANCE_PARTY_ID   ,
          p_TRANSACTION_ID               => p_txn_rec.TRANSACTION_ID  ,
          p_OLD_PARTY_SOURCE_TABLE       => NULL                      ,
          p_NEW_PARTY_SOURCE_TABLE       => p_party_rec.PARTY_SOURCE_TABLE,
          p_OLD_PARTY_ID                 => NULL                      ,
          p_NEW_PARTY_ID                 => p_party_rec.PARTY_ID      ,
          p_OLD_RELATIONSHIP_TYPE_CODE   => NULL                      ,
          p_NEW_RELATIONSHIP_TYPE_CODE   => p_party_rec.RELATIONSHIP_TYPE_CODE,
          p_OLD_CONTACT_FLAG             => NULL                      ,
          p_NEW_CONTACT_FLAG             => p_party_rec.CONTACT_FLAG  ,
          p_OLD_CONTACT_IP_ID            => NULL                      ,
          p_NEW_CONTACT_IP_ID            => p_party_rec.CONTACT_IP_ID ,
          p_OLD_ACTIVE_START_DATE        => NULL                      ,
          p_NEW_ACTIVE_START_DATE        => p_party_rec.ACTIVE_START_DATE,
          p_OLD_ACTIVE_END_DATE          => NULL                      ,
          p_NEW_ACTIVE_END_DATE          => p_party_rec.ACTIVE_END_DATE,
          p_OLD_CONTEXT                  => NULL                      ,
          p_NEW_CONTEXT                  => p_party_rec.context       ,
          p_OLD_ATTRIBUTE1               => NULL                      ,
          p_NEW_ATTRIBUTE1               => p_party_rec.ATTRIBUTE1    ,
          p_OLD_ATTRIBUTE2               => NULL                      ,
          p_NEW_ATTRIBUTE2               => p_party_rec.ATTRIBUTE2    ,
          p_OLD_ATTRIBUTE3               => NULL                      ,
          p_NEW_ATTRIBUTE3               => p_party_rec.ATTRIBUTE3    ,
          p_OLD_ATTRIBUTE4               => NULL                      ,
          p_NEW_ATTRIBUTE4               => p_party_rec.ATTRIBUTE4    ,
          p_OLD_ATTRIBUTE5               => NULL                      ,
          p_NEW_ATTRIBUTE5               => p_party_rec.ATTRIBUTE5    ,
          p_OLD_ATTRIBUTE6               => NULL                      ,
          p_NEW_ATTRIBUTE6               => p_party_rec.ATTRIBUTE6    ,
          p_OLD_ATTRIBUTE7               => NULL                      ,
          p_NEW_ATTRIBUTE7               => p_party_rec.ATTRIBUTE7    ,
          p_OLD_ATTRIBUTE8               => NULL                      ,
          p_NEW_ATTRIBUTE8               => p_party_rec.ATTRIBUTE8    ,
          p_OLD_ATTRIBUTE9               => NULL                      ,
          p_NEW_ATTRIBUTE9               => p_party_rec.ATTRIBUTE9    ,
          p_OLD_ATTRIBUTE10              => NULL                      ,
          p_NEW_ATTRIBUTE10              => p_party_rec.ATTRIBUTE10   ,
          p_OLD_ATTRIBUTE11              => NULL                      ,
          p_NEW_ATTRIBUTE11              => p_party_rec.ATTRIBUTE11   ,
          p_OLD_ATTRIBUTE12              => NULL                      ,
          p_NEW_ATTRIBUTE12              => p_party_rec.ATTRIBUTE12   ,
          p_OLD_ATTRIBUTE13              => NULL                      ,
          p_NEW_ATTRIBUTE13              => p_party_rec.ATTRIBUTE13   ,
          p_OLD_ATTRIBUTE14              => NULL                      ,
          p_NEW_ATTRIBUTE14              => p_party_rec.ATTRIBUTE14   ,
          p_OLD_ATTRIBUTE15              => NULL                      ,
          p_NEW_ATTRIBUTE15              => p_party_rec.ATTRIBUTE15   ,
          p_FULL_DUMP_FLAG               => 'N'                       ,
          p_CREATED_BY                    => FND_GLOBAL.USER_ID        ,
          p_CREATION_DATE                 => sysdate                   ,
          p_LAST_UPDATED_BY               => FND_GLOBAL.USER_ID        ,
          p_LAST_UPDATE_DATE              => sysdate                   ,
          p_LAST_UPDATE_LOGIN             => FND_GLOBAL.LOGIN_ID       ,
          p_OBJECT_VERSION_NUMBER         => 1                         ,
          p_OLD_PRIMARY_FLAG             => NULL                      ,
          p_NEW_PRIMARY_FLAG             => p_party_rec.PRIMARY_FLAG  ,
          p_OLD_PREFERRED_FLAG             => NULL                      ,
          p_NEW_PREFERRED_FLAG             => p_party_rec.PREFERRED_FLAG  );

        END IF; -- p_called_from_grp check

      END IF; -- Added by sk for bug 2232880

        --
        -- End of API body

        -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
        END IF;


        -- Standard call to get message count and if count is  get message info.
        FND_MSG_PUB.Count_And_Get
                (p_count        =>      x_msg_count ,
                 p_data         =>      x_msg_data  );
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO create_inst_party_rel_pvt;
                x_return_status := FND_API.G_RET_STS_ERROR ;
               FND_MSG_PUB.Count_And_Get
                (       p_count     =>      x_msg_count,
                        p_data      =>      x_msg_data  );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO create_inst_party_rel_pvt;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count   =>      x_msg_count,
                        p_data    =>      x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO create_inst_party_rel_pvt;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       g_pkg_name   ,
                        l_api_name   );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_count     =>      x_msg_count,
                        p_data      =>      x_msg_data   );
END  create_inst_party_relationship;

/*------------------------------------------------------------*/
/* Procedure name:  Update_inst_party_relationship            */
/* Description :   Procedure used to  update the existing     */
/*                 instance -party relationships              */
/*------------------------------------------------------------*/

PROCEDURE update_inst_party_relationship
    ( p_api_version                 IN  NUMBER
     ,p_commit                      IN  VARCHAR2
     ,p_init_msg_list               IN  VARCHAR2
     ,p_validation_level            IN  NUMBER
     ,p_party_rec                   IN OUT NOCOPY  csi_datastructures_pub.party_rec
     ,p_txn_rec                     IN OUT NOCOPY  csi_datastructures_pub.transaction_rec
     ,x_return_status               OUT NOCOPY  VARCHAR2
     ,x_msg_count                   OUT NOCOPY  NUMBER
     ,x_msg_data                    OUT NOCOPY  VARCHAR2
     ) IS

    l_api_name      CONSTANT VARCHAR2(30)   := 'UPDATE_INST_PARTY_RELATIONSHIP';
    l_api_version   CONSTANT NUMBER         := 1.0;
    l_csi_debug_level        NUMBER;
    l_curr_party_rec         csi_datastructures_pub.party_rec;
    l_temp_party_rec         csi_datastructures_pub.party_rec;
    l_cont_party_rec         csi_datastructures_pub.party_rec;
    l_init_party_rec         csi_datastructures_pub.party_rec;
    l_msg_index              NUMBER;
    l_msg_count              NUMBER;
    l_line_count             NUMBER;
    l_object_version_number  NUMBER;
    l_inst_party_his_id      NUMBER;
    l_full_dump_frequency    NUMBER;
    l_mod_value              NUMBER;
    l_party_account_rec      csi_datastructures_pub.party_account_rec;
    l_internal_party_id      NUMBER;

    x_msg_index_out          NUMBER;
    l_acct_class_code        VARCHAR2(10);

    -- alternate pk check variables
    l_alt_pk_instance_id    NUMBER;
    l_alt_pk_pty_source_tab VARCHAR2(30);
    l_alt_pk_party_id       NUMBER;
    l_alt_pk_rel_type_code  VARCHAR2(30);
    l_alt_pk_contact_flag   VARCHAR2(1);

  CURSOR GET_IP_ACCOUNT (p_inst_party_id   IN  NUMBER) IS
    SELECT
        ip_account_id,
        object_version_number
    FROM csi_ip_accounts
    WHERE instance_party_id = p_inst_party_id
     AND (( ACTIVE_END_DATE IS NULL) OR (ACTIVE_END_DATE >= SYSDATE)) ;

  CURSOR get_curr_party_rec (p_inst_party_id   IN  NUMBER) IS
     SELECT
     instance_party_id  ,
     instance_id        ,
     party_source_table ,
     party_id           ,
     relationship_type_code,
     contact_flag       ,
     contact_ip_id      ,
     active_start_date  ,
     active_end_date    ,
     context            ,
     attribute1         ,
     attribute2         ,
     attribute3         ,
     attribute4         ,
     attribute5         ,
     attribute6         ,
     attribute7         ,
     attribute8         ,
     attribute9         ,
     attribute10        ,
     attribute11        ,
     attribute12        ,
     attribute13        ,
     attribute14        ,
     attribute15        ,
     object_version_number,
     primary_flag       ,
     preferred_flag     ,
     null parent_tbl_index  ,
     null call_contracts,
     null interface_id,
     null contact_parent_tbl_index,
     null cascade_ownership_flag -- Added for bug 2972082
    FROM CSI_I_PARTIES
    WHERE INSTANCE_PARTY_ID = p_inst_party_id
    FOR UPDATE OF OBJECT_VERSION_NUMBER ;

  CURSOR get_cont_party_rec (p_cont_ip_id   IN  NUMBER) IS
     SELECT
     instance_party_id  ,
     instance_id        ,
     party_source_table ,
     party_id           ,
     relationship_type_code,
     contact_flag       ,
     contact_ip_id      ,
     active_start_date  ,
     active_end_date    ,
     context            ,
     attribute1         ,
     attribute2         ,
     attribute3         ,
     attribute4         ,
     attribute5         ,
     attribute6         ,
     attribute7         ,
     attribute8         ,
     attribute9         ,
     attribute10        ,
     attribute11        ,
     attribute12        ,
     attribute13        ,
     attribute14        ,
     attribute15        ,
     object_version_number,
     primary_flag       ,
     preferred_flag
    FROM CSI_I_PARTIES
    WHERE CONTACT_IP_ID = p_cont_ip_id
    AND (( ACTIVE_END_DATE IS NULL) OR (ACTIVE_END_DATE > SYSDATE))
    FOR UPDATE OF OBJECT_VERSION_NUMBER ;

  CURSOR curr_instance_rec(p_instance_id IN NUMBER)  IS
    SELECT
     INSTANCE_ID,
     INSTANCE_NUMBER,
     EXTERNAL_REFERENCE,
     INVENTORY_ITEM_ID,
     LAST_VLD_ORGANIZATION_ID VLD_ORGANIZATION_ID,
     INVENTORY_REVISION,
     INV_MASTER_ORGANIZATION_ID,
     SERIAL_NUMBER,
     MFG_SERIAL_NUMBER_FLAG,
     LOT_NUMBER,
     QUANTITY,
     UNIT_OF_MEASURE,
     ACCOUNTING_CLASS_CODE,
     INSTANCE_CONDITION_ID,
     INSTANCE_STATUS_ID,
     CUSTOMER_VIEW_FLAG,
     MERCHANT_VIEW_FLAG,
     SELLABLE_FLAG,
     SYSTEM_ID,
     INSTANCE_TYPE_CODE,
     ACTIVE_START_DATE,
     ACTIVE_END_DATE,
     LOCATION_TYPE_CODE,
     LOCATION_ID,
     INV_ORGANIZATION_ID,
     INV_SUBINVENTORY_NAME,
     INV_LOCATOR_ID,
     PA_PROJECT_ID,
     PA_PROJECT_TASK_ID,
     IN_TRANSIT_ORDER_LINE_ID,
     WIP_JOB_ID,
     PO_ORDER_LINE_ID,
     LAST_OE_ORDER_LINE_ID,
     LAST_OE_RMA_LINE_ID,
     LAST_PO_PO_LINE_ID,
     LAST_OE_PO_NUMBER,
     LAST_WIP_JOB_ID,
     LAST_PA_PROJECT_ID,
     LAST_PA_TASK_ID,
     LAST_OE_AGREEMENT_ID,
     INSTALL_DATE,
     MANUALLY_CREATED_FLAG,
     RETURN_BY_DATE,
     ACTUAL_RETURN_DATE,
     CREATION_COMPLETE_FLAG,
     COMPLETENESS_FLAG,
     NULL VERSION_LABEL,
     NULL VERSION_LABEL_DESCRIPTION,
     CONTEXT,
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
     OBJECT_VERSION_NUMBER,
     LAST_TXN_LINE_DETAIL_ID,
     INSTALL_LOCATION_TYPE_CODE,
     INSTALL_LOCATION_ID,
     INSTANCE_USAGE_CODE,
     NULL CHECK_FOR_INSTANCE_EXPIRY,
     NULL PROCESSED_FLAG,
     NULL CALL_CONTRACTS,
     NULL INTERFACE_ID,
     NULL GRP_CALL_CONTRACTS,
     CONFIG_INST_HDR_ID,
     CONFIG_INST_REV_NUM,
     CONFIG_INST_ITEM_ID,
     CONFIG_VALID_STATUS,
     INSTANCE_DESCRIPTION,
     NULL CALL_BATCH_VALIDATION,
     NULL REQUEST_ID,
     NULL PROGRAM_APPLICATION_ID,
     NULL PROGRAM_ID,
     NULL PROGRAM_UPDATE_DATE,
     NULL cascade_ownership_flag, -- Added for bug 2972082
     NULL NETWORK_ASSET_FLAG,
     NULL MAINTAINABLE_FLAG,
     NULL PN_LOCATION_ID,
     NULL ASSET_CRITICALITY_CODE,
     NULL CATEGORY_ID,
     NULL EQUIPMENT_GEN_OBJECT_ID,
     NULL INSTANTIATION_FLAG,
     NULL LINEAR_LOCATION_ID,
     NULL OPERATIONAL_LOG_FLAG,
     NULL CHECKIN_STATUS,
     NULL SUPPLIER_WARRANTY_EXP_DATE,
     NULL ATTRIBUTE16,
     NULL ATTRIBUTE17,
     NULL ATTRIBUTE18,
     NULL ATTRIBUTE19,
     NULL ATTRIBUTE20,
     NULL ATTRIBUTE21,
     NULL ATTRIBUTE22,
     NULL ATTRIBUTE23,
     NULL ATTRIBUTE24,
     NULL ATTRIBUTE25,
     NULL ATTRIBUTE26,
     NULL ATTRIBUTE27,
     NULL ATTRIBUTE28,
     NULL ATTRIBUTE29,
     NULL ATTRIBUTE30,
     NULL PURCHASE_UNIT_PRICE,
     NULL PURCHASE_CURRENCY_CODE,
     NULL PAYABLES_UNIT_PRICE,
     NULL PAYABLES_CURRENCY_CODE,
     NULL SALES_UNIT_PRICE,
     NULL SALES_CURRENCY_CODE,
     NULL OPERATIONAL_STATUS_CODE,
     NULL DEPARTMENT_ID,
     NULL WIP_ACCOUNTING_CLASS,
     NULL AREA_ID,
     NULL OWNER_PARTY_ID,
     NULL SOURCE_CODE -- Bug 6407307, added Code for Siebel Genesis Project
    FROM  csi_item_instances
    WHERE instance_id = p_instance_id;

    l_curr_instance_rec  csi_datastructures_pub.instance_rec;


   CURSOR pty_hist_csr (p_party_hist_id NUMBER) IS
   SELECT  instance_party_history_id
          ,instance_party_id
          ,transaction_id
          ,old_party_source_table
          ,new_party_source_table
          ,old_party_id
          ,new_party_id
          ,old_relationship_type_code
          ,new_relationship_type_code
          ,old_contact_flag
          ,new_contact_flag
          ,old_contact_ip_id
          ,new_contact_ip_id
          ,old_active_start_date
          ,new_active_start_date
          ,old_active_end_date
          ,new_active_end_date
          ,old_context
          ,new_context
          ,old_attribute1
          ,new_attribute1
          ,old_attribute2
          ,new_attribute2
          ,old_attribute3
          ,new_attribute3
          ,old_attribute4
          ,new_attribute4
          ,old_attribute5
          ,new_attribute5
          ,old_attribute6
          ,new_attribute6
          ,old_attribute7
          ,new_attribute7
          ,old_attribute8
          ,new_attribute8
          ,old_attribute9
          ,new_attribute9
          ,old_attribute10
          ,new_attribute10
          ,old_attribute11
          ,new_attribute11
          ,old_attribute12
          ,new_attribute12
          ,old_attribute13
          ,new_attribute13
          ,old_attribute14
          ,new_attribute14
          ,old_attribute15
          ,new_attribute15
          ,full_dump_flag
          ,object_version_number
          ,old_primary_flag
          ,new_primary_flag
          ,old_preferred_flag
          ,new_preferred_flag
   FROM   csi_i_parties_h
   WHERE  csi_i_parties_h.instance_party_history_id = p_party_hist_id
   FOR UPDATE OF object_version_number ;
   l_pty_hist_csr    pty_hist_csr%rowtype;
   l_party_hist_id   NUMBER;
   l_open_service    VARCHAR2(1);
   l_party_hist_rec  csi_datastructures_pub.party_history_rec;
   l_ins_pty_found   NUMBER;
   l_pty_end_date    DATE;

   l_inst_just_expired    VARCHAR2(1) := FND_API.G_FALSE;  --Added for bug 7517240
BEGIN
   -- Standard Start of API savepoint
   -- SAVEPOINT    update_inst_party_rel_pvt  ;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (    l_api_version           ,
					   p_api_version           ,
					   l_api_name              ,
					   g_pkg_name              )
   THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
	   FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Check the profile option CSI_DEBUG_LEVEL for debug message reporting
   l_csi_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If CSI_DEBUG_LEVEL = 1 then dump the procedure name
   IF (l_csi_debug_level > 0) THEN
       csi_gen_utility_pvt.put_line( 'update_inst_party_relationship ');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (l_csi_debug_level> 1) THEN
       csi_gen_utility_pvt.put_line( 'update_inst_party_relationship:' ||
						    p_api_version    ||'-'||
						    p_commit         ||'-'||
						    p_init_msg_list        );
       -- Dump the records in the log file
       csi_gen_utility_pvt.dump_party_rec(p_party_rec);
       csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
   END IF;
   -- Start API body
   --
   -- Check if all the required parameters are passed
   CSI_Instance_parties_vld_pvt.Check_Reqd_Param_num
	 (    p_party_rec.INSTANCE_PARTY_ID ,
	       '  p_party_rec.INSTANCE_PARTY_ID ',
		  l_api_name                 );
   --
   IF p_party_rec.party_id IS NULL THEN
      FND_MESSAGE.SET_NAME('CSI','CSI_API_MANDATORY_PARTY');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   --
   -- Check if the instance party id  is valid
   -- End commentation by sk for bug 2232880
   -- Verify if the instance_id exists in csi_item_instances
   IF p_party_rec.INSTANCE_ID <> FND_API.G_MISS_NUM THEN
      --Added query for bug 7517240
      IF p_party_rec.ACTIVE_END_DATE IS NOT NULL AND p_party_rec.ACTIVE_END_DATE < SYSDATE THEN
        BEGIN
          SELECT 'T'
          INTO  l_inst_just_expired
          FROM  CSI_ITEM_INSTANCES_H
          WHERE INSTANCE_ID = p_party_rec.INSTANCE_ID
          AND   TRANSACTION_ID = p_txn_rec.TRANSACTION_ID
          AND   OLD_ACTIVE_END_DATE IS NULL
          AND   NEW_ACTIVE_END_DATE < SYSDATE
          AND   ROWNUM = 1;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_inst_just_expired := FND_API.G_FALSE;
        END;
      END IF;
      IF l_inst_just_expired = FND_API.G_FALSE
        AND NOT(CSI_Instance_parties_vld_pvt.Is_InstanceID_Valid(p_party_rec.INSTANCE_ID)) THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   -- Verify the instance owner exists already if exists then raise error
   IF p_party_rec.RELATIONSHIP_TYPE_CODE = 'OWNER' THEN
      IF CSI_Instance_parties_vld_pvt.Is_Inst_Owner_exists
                                  (p_instance_id   => p_party_rec.INSTANCE_ID,
                                   p_instance_party_id => p_party_rec.instance_party_id ) THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   -- start of addition of code by rtalluri for bugfix 2324745 on 04/23/02
   -- validating the owner
   IF l_curr_party_rec.instance_party_id = p_party_rec.instance_party_id
       AND l_curr_party_rec.party_id <> p_party_rec.party_id
       AND (p_party_rec.party_id is not null and p_party_rec.party_id <> fnd_api.g_miss_num)
       AND l_curr_party_rec.relationship_type_code = 'OWNER'
   THEN
      OPEN curr_instance_rec(p_party_rec.instance_id);
      FETCH curr_instance_rec INTO l_curr_instance_rec;
      IF NOT (csi_item_instance_vld_pvt.Validate_Uniqueness(p_instance_rec     => l_curr_instance_rec,
                                                            p_party_rec        => p_party_rec,
                                                            p_csi_txn_type_id  => p_txn_rec.transaction_type_id
															)) THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE curr_instance_rec;
   END IF;
   -- end of addition of code by rtalluri for bugfix 2324745 on 04/23/02
   -- The following code has been added for the following scenario...
   -- For the customer merge/account merge, all the parent and the child instances
   -- were selected before calling update_item_instance.
   -- In this case the child records object_version numbers will be updated
   -- if the child owner party is same as the parent.
   IF p_txn_rec.transaction_type_id=7
   THEN
      BEGIN
         SELECT object_version_number
         INTO   p_party_rec.object_version_number
         FROM   csi_i_parties
         WHERE  instance_party_id=p_party_rec.instance_party_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            csi_gen_utility_pvt.put_line('Passed instance_party_id : '||p_party_rec.instance_party_id||' is not found.');
            RAISE FND_API.G_EXC_ERROR;
      END;
   END IF;
   -- check if the object_version_number passed matches with the one
   -- in the database else raise error
   OPEN get_curr_party_rec(p_party_rec.INSTANCE_PARTY_ID);
   FETCH get_curr_party_rec INTO l_curr_party_rec;
   IF (l_curr_party_rec.object_version_number <> p_party_rec.OBJECT_VERSION_NUMBER) THEN
      FND_MESSAGE.Set_Name('CSI', 'CSI_API_OBJ_VER_MISMATCH');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   --
   IF get_curr_party_rec%NOTFOUND THEN
      FND_MESSAGE.Set_Name('CSI', 'CSI_API_RECORD_LOCKED');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE get_curr_party_rec;
   --
   IF p_party_rec.instance_id <> FND_API.G_MISS_NUM THEN
      IF p_party_rec.instance_id <> l_curr_party_rec.instance_id THEN
	 FND_MESSAGE.Set_Name('CSI', 'CSI_API_UPD_NOT_ALLOWED');
	 FND_MESSAGE.Set_Token('COLUMN', 'INSTANCE_ID');
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   --
   IF p_party_rec.active_start_date IS NULL THEN
      FND_MESSAGE.Set_Name('CSI', 'CSI_API_UPD_NOT_ALLOWED');
      FND_MESSAGE.Set_Token('COLUMN', 'ACTIVE_START_DATE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   --
   IF p_party_rec.active_start_date <> FND_API.G_MISS_DATE THEN
      IF p_party_rec.active_start_date <> l_curr_party_rec.active_start_date THEN
	 FND_MESSAGE.Set_Name('CSI', 'CSI_API_UPD_NOT_ALLOWED');
	 FND_MESSAGE.Set_Token('COLUMN', 'ACTIVE_START_DATE');
	 FND_MSG_PUB.ADD;
	RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   -- Increment the object_version_number before updating
   l_OBJECT_VERSION_NUMBER := l_curr_party_rec.OBJECT_VERSION_NUMBER + 1 ;
   -- Verify if the active_end_date is valid
   -- Don't allow expiry of owner parties
   IF p_party_rec.ACTIVE_END_DATE <> FND_API.G_MISS_DATE THEN
      IF l_curr_party_rec.relationship_type_code = 'OWNER'  THEN
	 FND_MESSAGE.Set_Name('CSI', 'CSI_API_EXP_NOT_ALLOWED');
	 FND_MESSAGE.Set_Token('COLUMN', 'OWNER PARTY');
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_EXC_ERROR;
      ELSE
	 -- Verify if the active_end_date is valid
	 IF (g_expire_party_flag <> 'Y') THEN
	    IF NOT(CSI_Instance_parties_vld_pvt.Is_EndDate_Valid
			    (l_curr_party_rec.ACTIVE_START_DATE,
			     p_party_rec.ACTIVE_END_DATE ,
			     p_party_rec.INSTANCE_ID,
			     p_party_rec.INSTANCE_PARTY_ID,
			     p_txn_rec.TRANSACTION_ID))  THEN
	       RAISE FND_API.G_EXC_ERROR;
	    END IF;
	 END IF;
      END IF;
   END IF;
   --
   IF p_party_rec.relationship_type_code <> FND_API.G_MISS_CHAR THEN
      IF ((p_party_rec.relationship_type_code <> l_curr_party_rec.relationship_type_code)
	      AND l_curr_party_rec.relationship_type_code = 'OWNER' ) THEN
	   FND_MESSAGE.Set_Name('CSI', 'CSI_API_UPD_NOT_ALLOWED');
	   FND_MESSAGE.Set_Token('COLUMN', 'OWNER PARTY');

	   FND_MSG_PUB.ADD;
	   RAISE FND_API.G_EXC_ERROR;
      ELSE


     IF (l_csi_debug_level > 0) THEN
            csi_gen_utility_pvt.put_line( 'Added line of code...');
      END IF;
        --bug 7015558 fix...Contact_flag is missing.
	IF p_party_rec.RELATIONSHIP_TYPE_CODE <> 'OWNER' THEN
	    select contact_flag into p_party_rec.contact_flag FROM csi_i_parties where instance_id=p_party_rec.instance_id and instance_party_id=p_party_rec.instance_party_id;
        END IF;
      IF (l_csi_debug_level > 0) THEN
            csi_gen_utility_pvt.put_line( 'Added line of code ends...');
            csi_gen_utility_pvt.put_line('Contact flag'|| p_party_rec.contact_flag);
            csi_gen_utility_pvt.put_line('Instance id'|| p_party_rec.instance_id);
            csi_gen_utility_pvt.put_line('Instance party id'|| p_party_rec.instance_party_id);
      END IF;

	 -- Verify the relationship_type_code is valid
	 IF p_party_rec.contact_flag = 'Y' THEN
	     IF NOT(CSI_Instance_parties_vld_pvt.Is_Pty_Rel_type_Valid
					     (p_party_rec.RELATIONSHIP_TYPE_CODE,
					      'C'    )) THEN
		 RAISE FND_API.G_EXC_ERROR;
	     END IF;
	 ELSE
	      -- Verify the relationship_type_code is valid
	      IF NOT(CSI_Instance_parties_vld_pvt.Is_Pty_Rel_type_Valid
					     (p_party_rec.RELATIONSHIP_TYPE_CODE,
					      'P'    )) THEN
		 RAISE FND_API.G_EXC_ERROR;
	      END IF;
	 END IF;
      END IF;
   END IF;

   -- Verify that there is only one Preferred Party for a
   -- given instance party relationship
   -- Bug 9286516
   IF p_party_rec.preferred_flag <> FND_API.G_MISS_CHAR THEN
           IF ( ((p_party_rec.preferred_flag IS NULL AND l_curr_party_rec.preferred_flag IS NOT NULL)
	 OR (p_party_rec.preferred_flag IS NOT NULL AND l_curr_party_rec.preferred_flag IS NULL)
              OR  (p_party_rec.preferred_flag <> l_curr_party_rec.preferred_flag))
	 AND (p_party_rec.preferred_flag = 'Y')) THEN
	   IF p_party_rec.CONTACT_FLAG <> 'Y' THEN
		IF (((p_party_rec.PARTY_SOURCE_TABLE <> FND_API.G_MISS_CHAR)
		   AND (p_party_rec.PARTY_SOURCE_TABLE NOT IN ('GROUP','TEAM')))
		  OR (l_curr_party_rec.PARTY_SOURCE_TABLE NOT IN ('GROUP','TEAM'))) THEN
		  FND_MESSAGE.SET_NAME('CSI','CSI_PREFERRED_PTY_TYPE');
		  FND_MESSAGE.SET_TOKEN('PARTY_TYPE',l_curr_party_rec.PARTY_SOURCE_TABLE);
		  FND_MESSAGE.SET_TOKEN('INSTANCE_ID',l_curr_party_rec.INSTANCE_ID);
		  FND_MSG_PUB.Add;
		  RAISE FND_API.G_EXC_ERROR;
	       END IF;
	   END IF;
	END IF;
   END IF;
   -- Verify that there is only one Primary Party for a
   -- given instance party relationship
   IF ((nvl(p_party_rec.primary_flag,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR)
      OR (nvl(p_party_rec.relationship_type_code,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR)) THEN
      IF (((p_party_rec.primary_flag IS NULL AND l_curr_party_rec.primary_flag IS NOT NULL)
	  OR (p_party_rec.primary_flag IS NOT NULL AND l_curr_party_rec.primary_flag IS NULL)
	  OR  (p_party_rec.primary_flag <> l_curr_party_rec.primary_flag)
	  AND (p_party_rec.primary_flag = 'Y'))
	  OR (p_party_rec.relationship_type_code <> l_curr_party_rec.relationship_type_code)) THEN
	 IF (((p_party_rec.CONTACT_FLAG <> FND_API.G_MISS_CHAR)
	       AND (p_party_rec.CONTACT_FLAG = 'Y'))
	       OR (l_curr_party_rec.CONTACT_FLAG = 'Y')) THEN
	       -- SK ADDED
	       -- following code 10 lines needs to be removed once
	       -- html code is fixed
	    IF p_party_rec.PARTY_SOURCE_TABLE IS NULL
	    THEN
	       p_party_rec.PARTY_SOURCE_TABLE:=fnd_api.g_miss_char;
	    END IF;
	    IF  p_party_rec.primary_flag IS NULL THEN
		p_party_rec.primary_flag:='N';
	    END IF;
	    --
	    IF  nvl(l_curr_party_rec.primary_flag,'N') = 'Y'
		AND p_party_rec.primary_flag = 'N'
	    THEN
	       NULL;
	    ELSIF ((nvl(l_curr_party_rec.primary_flag,'N') = 'Y') OR (p_party_rec.primary_flag = 'Y')) THEN
	       IF p_party_rec.ACTIVE_START_DATE IS NULL
		  OR p_party_rec.ACTIVE_START_DATE = fnd_api.g_miss_date THEN
		  p_party_rec.ACTIVE_START_DATE := l_curr_party_rec.ACTIVE_START_DATE;
	       END IF;
	       --
	       IF  p_party_rec.ACTIVE_END_DATE IS NULL
		   OR p_party_rec.ACTIVE_END_DATE = fnd_api.g_miss_date
	       THEN
		  p_party_rec.ACTIVE_END_DATE := l_curr_party_rec.ACTIVE_END_DATE;
	       END IF;
	       -- SK END ADDITION
	       IF CSI_Instance_parties_vld_pvt.Is_Primary_Contact_Pty
		       (l_curr_party_rec.INSTANCE_ID,
			l_curr_party_rec.CONTACT_IP_ID,
			p_party_rec.RELATIONSHIP_TYPE_CODE,
			p_party_rec.ACTIVE_START_DATE,
			p_party_rec.ACTIVE_END_DATE) THEN
		  RAISE FND_API.G_EXC_ERROR;
	       END IF;
	    END IF; --SK ADDED
	 ELSE
	    IF (((p_party_rec.PARTY_SOURCE_TABLE <> FND_API.G_MISS_CHAR)
		   AND (p_party_rec.PARTY_SOURCE_TABLE NOT IN ('GROUP','TEAM')))
		  OR (l_curr_party_rec.PARTY_SOURCE_TABLE NOT IN ('GROUP','TEAM'))) THEN
		   -- following code is commented by sk
		  /*FND_MESSAGE.SET_NAME('CSI','CSI_HAHA2');
		   --FND_MESSAGE.SET_NAME('CSI','CSI_PRIMARY_PTY_TYPE');
		   FND_MESSAGE.SET_TOKEN('PARTY_TYPE',l_curr_party_rec.PARTY_SOURCE_TABLE);
		   FND_MESSAGE.SET_TOKEN('INSTANCE_ID',l_curr_party_rec.INSTANCE_ID);
		   FND_MSG_PUB.Add;
		   RAISE FND_API.G_EXC_ERROR; */
		  NULL; --added by sk
	    ELSE
	       -- SK ADDED
	       IF  p_party_rec.primary_flag IS NULL
	       THEN
		   p_party_rec.primary_flag:='N';
	       END IF;
	       --
	       IF  nvl(l_curr_party_rec.primary_flag,'N') = 'Y'
		   AND p_party_rec.primary_flag = 'N'
	       THEN
		  NULL;
	       ELSIF ((nvl(l_curr_party_rec.primary_flag,'N') = 'Y') OR (p_party_rec.primary_flag = 'Y')) THEN
		  IF  p_party_rec.ACTIVE_START_DATE IS NULL
		     OR p_party_rec.ACTIVE_START_DATE = fnd_api.g_miss_date
		  THEN
		     p_party_rec.ACTIVE_START_DATE := l_curr_party_rec.ACTIVE_START_DATE;
		  END IF;
		  IF  p_party_rec.ACTIVE_END_DATE IS NULL
		     OR p_party_rec.ACTIVE_END_DATE = fnd_api.g_miss_date
		  THEN
		     p_party_rec.ACTIVE_END_DATE := l_curr_party_rec.ACTIVE_END_DATE;
		  END IF;
		  -- SK END ADDITION
		  IF CSI_Instance_parties_vld_pvt.Is_Primary_Pty
			       (l_curr_party_rec.INSTANCE_ID,
				p_party_rec.RELATIONSHIP_TYPE_CODE,
				p_party_rec.ACTIVE_START_DATE,
				p_party_rec.ACTIVE_END_DATE) THEN
		     RAISE FND_API.G_EXC_ERROR;
		  END IF;
	       END IF; --SK ADDED
	    END IF;
	 END IF;
      END IF;
   END IF;
   -- Call table handlers to insert into the csi_i_parties table
   -- Verify if the party_source_table exists in CSI_LOOKUPS
   IF (p_party_rec.PARTY_SOURCE_TABLE <> FND_API.G_MISS_CHAR) THEN
      IF NOT(CSI_Instance_parties_vld_pvt.Is_Pty_Source_tab_Valid(p_party_rec.PARTY_SOURCE_TABLE)) THEN
	 RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- Verify if the party_id is valid based on the value of party_source_table
      IF (p_party_rec.PARTY_ID <> FND_API.G_MISS_NUM) THEN
	 IF NOT(CSI_Instance_parties_vld_pvt.Is_Party_Valid
			 (p_party_rec.PARTY_SOURCE_TABLE ,
			  p_party_rec.PARTY_ID ,
			  p_party_rec.CONTACT_FLAG )) THEN
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;
      END IF;
   ELSE
      IF (p_party_rec.PARTY_ID <> FND_API.G_MISS_NUM) THEN
	 IF NOT(CSI_Instance_parties_vld_pvt.Is_Party_Valid
			   (l_curr_party_rec.PARTY_SOURCE_TABLE ,
			    p_party_rec.PARTY_ID ,
			    p_party_rec.CONTACT_FLAG )) THEN
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;
      END IF;
   END IF;
   -- Grab the internal party id from csi_installed paramters
   IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
      csi_gen_utility_pvt.populate_install_param_rec;
   END IF;
   --
   l_internal_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;
   --
   IF l_internal_party_id IS NULL THEN
      FND_MESSAGE.SET_NAME('CSI','CSI_API_UNINSTALLED_PARAMETER');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   -- Validate Tranfer Party rules in case of tranfer of instance
   IF ((p_party_rec.PARTY_ID <> FND_API.G_MISS_NUM)
       AND (p_party_rec.PARTY_ID IS NOT NULL)
       AND (p_party_rec.PARTY_ID <> l_curr_party_rec.PARTY_ID))
       --AND (p_party_rec.party_id <> l_internal_party_id)) -- commented for bug 3294748
   THEN
      -- End of code comment for bug 2600000
      -- End commentation by sguthiva for bug 2307804
      CSI_Instance_parties_vld_pvt.Transfer_Party_Rules
           ( p_api_version                 => p_api_version
            ,p_commit                      => p_commit
            ,p_init_msg_list               => p_init_msg_list
            ,p_validation_level            => p_validation_level
            ,p_party_rec                   => l_curr_party_rec
            ,p_stack_err_msg               => TRUE
            ,p_txn_rec                     => p_txn_rec
            ,x_return_status               => x_return_status
            ,x_msg_count                   => x_msg_count
            ,x_msg_data                    => x_msg_data       );

      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
                    x_msg_data := FND_MSG_PUB.GET(
                                                  l_msg_index,
                                                  FND_API.G_FALSE	);
                   csi_gen_utility_pvt.put_line( 'message data = '||x_msg_data);
                   l_msg_index := l_msg_index + 1;
                   l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   -- Validate alternate primary key
   IF  ((p_party_rec.instance_id IS NULL) OR  (p_party_rec.instance_id = FND_API.G_MISS_NUM)) THEN
      l_alt_pk_instance_id   := l_curr_party_rec.instance_id;
   ELSE
      l_alt_pk_instance_id   := p_party_rec.instance_id;
   END IF;
   --
   IF  ((p_party_rec.party_source_table IS NULL) OR  (p_party_rec.party_source_table = FND_API.G_MISS_CHAR)) THEN
      l_alt_pk_pty_source_tab   := l_curr_party_rec.party_source_table;
   ELSE
      l_alt_pk_pty_source_tab   := p_party_rec.party_source_table;
   END IF;
   --
   IF  ((p_party_rec.party_id IS NULL) OR  (p_party_rec.party_id = FND_API.G_MISS_NUM)) THEN
      l_alt_pk_party_id   := l_curr_party_rec.party_id;
   ELSE
      l_alt_pk_party_id   := p_party_rec.party_id;
   END IF;
   --
   IF  ((p_party_rec.relationship_type_code IS NULL) OR
      (p_party_rec.relationship_type_code = FND_API.G_MISS_CHAR)) THEN
      l_alt_pk_rel_type_code   := l_curr_party_rec.relationship_type_code ;
   ELSE
      l_alt_pk_rel_type_code   := p_party_rec.relationship_type_code ;
   END IF;
   --
   IF  ((p_party_rec.contact_flag IS NULL) OR  (p_party_rec.contact_flag = FND_API.G_MISS_CHAR)) THEN
      l_alt_pk_contact_flag   := l_curr_party_rec.contact_flag ;
   ELSE
      l_alt_pk_contact_flag   := p_party_rec.contact_flag ;
   END IF;
   -- Verify if the Party rel combination exists
   IF  ((l_alt_pk_instance_id   <> l_curr_party_rec.instance_id)
      OR
      (l_alt_pk_pty_source_tab   <> l_curr_party_rec.party_source_table )
      OR
      (l_alt_pk_party_id   <> l_curr_party_rec.party_id)
      OR
      (l_alt_pk_rel_type_code   <> l_curr_party_rec.relationship_type_code )
      OR
      (l_alt_pk_contact_flag   <> l_curr_party_rec.contact_flag ))
   THEN
      -- Verify if the Party rel combination exists
      -- Added the following code for bug 3694434
      -- party rel combination check is relaxed on for party/acct merge transaction.
      IF p_txn_rec.transaction_type_id=7
      THEN
         BEGIN
	    SELECT instance_party_id
            INTO l_ins_pty_found
            FROM csi_i_parties
	    WHERE instance_id            = l_alt_pk_instance_id
            AND party_source_table     = l_alt_pk_pty_source_tab
            AND party_id               = l_alt_pk_party_id
            AND relationship_type_code = l_alt_pk_rel_type_code
            AND contact_flag           = l_alt_pk_contact_flag
            AND NVL(contact_ip_id,fnd_api.g_miss_num) = NVL(p_party_rec.contact_ip_id,fnd_api.g_miss_num)
            AND ((active_end_date IS NULL) OR (active_end_date >= sysdate));
            -- If found then there exists a record in csi_i_parties, Hence
            -- I need to expire(if active) this record.
            BEGIN
               SELECT active_end_date
               INTO l_pty_end_date
               FROM csi_i_parties
               WHERE instance_party_id=p_party_rec.instance_party_id
               AND ((active_end_date IS NULL) OR (active_end_date > sysdate));
               -- Active record found so make it inactive.
               p_party_rec.active_end_date:=sysdate;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;
         EXCEPTION
            WHEN TOO_MANY_ROWS THEN
               csi_gen_utility_pvt.put_line('Too many rows exist in csi_i_parties with the same party rel combination.');
	       FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_PARTY_REL_COMB');
	       FND_MESSAGE.SET_TOKEN('PARTY_REL_COMB',to_char(l_alt_pk_instance_id) ||','||l_alt_pk_pty_source_tab||','||to_char(l_alt_pk_party_id)||','||l_alt_pk_rel_type_code||','||to_char(p_party_rec.contact_ip_id));
	       FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
            WHEN OTHERS THEN
               NULL;
         END;
      ELSE
         IF (CSI_Instance_parties_vld_pvt.Is_Party_Rel_Comb_Exists
                  (l_alt_pk_instance_id              ,
                   l_alt_pk_pty_source_tab           ,
                   l_alt_pk_party_id                 ,
                   l_alt_pk_rel_type_code            ,
                   l_alt_pk_contact_flag             ,
                   p_party_rec.contact_ip_id         ,
                   TRUE           )) THEN
               RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;
   END IF;
   --
   IF p_party_rec.relationship_type_code <> FND_API.G_MISS_CHAR THEN
      IF (p_party_rec.relationship_type_code = 'OWNER' ) THEN
         update csi_item_instances
         set owner_party_source_table = l_alt_pk_pty_source_tab, --p_party_rec.party_source_table,--bug 2769176
         owner_party_id  = l_alt_pk_party_id, --p_party_rec.party_id, --bug 2769176
         last_update_date = sysdate,
         last_updated_by = fnd_global.user_id
         where  instance_id     = l_curr_party_rec.instance_id;
      END IF;
   END IF;
   -- A contact marked as 'Primary' can also be marked as 'Preferred' or
   -- 'Non-Preferred' at the same time.
   IF p_party_rec.preferred_flag IS NULL THEN
      p_party_rec.preferred_flag:='N';
   END IF;
   IF (p_party_rec.preferred_flag='E' OR
      p_party_rec.preferred_flag='e' )
   THEN
      p_party_rec.preferred_flag:='E';
   END IF;
   -- A contact marked as Primary cannot be marked as 'Excluded'
   IF (p_party_rec.primary_flag='Y' AND p_party_rec.preferred_flag='E') OR
      (p_party_rec.primary_flag=fnd_api.g_miss_char AND nvl(l_curr_party_rec.primary_flag,'N') = 'Y' AND
      p_party_rec.preferred_flag='E') OR
      (p_party_rec.preferred_flag=fnd_api.g_miss_char AND nvl(l_curr_party_rec.preferred_flag,'N') = 'E' AND
      p_party_rec.primary_flag='Y')
   THEN
      fnd_message.set_name('CSI','CSI_PRIMARY_PTY_EXC');
      fnd_msg_pub.Add;
      RAISE fnd_api.g_exc_error;
   END IF;
   -- Possible values for preferred flag are
   -- 'N','Y' and 'E'.
   IF p_party_rec.preferred_flag='Y' OR
      p_party_rec.preferred_flag='N' OR
      p_party_rec.preferred_flag='E' OR
      p_party_rec.preferred_flag=fnd_api.g_miss_char
   THEN
      NULL;
   ELSE
      fnd_message.set_name('CSI','CSI_PREFERRED_VALUES');
      fnd_message.set_token('PREFERRED_FLAG',p_party_rec.preferred_flag);
      fnd_msg_pub.Add;
      RAISE fnd_api.g_exc_error;
   END IF;
   -- Call table handlers to update the  table
   CSI_I_PARTIES_PKG.Update_Row
        (
          p_INSTANCE_PARTY_ID      =>  p_party_rec.instance_party_id,
          p_INSTANCE_ID            =>  p_party_rec.instance_id,
          p_PARTY_SOURCE_TABLE     =>  p_party_rec.PARTY_SOURCE_TABLE,
          p_PARTY_ID               =>  p_party_rec.PARTY_ID,
          p_RELATIONSHIP_TYPE_CODE =>  p_party_rec.RELATIONSHIP_TYPE_CODE,
          p_CONTACT_FLAG           =>  p_party_rec.CONTACT_FLAG,
          p_CONTACT_IP_ID          =>  p_party_rec.CONTACT_IP_ID,
          p_ACTIVE_START_DATE      =>  p_party_rec.ACTIVE_START_DATE,
          p_ACTIVE_END_DATE        =>  p_party_rec.ACTIVE_END_DATE,
          p_CONTEXT                =>  p_party_rec.CONTEXT,
          p_ATTRIBUTE1             =>  p_party_rec.ATTRIBUTE1,
          p_ATTRIBUTE2             =>  p_party_rec.ATTRIBUTE2,
          p_ATTRIBUTE3             =>  p_party_rec.ATTRIBUTE3,
          p_ATTRIBUTE4             =>  p_party_rec.ATTRIBUTE4,
          p_ATTRIBUTE5             =>  p_party_rec.ATTRIBUTE5,
          p_ATTRIBUTE6             =>  p_party_rec.ATTRIBUTE6,
          p_ATTRIBUTE7             =>  p_party_rec.ATTRIBUTE7,
          p_ATTRIBUTE8             =>  p_party_rec.ATTRIBUTE8,
          p_ATTRIBUTE9             =>  p_party_rec.ATTRIBUTE9,
          p_ATTRIBUTE10            =>  p_party_rec.ATTRIBUTE10,
          p_ATTRIBUTE11            =>  p_party_rec.ATTRIBUTE11,
          p_ATTRIBUTE12            =>  p_party_rec.ATTRIBUTE12,
          p_ATTRIBUTE13            =>  p_party_rec.ATTRIBUTE13,
          p_ATTRIBUTE14            =>  p_party_rec.ATTRIBUTE14,
          p_ATTRIBUTE15            =>  p_party_rec.ATTRIBUTE15,
          p_CREATED_BY             =>  FND_API.G_MISS_NUM, -- FND_GLOBAL.USER_ID,
          p_CREATION_DATE          =>  FND_API.G_MISS_DATE, -- sysdate,
          p_LAST_UPDATED_BY        =>  FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE       =>  sysdate,
          p_LAST_UPDATE_LOGIN      =>  FND_GLOBAL.LOGIN_ID,
          p_OBJECT_VERSION_NUMBER  =>  l_OBJECT_VERSION_NUMBER,
          p_PRIMARY_FLAG           =>  p_party_rec.PRIMARY_FLAG,
          p_PREFERRED_FLAG           =>  p_party_rec.PREFERRED_FLAG);

         -- Call create_transaction to create txn log
         CSI_TRANSACTIONS_PVT.Create_transaction
          (
             p_api_version            => p_api_version
            ,p_commit                 => p_commit
            ,p_init_msg_list          => p_init_msg_list
            ,p_validation_level       => p_validation_level
            ,p_Success_If_Exists_Flag => 'Y'
            ,P_transaction_rec        => p_txn_rec
            ,x_return_status          => x_return_status
            ,x_msg_count              => x_msg_count
            ,x_msg_data               => x_msg_data         );

         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	      l_msg_index := 1;
              l_msg_count := x_msg_count;
    	      WHILE l_msg_count > 0 LOOP
     		       x_msg_data := FND_MSG_PUB.GET(
    	       			                 l_msg_index,
	     	  		                     FND_API.G_FALSE	);
	               csi_gen_utility_pvt.put_line( 'message data = '||x_msg_data);
	    	       l_msg_index := l_msg_index + 1;
		           l_msg_count := l_msg_count - 1;
	      END LOOP;
              RAISE FND_API.G_EXC_ERROR;
         END IF;

       -- Get the full_dump_frequency from csi_install_parameter
       IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
          csi_gen_utility_pvt.populate_install_param_rec;
       END IF;
       --
       l_full_dump_frequency := csi_datastructures_pub.g_install_param_rec.history_full_dump_frequency;
       --
       IF l_full_dump_frequency IS NULL THEN
          FND_MESSAGE.SET_NAME('CSI','CSI_API_GET_FULL_DUMP_FAILED');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Generate a unique instance_party_history_id from the sequence
       l_inst_party_his_id := CSI_Instance_parties_vld_pvt.gen_inst_party_hist_id;


       select mod(l_object_version_number,l_full_dump_frequency)
       into   l_mod_value
       from   dual;

       -- assign the party rec
       l_temp_party_rec := p_party_rec;
       -- Start of Changes for Bug#2547034 on 09/20/02 - rtalluri
       BEGIN
        SELECT  instance_party_history_id
        INTO    l_party_hist_id
        FROM    csi_i_parties_h h
        WHERE   h.transaction_id = p_txn_rec.transaction_id
        AND     h.instance_party_id = p_party_rec.instance_party_id;

        OPEN   pty_hist_csr(l_party_hist_id);
        FETCH  pty_hist_csr INTO l_pty_hist_csr ;
        CLOSE  pty_hist_csr;

        IF l_pty_hist_csr.full_dump_flag = 'Y'
        THEN
         CSI_I_PARTIES_H_PKG.update_Row
        (
         p_INSTANCE_PARTY_HISTORY_ID    =>  l_party_hist_id                    ,
         p_INSTANCE_PARTY_ID             => fnd_api.g_miss_num                 ,
         p_TRANSACTION_ID                => fnd_api.g_miss_num                 ,
         p_OLD_PARTY_SOURCE_TABLE        => fnd_api.g_miss_char                ,
         p_NEW_PARTY_SOURCE_TABLE        => l_temp_party_rec.PARTY_SOURCE_TABLE,
         p_OLD_PARTY_ID                  => fnd_api.g_miss_num                 ,
         p_NEW_PARTY_ID                  => l_temp_party_rec.PARTY_ID          ,
         p_OLD_RELATIONSHIP_TYPE_CODE    => fnd_api.g_miss_char                ,
         p_NEW_RELATIONSHIP_TYPE_CODE    => l_temp_party_rec.RELATIONSHIP_TYPE_CODE,
         p_OLD_CONTACT_FLAG              => fnd_api.g_miss_char                ,
         p_NEW_CONTACT_FLAG              => l_temp_party_rec.CONTACT_FLAG      ,
         p_OLD_CONTACT_IP_ID             => fnd_api.g_miss_num                 ,
         p_NEW_CONTACT_IP_ID             => l_temp_party_rec.CONTACT_IP_ID     ,
         p_OLD_ACTIVE_START_DATE         => l_curr_party_rec.ACTIVE_START_DATE ,
         p_NEW_ACTIVE_START_DATE         => l_temp_party_rec.ACTIVE_START_DATE ,
         p_OLD_ACTIVE_END_DATE           => l_curr_party_rec.ACTIVE_END_DATE   ,
         p_NEW_ACTIVE_END_DATE           => l_temp_party_rec.ACTIVE_END_DATE   ,
         p_OLD_CONTEXT                   => fnd_api.g_miss_char                ,
         p_NEW_CONTEXT                   => l_temp_party_rec.context           ,
         p_OLD_ATTRIBUTE1                => fnd_api.g_miss_char                ,
         p_NEW_ATTRIBUTE1                => l_temp_party_rec.ATTRIBUTE1        ,
         p_OLD_ATTRIBUTE2                => fnd_api.g_miss_char                ,
         p_NEW_ATTRIBUTE2                => l_temp_party_rec.ATTRIBUTE2        ,
         p_OLD_ATTRIBUTE3                => fnd_api.g_miss_char                ,
         p_NEW_ATTRIBUTE3                => l_temp_party_rec.ATTRIBUTE3        ,
         p_OLD_ATTRIBUTE4                => fnd_api.g_miss_char                ,
         p_NEW_ATTRIBUTE4                => l_temp_party_rec.ATTRIBUTE4        ,
         p_OLD_ATTRIBUTE5                => fnd_api.g_miss_char                ,
         p_NEW_ATTRIBUTE5                => l_temp_party_rec.ATTRIBUTE5        ,
         p_OLD_ATTRIBUTE6                => fnd_api.g_miss_char                ,
         p_NEW_ATTRIBUTE6                => l_temp_party_rec.ATTRIBUTE6        ,
         p_OLD_ATTRIBUTE7                => fnd_api.g_miss_char                ,
         p_NEW_ATTRIBUTE7                => l_temp_party_rec.ATTRIBUTE7        ,
         p_OLD_ATTRIBUTE8                => fnd_api.g_miss_char                ,
         p_NEW_ATTRIBUTE8                => l_temp_party_rec.ATTRIBUTE8        ,
         p_OLD_ATTRIBUTE9                => fnd_api.g_miss_char                ,
         p_NEW_ATTRIBUTE9                => l_temp_party_rec.ATTRIBUTE9        ,
         p_OLD_ATTRIBUTE10               => fnd_api.g_miss_char                ,
         p_NEW_ATTRIBUTE10               => l_temp_party_rec.ATTRIBUTE10       ,
         p_OLD_ATTRIBUTE11               => fnd_api.g_miss_char                ,
         p_NEW_ATTRIBUTE11               => l_temp_party_rec.ATTRIBUTE11       ,
         p_OLD_ATTRIBUTE12               => fnd_api.g_miss_char                ,
         p_NEW_ATTRIBUTE12               => l_temp_party_rec.ATTRIBUTE12       ,
         p_OLD_ATTRIBUTE13               => fnd_api.g_miss_char                ,
         p_NEW_ATTRIBUTE13               => l_temp_party_rec.ATTRIBUTE13       ,
         p_OLD_ATTRIBUTE14               => fnd_api.g_miss_char                ,
         p_NEW_ATTRIBUTE14               => l_temp_party_rec.ATTRIBUTE14       ,
         p_OLD_ATTRIBUTE15               => fnd_api.g_miss_char                ,
         p_NEW_ATTRIBUTE15               => l_temp_party_rec.ATTRIBUTE15       ,
         p_FULL_DUMP_FLAG                => fnd_api.g_miss_char                ,
         p_CREATED_BY                    => FND_API.G_MISS_NUM                 ,
         p_CREATION_DATE                 => FND_API.G_MISS_DATE                ,
         p_LAST_UPDATED_BY               => FND_GLOBAL.USER_ID                 ,
         p_LAST_UPDATE_DATE              => SYSDATE                            ,
         p_LAST_UPDATE_LOGIN             => FND_GLOBAL.LOGIN_ID                ,
         p_OBJECT_VERSION_NUMBER         => fnd_api.g_miss_num                 ,
         p_OLD_PRIMARY_FLAG              => fnd_api.g_miss_char                ,
         p_NEW_PRIMARY_FLAG              => l_temp_party_rec.PRIMARY_FLAG      ,
         p_OLD_PREFERRED_FLAG            => fnd_api.g_miss_char                ,
         p_NEW_PREFERRED_FLAG            => l_temp_party_rec.PREFERRED_FLAG      );

        ELSE

             IF    ( l_pty_hist_csr.old_party_source_table IS NULL
                AND  l_pty_hist_csr.new_party_source_table IS NULL ) THEN
                     IF  ( l_temp_party_rec.party_source_table = l_curr_party_rec.party_source_table )
                      OR ( l_temp_party_rec.party_source_table = fnd_api.g_miss_char ) THEN
                           l_pty_hist_csr.old_party_source_table := NULL;
                           l_pty_hist_csr.new_party_source_table := NULL;
                     ELSE
                           l_pty_hist_csr.old_party_source_table := fnd_api.g_miss_char;
                           l_pty_hist_csr.new_party_source_table := l_temp_party_rec.party_source_table;
                     END IF;
             ELSE
                     l_pty_hist_csr.old_party_source_table := fnd_api.g_miss_char;
                     l_pty_hist_csr.new_party_source_table := l_temp_party_rec.party_source_table;
             END IF;
             --
             IF    ( l_pty_hist_csr.old_party_id IS NULL
                AND  l_pty_hist_csr.new_party_id IS NULL ) THEN
                     IF  ( l_temp_party_rec.party_id = l_curr_party_rec.party_id )
                      OR ( l_temp_party_rec.party_id = fnd_api.g_miss_num ) THEN
                           l_pty_hist_csr.old_party_id := NULL;
                           l_pty_hist_csr.new_party_id := NULL;
                     ELSE
                           l_pty_hist_csr.old_party_id := fnd_api.g_miss_num;
                           l_pty_hist_csr.new_party_id := l_temp_party_rec.party_id;
                     END IF;
             ELSE
                     l_pty_hist_csr.old_party_id := fnd_api.g_miss_num;
                     l_pty_hist_csr.new_party_id := l_temp_party_rec.party_id;
             END IF;
             --
             IF    ( l_pty_hist_csr.old_relationship_type_code IS NULL
                AND  l_pty_hist_csr.new_relationship_type_code IS NULL ) THEN
                     IF  ( l_temp_party_rec.relationship_type_code = l_curr_party_rec.relationship_type_code )
                      OR ( l_temp_party_rec.relationship_type_code = fnd_api.g_miss_char ) THEN
                           l_pty_hist_csr.old_relationship_type_code := NULL;
                           l_pty_hist_csr.new_relationship_type_code := NULL;
                     ELSE
                           l_pty_hist_csr.old_relationship_type_code := fnd_api.g_miss_char;
                           l_pty_hist_csr.new_relationship_type_code := l_temp_party_rec.relationship_type_code;
                     END IF;
             ELSE
                     l_pty_hist_csr.old_relationship_type_code := fnd_api.g_miss_char;
                     l_pty_hist_csr.new_relationship_type_code := l_temp_party_rec.relationship_type_code;
             END IF;
             --
             IF    ( l_pty_hist_csr.old_contact_flag IS NULL
                AND  l_pty_hist_csr.new_contact_flag IS NULL ) THEN
                     IF  ( l_temp_party_rec.contact_flag = l_curr_party_rec.contact_flag )
                      OR ( l_temp_party_rec.contact_flag = fnd_api.g_miss_char ) THEN
                           l_pty_hist_csr.old_contact_flag := NULL;
                           l_pty_hist_csr.new_contact_flag := NULL;
                     ELSE
                           l_pty_hist_csr.old_contact_flag := fnd_api.g_miss_char;
                           l_pty_hist_csr.new_contact_flag := l_temp_party_rec.contact_flag;
                     END IF;
             ELSE
                     l_pty_hist_csr.old_contact_flag := fnd_api.g_miss_char;
                     l_pty_hist_csr.new_contact_flag := l_temp_party_rec.contact_flag;
             END IF;
             --
             IF    ( l_pty_hist_csr.old_contact_ip_id IS NULL
                AND  l_pty_hist_csr.new_contact_ip_id IS NULL ) THEN
                     IF  ( l_temp_party_rec.contact_ip_id = l_curr_party_rec.contact_ip_id )
                      OR ( l_temp_party_rec.contact_ip_id = fnd_api.g_miss_num ) THEN
                           l_pty_hist_csr.old_contact_ip_id := NULL;
                           l_pty_hist_csr.new_contact_ip_id := NULL;
                     ELSE
                           l_pty_hist_csr.old_contact_ip_id := fnd_api.g_miss_num;
                           l_pty_hist_csr.new_contact_ip_id := l_temp_party_rec.contact_ip_id;
                     END IF;
             ELSE
                     l_pty_hist_csr.old_contact_ip_id := fnd_api.g_miss_num;
                     l_pty_hist_csr.new_contact_ip_id := l_temp_party_rec.contact_ip_id;
             END IF;
             --
             IF    ( l_pty_hist_csr.old_active_start_date IS NULL
                AND  l_pty_hist_csr.new_active_start_date IS NULL ) THEN
                     IF  ( l_temp_party_rec.active_start_date = l_curr_party_rec.active_start_date )
                      OR ( l_temp_party_rec.active_start_date = fnd_api.g_miss_date ) THEN
                           l_pty_hist_csr.old_active_start_date := NULL;
                           l_pty_hist_csr.new_active_start_date := NULL;
                     ELSE
                           l_pty_hist_csr.old_active_start_date := fnd_api.g_miss_date;
                           l_pty_hist_csr.new_active_start_date := l_temp_party_rec.active_start_date;
                     END IF;
             ELSE
                     l_pty_hist_csr.old_active_start_date := fnd_api.g_miss_date;
                     l_pty_hist_csr.new_active_start_date := l_temp_party_rec.active_start_date;
             END IF;
             --
             IF    ( l_pty_hist_csr.old_active_end_date IS NULL
                AND  l_pty_hist_csr.new_active_end_date IS NULL ) THEN
                     IF  ( l_temp_party_rec.active_end_date = l_curr_party_rec.active_end_date )
                      OR ( l_temp_party_rec.active_end_date = fnd_api.g_miss_date ) THEN
                           l_pty_hist_csr.old_active_end_date := NULL;
                           l_pty_hist_csr.new_active_end_date := NULL;
                     ELSE
                           l_pty_hist_csr.old_active_end_date := fnd_api.g_miss_date;
                           l_pty_hist_csr.new_active_end_date := l_temp_party_rec.active_end_date;
                     END IF;
             ELSE
                     l_pty_hist_csr.old_active_end_date := fnd_api.g_miss_date;
                     l_pty_hist_csr.new_active_end_date := l_temp_party_rec.active_end_date;
             END IF;
             --
             IF    ( l_pty_hist_csr.old_context IS NULL
                AND  l_pty_hist_csr.new_context IS NULL ) THEN
                     IF  ( l_temp_party_rec.context = l_curr_party_rec.context )
                      OR ( l_temp_party_rec.context = fnd_api.g_miss_char ) THEN
                           l_pty_hist_csr.old_context := NULL;
                           l_pty_hist_csr.new_context := NULL;
                     ELSE
                           l_pty_hist_csr.old_context := fnd_api.g_miss_char;
                           l_pty_hist_csr.new_context := l_temp_party_rec.context;
                     END IF;
             ELSE
                     l_pty_hist_csr.old_context := fnd_api.g_miss_char;
                     l_pty_hist_csr.new_context := l_temp_party_rec.context;
             END IF;
             --
             IF    ( l_pty_hist_csr.old_attribute1 IS NULL
                AND  l_pty_hist_csr.new_attribute1 IS NULL ) THEN
                     IF  ( l_temp_party_rec.attribute1 = l_curr_party_rec.attribute1 )
                      OR ( l_temp_party_rec.attribute1 = fnd_api.g_miss_char ) THEN
                           l_pty_hist_csr.old_attribute1 := NULL;
                           l_pty_hist_csr.new_attribute1 := NULL;
                     ELSE
                           l_pty_hist_csr.old_attribute1 := fnd_api.g_miss_char;
                           l_pty_hist_csr.new_attribute1 := l_temp_party_rec.attribute1;
                     END IF;
             ELSE
                     l_pty_hist_csr.old_attribute1 := fnd_api.g_miss_char;
                     l_pty_hist_csr.new_attribute1 := l_temp_party_rec.attribute1;
             END IF;
             --
             IF    ( l_pty_hist_csr.old_attribute2 IS NULL
                AND  l_pty_hist_csr.new_attribute2 IS NULL ) THEN
                     IF  ( l_temp_party_rec.attribute2 = l_curr_party_rec.attribute2 )
                      OR ( l_temp_party_rec.attribute2 = fnd_api.g_miss_char ) THEN
                           l_pty_hist_csr.old_attribute2 := NULL;
                           l_pty_hist_csr.new_attribute2 := NULL;
                     ELSE
                           l_pty_hist_csr.old_attribute2 := fnd_api.g_miss_char;
                           l_pty_hist_csr.new_attribute2 := l_temp_party_rec.attribute2;
                     END IF;
             ELSE
                     l_pty_hist_csr.old_attribute2 := fnd_api.g_miss_char;
                     l_pty_hist_csr.new_attribute2 := l_temp_party_rec.attribute2;
             END IF;
             --
             IF    ( l_pty_hist_csr.old_attribute3 IS NULL
                AND  l_pty_hist_csr.new_attribute3 IS NULL ) THEN
                     IF  ( l_temp_party_rec.attribute3 = l_curr_party_rec.attribute3 )
                      OR ( l_temp_party_rec.attribute3 = fnd_api.g_miss_char ) THEN
                           l_pty_hist_csr.old_attribute3 := NULL;
                           l_pty_hist_csr.new_attribute3 := NULL;
                     ELSE
                           l_pty_hist_csr.old_attribute3 := fnd_api.g_miss_char;
                           l_pty_hist_csr.new_attribute3 := l_temp_party_rec.attribute3;
                     END IF;
             ELSE
                     l_pty_hist_csr.old_attribute3 := fnd_api.g_miss_char;
                     l_pty_hist_csr.new_attribute3 := l_temp_party_rec.attribute3;
             END IF;
             --
             IF    ( l_pty_hist_csr.old_attribute4 IS NULL
                AND  l_pty_hist_csr.new_attribute4 IS NULL ) THEN
                     IF  ( l_temp_party_rec.attribute4 = l_curr_party_rec.attribute4 )
                      OR ( l_temp_party_rec.attribute4 = fnd_api.g_miss_char ) THEN
                           l_pty_hist_csr.old_attribute4 := NULL;
                           l_pty_hist_csr.new_attribute4 := NULL;
                     ELSE
                           l_pty_hist_csr.old_attribute4 := fnd_api.g_miss_char;
                           l_pty_hist_csr.new_attribute4 := l_temp_party_rec.attribute4;
                     END IF;
             ELSE
                     l_pty_hist_csr.old_attribute4 := fnd_api.g_miss_char;
                     l_pty_hist_csr.new_attribute4 := l_temp_party_rec.attribute4;
             END IF;
             --
             IF    ( l_pty_hist_csr.old_attribute5 IS NULL
                AND  l_pty_hist_csr.new_attribute5 IS NULL ) THEN
                     IF  ( l_temp_party_rec.attribute5 = l_curr_party_rec.attribute5 )
                      OR ( l_temp_party_rec.attribute5 = fnd_api.g_miss_char ) THEN
                           l_pty_hist_csr.old_attribute5 := NULL;
                           l_pty_hist_csr.new_attribute5 := NULL;
                     ELSE
                           l_pty_hist_csr.old_attribute5 := fnd_api.g_miss_char;
                           l_pty_hist_csr.new_attribute5 := l_temp_party_rec.attribute5;
                     END IF;
             ELSE
                     l_pty_hist_csr.old_attribute5 := fnd_api.g_miss_char;
                     l_pty_hist_csr.new_attribute5 := l_temp_party_rec.attribute5;
             END IF;
             --
             IF    ( l_pty_hist_csr.old_attribute6 IS NULL
                AND  l_pty_hist_csr.new_attribute6 IS NULL ) THEN
                     IF  ( l_temp_party_rec.attribute6 = l_curr_party_rec.attribute6 )
                      OR ( l_temp_party_rec.attribute6 = fnd_api.g_miss_char ) THEN
                           l_pty_hist_csr.old_attribute6 := NULL;
                           l_pty_hist_csr.new_attribute6 := NULL;
                     ELSE
                           l_pty_hist_csr.old_attribute6 := fnd_api.g_miss_char;
                           l_pty_hist_csr.new_attribute6 := l_temp_party_rec.attribute6;
                     END IF;
             ELSE
                     l_pty_hist_csr.old_attribute6 := fnd_api.g_miss_char;
                     l_pty_hist_csr.new_attribute6 := l_temp_party_rec.attribute6;
             END IF;
             --
             IF    ( l_pty_hist_csr.old_attribute7 IS NULL
                AND  l_pty_hist_csr.new_attribute7 IS NULL ) THEN
                     IF  ( l_temp_party_rec.attribute7 = l_curr_party_rec.attribute7 )
                      OR ( l_temp_party_rec.attribute7 = fnd_api.g_miss_char ) THEN
                           l_pty_hist_csr.old_attribute7 := NULL;
                           l_pty_hist_csr.new_attribute7 := NULL;
                     ELSE
                           l_pty_hist_csr.old_attribute7 := fnd_api.g_miss_char;
                           l_pty_hist_csr.new_attribute7 := l_temp_party_rec.attribute7;
                     END IF;
             ELSE
                     l_pty_hist_csr.old_attribute7 := fnd_api.g_miss_char;
                     l_pty_hist_csr.new_attribute7 := l_temp_party_rec.attribute7;
             END IF;
             --
             IF    ( l_pty_hist_csr.old_attribute8 IS NULL
                AND  l_pty_hist_csr.new_attribute8 IS NULL ) THEN
                     IF  ( l_temp_party_rec.attribute8 = l_curr_party_rec.attribute8 )
                      OR ( l_temp_party_rec.attribute8 = fnd_api.g_miss_char ) THEN
                           l_pty_hist_csr.old_attribute8 := NULL;
                           l_pty_hist_csr.new_attribute8 := NULL;
                     ELSE
                           l_pty_hist_csr.old_attribute8 := fnd_api.g_miss_char;
                           l_pty_hist_csr.new_attribute8 := l_temp_party_rec.attribute8;
                     END IF;
             ELSE
                     l_pty_hist_csr.old_attribute8 := fnd_api.g_miss_char;
                     l_pty_hist_csr.new_attribute8 := l_temp_party_rec.attribute8;
             END IF;
             --
             IF    ( l_pty_hist_csr.old_attribute9 IS NULL
                AND  l_pty_hist_csr.new_attribute9 IS NULL ) THEN
                     IF  ( l_temp_party_rec.attribute9 = l_curr_party_rec.attribute9 )
                      OR ( l_temp_party_rec.attribute9 = fnd_api.g_miss_char ) THEN
                           l_pty_hist_csr.old_attribute9 := NULL;
                           l_pty_hist_csr.new_attribute9 := NULL;
                     ELSE
                           l_pty_hist_csr.old_attribute9 := fnd_api.g_miss_char;
                           l_pty_hist_csr.new_attribute9 := l_temp_party_rec.attribute9;
                     END IF;
             ELSE
                     l_pty_hist_csr.old_attribute9 := fnd_api.g_miss_char;
                     l_pty_hist_csr.new_attribute9 := l_temp_party_rec.attribute9;
             END IF;
             --
             IF    ( l_pty_hist_csr.old_attribute10 IS NULL
                AND  l_pty_hist_csr.new_attribute10 IS NULL ) THEN
                     IF  ( l_temp_party_rec.attribute10 = l_curr_party_rec.attribute10 )
                      OR ( l_temp_party_rec.attribute10 = fnd_api.g_miss_char ) THEN
                           l_pty_hist_csr.old_attribute10 := NULL;
                           l_pty_hist_csr.new_attribute10 := NULL;
                     ELSE
                           l_pty_hist_csr.old_attribute10 := fnd_api.g_miss_char;
                           l_pty_hist_csr.new_attribute10 := l_temp_party_rec.attribute10;
                     END IF;
             ELSE
                     l_pty_hist_csr.old_attribute10 := fnd_api.g_miss_char;
                     l_pty_hist_csr.new_attribute10 := l_temp_party_rec.attribute10;
             END IF;
             --
             IF    ( l_pty_hist_csr.old_attribute11 IS NULL
                AND  l_pty_hist_csr.new_attribute11 IS NULL ) THEN
                     IF  ( l_temp_party_rec.attribute11 = l_curr_party_rec.attribute11 )
                      OR ( l_temp_party_rec.attribute11 = fnd_api.g_miss_char ) THEN
                           l_pty_hist_csr.old_attribute11 := NULL;
                           l_pty_hist_csr.new_attribute11 := NULL;
                     ELSE
                           l_pty_hist_csr.old_attribute11 := fnd_api.g_miss_char;
                           l_pty_hist_csr.new_attribute11 := l_temp_party_rec.attribute11;
                     END IF;
             ELSE
                     l_pty_hist_csr.old_attribute11 := fnd_api.g_miss_char;
                     l_pty_hist_csr.new_attribute11 := l_temp_party_rec.attribute11;
             END IF;
             --
             IF    ( l_pty_hist_csr.old_attribute12 IS NULL
                AND  l_pty_hist_csr.new_attribute12 IS NULL ) THEN
                     IF  ( l_temp_party_rec.attribute12 = l_curr_party_rec.attribute12 )
                      OR ( l_temp_party_rec.attribute12 = fnd_api.g_miss_char ) THEN
                           l_pty_hist_csr.old_attribute12 := NULL;
                           l_pty_hist_csr.new_attribute12 := NULL;
                     ELSE
                           l_pty_hist_csr.old_attribute12 := fnd_api.g_miss_char;
                           l_pty_hist_csr.new_attribute12 := l_temp_party_rec.attribute12;
                     END IF;
             ELSE
                     l_pty_hist_csr.old_attribute12 := fnd_api.g_miss_char;
                     l_pty_hist_csr.new_attribute12 := l_temp_party_rec.attribute12;
             END IF;
             --
             IF    ( l_pty_hist_csr.old_attribute13 IS NULL
                AND  l_pty_hist_csr.new_attribute13 IS NULL ) THEN
                     IF  ( l_temp_party_rec.attribute13 = l_curr_party_rec.attribute13 )
                      OR ( l_temp_party_rec.attribute13 = fnd_api.g_miss_char ) THEN
                           l_pty_hist_csr.old_attribute13 := NULL;
                           l_pty_hist_csr.new_attribute13 := NULL;
                     ELSE
                           l_pty_hist_csr.old_attribute13 := fnd_api.g_miss_char;
                           l_pty_hist_csr.new_attribute13 := l_temp_party_rec.attribute13;
                     END IF;
             ELSE
                     l_pty_hist_csr.old_attribute13 := fnd_api.g_miss_char;
                     l_pty_hist_csr.new_attribute13 := l_temp_party_rec.attribute13;
             END IF;
             --
             IF    ( l_pty_hist_csr.old_attribute14 IS NULL
                AND  l_pty_hist_csr.new_attribute14 IS NULL ) THEN
                     IF  ( l_temp_party_rec.attribute14 = l_curr_party_rec.attribute14 )
                      OR ( l_temp_party_rec.attribute14 = fnd_api.g_miss_char ) THEN
                           l_pty_hist_csr.old_attribute14 := NULL;
                           l_pty_hist_csr.new_attribute14 := NULL;
                     ELSE
                           l_pty_hist_csr.old_attribute14 := fnd_api.g_miss_char;
                           l_pty_hist_csr.new_attribute14 := l_temp_party_rec.attribute14;
                     END IF;
             ELSE
                     l_pty_hist_csr.old_attribute14 := fnd_api.g_miss_char;
                     l_pty_hist_csr.new_attribute14 := l_temp_party_rec.attribute14;
             END IF;
             --
             IF    ( l_pty_hist_csr.old_attribute15 IS NULL
                AND  l_pty_hist_csr.new_attribute15 IS NULL ) THEN
                     IF  ( l_temp_party_rec.attribute15 = l_curr_party_rec.attribute15 )
                      OR ( l_temp_party_rec.attribute15 = fnd_api.g_miss_char ) THEN
                           l_pty_hist_csr.old_attribute15 := NULL;
                           l_pty_hist_csr.new_attribute15 := NULL;
                     ELSE
                           l_pty_hist_csr.old_attribute15 := fnd_api.g_miss_char;
                           l_pty_hist_csr.new_attribute15 := l_temp_party_rec.attribute15;
                     END IF;
             ELSE
                     l_pty_hist_csr.old_attribute15 := fnd_api.g_miss_char;
                     l_pty_hist_csr.new_attribute15 := l_temp_party_rec.attribute15;
             END IF;
             --
             IF    ( l_pty_hist_csr.old_primary_flag IS NULL
                AND  l_pty_hist_csr.new_primary_flag IS NULL ) THEN
                     IF  ( l_temp_party_rec.primary_flag = l_curr_party_rec.primary_flag )
                      OR ( l_temp_party_rec.primary_flag = fnd_api.g_miss_char ) THEN
                           l_pty_hist_csr.old_primary_flag := NULL;
                           l_pty_hist_csr.new_primary_flag := NULL;
                     ELSE
                           l_pty_hist_csr.old_primary_flag := fnd_api.g_miss_char;
                           l_pty_hist_csr.new_primary_flag := l_temp_party_rec.primary_flag;
                     END IF;
             ELSE
                     l_pty_hist_csr.old_primary_flag := fnd_api.g_miss_char;
                     l_pty_hist_csr.new_primary_flag := l_temp_party_rec.primary_flag;
             END IF;
             --
             IF    ( l_pty_hist_csr.old_preferred_flag IS NULL
                AND  l_pty_hist_csr.new_preferred_flag IS NULL ) THEN
                     IF  ( l_temp_party_rec.preferred_flag = l_curr_party_rec.preferred_flag )
                      OR ( l_temp_party_rec.preferred_flag = fnd_api.g_miss_char ) THEN
                           l_pty_hist_csr.old_preferred_flag := NULL;
                           l_pty_hist_csr.new_preferred_flag := NULL;
                     ELSE
                           l_pty_hist_csr.old_preferred_flag := fnd_api.g_miss_char;
                           l_pty_hist_csr.new_preferred_flag := l_temp_party_rec.preferred_flag;
                     END IF;
             ELSE
                     l_pty_hist_csr.old_preferred_flag := fnd_api.g_miss_char;
                     l_pty_hist_csr.new_preferred_flag := l_temp_party_rec.preferred_flag;
             END IF;

         CSI_I_PARTIES_H_PKG.update_Row
        (
         p_INSTANCE_PARTY_HISTORY_ID     => l_party_hist_id ,
         p_INSTANCE_PARTY_ID             => FND_API.G_MISS_NUM ,
         p_TRANSACTION_ID                => FND_API.G_MISS_NUM ,
         p_OLD_PARTY_SOURCE_TABLE        => l_pty_hist_csr.OLD_PARTY_SOURCE_TABLE ,
         p_NEW_PARTY_SOURCE_TABLE        => l_pty_hist_csr.NEW_PARTY_SOURCE_TABLE ,
         p_OLD_PARTY_ID                  => l_pty_hist_csr.OLD_PARTY_ID ,
         p_NEW_PARTY_ID                  => l_pty_hist_csr.NEW_PARTY_ID ,
         p_OLD_RELATIONSHIP_TYPE_CODE    => l_pty_hist_csr.OLD_RELATIONSHIP_TYPE_CODE ,
         p_NEW_RELATIONSHIP_TYPE_CODE    => l_pty_hist_csr.NEW_RELATIONSHIP_TYPE_CODE ,
         p_OLD_CONTACT_FLAG              => l_pty_hist_csr.OLD_CONTACT_FLAG ,
         p_NEW_CONTACT_FLAG              => l_pty_hist_csr.NEW_CONTACT_FLAG ,
         p_OLD_CONTACT_IP_ID             => l_pty_hist_csr.OLD_CONTACT_IP_ID ,
         p_NEW_CONTACT_IP_ID             => l_pty_hist_csr.NEW_CONTACT_IP_ID ,
         p_OLD_ACTIVE_START_DATE         => l_pty_hist_csr.OLD_ACTIVE_START_DATE ,
         p_NEW_ACTIVE_START_DATE         => l_pty_hist_csr.NEW_ACTIVE_START_DATE ,
         p_OLD_ACTIVE_END_DATE           => l_pty_hist_csr.OLD_ACTIVE_END_DATE ,
         p_NEW_ACTIVE_END_DATE           => l_pty_hist_csr.NEW_ACTIVE_END_DATE ,
         p_OLD_CONTEXT                   => l_pty_hist_csr.OLD_CONTEXT ,
         p_NEW_CONTEXT                   => l_pty_hist_csr.NEW_CONTEXT ,
         p_OLD_ATTRIBUTE1                => l_pty_hist_csr.OLD_ATTRIBUTE1 ,
         p_NEW_ATTRIBUTE1                => l_pty_hist_csr.NEW_ATTRIBUTE1 ,
         p_OLD_ATTRIBUTE2                => l_pty_hist_csr.OLD_ATTRIBUTE2 ,
         p_NEW_ATTRIBUTE2                => l_pty_hist_csr.NEW_ATTRIBUTE2 ,
         p_OLD_ATTRIBUTE3                => l_pty_hist_csr.OLD_ATTRIBUTE3 ,
         p_NEW_ATTRIBUTE3                => l_pty_hist_csr.NEW_ATTRIBUTE3 ,
         p_OLD_ATTRIBUTE4                => l_pty_hist_csr.OLD_ATTRIBUTE4 ,
         p_NEW_ATTRIBUTE4                => l_pty_hist_csr.NEW_ATTRIBUTE4 ,
         p_OLD_ATTRIBUTE5                => l_pty_hist_csr.OLD_ATTRIBUTE5 ,
         p_NEW_ATTRIBUTE5                => l_pty_hist_csr.NEW_ATTRIBUTE5 ,
         p_OLD_ATTRIBUTE6                => l_pty_hist_csr.OLD_ATTRIBUTE6 ,
         p_NEW_ATTRIBUTE6                => l_pty_hist_csr.NEW_ATTRIBUTE6 ,
         p_OLD_ATTRIBUTE7                => l_pty_hist_csr.OLD_ATTRIBUTE7 ,
         p_NEW_ATTRIBUTE7                => l_pty_hist_csr.NEW_ATTRIBUTE7 ,
         p_OLD_ATTRIBUTE8                => l_pty_hist_csr.OLD_ATTRIBUTE8 ,
         p_NEW_ATTRIBUTE8                => l_pty_hist_csr.NEW_ATTRIBUTE8 ,
         p_OLD_ATTRIBUTE9                => l_pty_hist_csr.OLD_ATTRIBUTE9 ,
         p_NEW_ATTRIBUTE9                => l_pty_hist_csr.NEW_ATTRIBUTE9 ,
         p_OLD_ATTRIBUTE10               => l_pty_hist_csr.OLD_ATTRIBUTE10 ,
         p_NEW_ATTRIBUTE10               => l_pty_hist_csr.NEW_ATTRIBUTE10 ,
         p_OLD_ATTRIBUTE11               => l_pty_hist_csr.OLD_ATTRIBUTE11 ,
         p_NEW_ATTRIBUTE11               => l_pty_hist_csr.NEW_ATTRIBUTE11 ,
         p_OLD_ATTRIBUTE12               => l_pty_hist_csr.OLD_ATTRIBUTE12 ,
         p_NEW_ATTRIBUTE12               => l_pty_hist_csr.NEW_ATTRIBUTE12 ,
         p_OLD_ATTRIBUTE13               => l_pty_hist_csr.OLD_ATTRIBUTE13 ,
         p_NEW_ATTRIBUTE13               => l_pty_hist_csr.NEW_ATTRIBUTE13 ,
         p_OLD_ATTRIBUTE14               => l_pty_hist_csr.OLD_ATTRIBUTE14 ,
         p_NEW_ATTRIBUTE14               => l_pty_hist_csr.NEW_ATTRIBUTE14 ,
         p_OLD_ATTRIBUTE15               => l_pty_hist_csr.OLD_ATTRIBUTE15 ,
         p_NEW_ATTRIBUTE15               => l_pty_hist_csr.NEW_ATTRIBUTE15 ,
         p_FULL_DUMP_FLAG                => FND_API.G_MISS_CHAR ,
         p_CREATED_BY                    => FND_API.G_MISS_NUM ,
         p_CREATION_DATE                 => FND_API.G_MISS_DATE ,
         p_LAST_UPDATED_BY               => FND_GLOBAL.USER_ID ,
         p_LAST_UPDATE_DATE              => SYSDATE ,
         p_LAST_UPDATE_LOGIN             => FND_GLOBAL.LOGIN_ID ,
         p_OBJECT_VERSION_NUMBER         => FND_API.G_MISS_NUM ,
         p_OLD_PRIMARY_FLAG              => l_pty_hist_csr.OLD_CONTACT_FLAG ,
         p_NEW_PRIMARY_FLAG              => l_pty_hist_csr.NEW_PRIMARY_FLAG ,
         p_OLD_PREFERRED_FLAG            => l_pty_hist_csr.OLD_CONTACT_FLAG ,
         p_NEW_PREFERRED_FLAG            => l_pty_hist_csr.NEW_PREFERRED_FLAG );

        END IF;
     EXCEPTION

       WHEN NO_DATA_FOUND THEN
        IF (l_mod_value = 0) THEN
          -- If the mod value is 0 then dump all the columns both changed and unchanged
          -- changed columns have old and new values while the unchanged values have old and new values
          -- exactly same
          IF (p_party_rec.PARTY_SOURCE_TABLE = FND_API.G_MISS_CHAR) THEN
              l_temp_party_rec.PARTY_SOURCE_TABLE := l_curr_party_rec.PARTY_SOURCE_TABLE;
          END IF;
          IF (p_party_rec.PARTY_ID = FND_API.G_MISS_NUM) THEN
              l_temp_party_rec.PARTY_ID := l_curr_party_rec.PARTY_ID ;
          END IF;
          IF (p_party_rec.RELATIONSHIP_TYPE_CODE = FND_API.G_MISS_CHAR) THEN
              l_temp_party_rec.RELATIONSHIP_TYPE_CODE := l_curr_party_rec.RELATIONSHIP_TYPE_CODE ;
          END IF;
          IF (p_party_rec.CONTACT_FLAG = FND_API.G_MISS_CHAR) THEN
              l_temp_party_rec.CONTACT_FLAG := l_curr_party_rec.CONTACT_FLAG ;
          END IF;
          IF (p_party_rec.CONTACT_IP_ID = FND_API.G_MISS_NUM) THEN
              l_temp_party_rec.CONTACT_IP_ID := l_curr_party_rec.CONTACT_IP_ID ;
          END IF;
          IF (p_party_rec.ACTIVE_START_DATE = FND_API.G_MISS_DATE) THEN
              l_temp_party_rec.ACTIVE_START_DATE := l_curr_party_rec.ACTIVE_START_DATE ;
          END IF;
          IF  (p_party_rec.ACTIVE_END_DATE = FND_API.G_MISS_DATE) THEN
              l_temp_party_rec.ACTIVE_END_DATE := l_curr_party_rec.ACTIVE_END_DATE ;
          END IF;
          IF  (p_party_rec.context = FND_API.G_MISS_CHAR) THEN
              l_temp_party_rec.CONTEXT := l_curr_party_rec.CONTEXT ;
          END IF;
          IF  (p_party_rec.ATTRIBUTE1 = FND_API.G_MISS_CHAR) THEN
              l_temp_party_rec.ATTRIBUTE1 := l_curr_party_rec.ATTRIBUTE1 ;
          END IF;
          IF  (p_party_rec.ATTRIBUTE2 = FND_API.G_MISS_CHAR) THEN
              l_temp_party_rec.ATTRIBUTE2 := l_curr_party_rec.ATTRIBUTE2 ;
          END IF;
          IF  (p_party_rec.ATTRIBUTE3 = FND_API.G_MISS_CHAR) THEN
              l_temp_party_rec.ATTRIBUTE3 := l_curr_party_rec.ATTRIBUTE3 ;
          END IF;
          IF  (p_party_rec.ATTRIBUTE4 = FND_API.G_MISS_CHAR) THEN
              l_temp_party_rec.ATTRIBUTE4 := l_curr_party_rec.ATTRIBUTE4 ;
          END IF;
          IF  (p_party_rec.ATTRIBUTE5 = FND_API.G_MISS_CHAR) THEN
              l_temp_party_rec.ATTRIBUTE5 := l_curr_party_rec.ATTRIBUTE5 ;
          END IF;
          IF  (p_party_rec.ATTRIBUTE6 = FND_API.G_MISS_CHAR) THEN
              l_temp_party_rec.ATTRIBUTE6 := l_curr_party_rec.ATTRIBUTE6 ;
          END IF;
          IF  (p_party_rec.ATTRIBUTE7 = FND_API.G_MISS_CHAR) THEN
              l_temp_party_rec.ATTRIBUTE7 := l_curr_party_rec.ATTRIBUTE7 ;
          END IF;
          IF  (p_party_rec.ATTRIBUTE8 = FND_API.G_MISS_CHAR) THEN
              l_temp_party_rec.ATTRIBUTE8 := l_curr_party_rec.ATTRIBUTE8 ;
          END IF;
          IF  (p_party_rec.ATTRIBUTE9 = FND_API.G_MISS_CHAR) THEN
              l_temp_party_rec.ATTRIBUTE9 := l_curr_party_rec.ATTRIBUTE9 ;
          END IF;
          IF  (p_party_rec.ATTRIBUTE10 = FND_API.G_MISS_CHAR) THEN
              l_temp_party_rec.ATTRIBUTE10 := l_curr_party_rec.ATTRIBUTE10 ;
          END IF;
          IF  (p_party_rec.ATTRIBUTE11 = FND_API.G_MISS_CHAR) THEN
              l_temp_party_rec.ATTRIBUTE11 := l_curr_party_rec.ATTRIBUTE11 ;
          END IF;
          IF  (p_party_rec.ATTRIBUTE12 = FND_API.G_MISS_CHAR) THEN
              l_temp_party_rec.ATTRIBUTE12 := l_curr_party_rec.ATTRIBUTE12 ;
          END IF;
          IF  (p_party_rec.ATTRIBUTE13 = FND_API.G_MISS_CHAR) THEN
              l_temp_party_rec.ATTRIBUTE13 := l_curr_party_rec.ATTRIBUTE13 ;
          END IF;
          IF  (p_party_rec.ATTRIBUTE14 = FND_API.G_MISS_CHAR) THEN
              l_temp_party_rec.ATTRIBUTE14 := l_curr_party_rec.ATTRIBUTE14 ;
          END IF;
          IF  (p_party_rec.ATTRIBUTE15 = FND_API.G_MISS_CHAR) THEN
              l_temp_party_rec.ATTRIBUTE15 := l_curr_party_rec.ATTRIBUTE15 ;
          END IF;
          IF (p_party_rec.PRIMARY_FLAG = FND_API.G_MISS_CHAR) THEN
              l_temp_party_rec.PRIMARY_FLAG := l_curr_party_rec.PRIMARY_FLAG ;
          END IF;
          IF (p_party_rec.PREFERRED_FLAG = FND_API.G_MISS_CHAR) THEN
              l_temp_party_rec.PREFERRED_FLAG := l_curr_party_rec.PREFERRED_FLAG ;
          END IF;

        -- Call table handlers to insert into csi_i_parties_h table
        CSI_I_PARTIES_H_PKG.Insert_Row
        (
         px_INSTANCE_PARTY_HISTORY_ID    => l_inst_party_his_id                ,
         p_INSTANCE_PARTY_ID             => p_party_rec.INSTANCE_PARTY_ID      ,
         p_TRANSACTION_ID                => p_txn_rec.TRANSACTION_ID           ,
         p_OLD_PARTY_SOURCE_TABLE        => l_curr_party_rec.PARTY_SOURCE_TABLE,
         p_NEW_PARTY_SOURCE_TABLE        => l_temp_party_rec.PARTY_SOURCE_TABLE,
         p_OLD_PARTY_ID                  => l_curr_party_rec.PARTY_ID          ,
         p_NEW_PARTY_ID                  => l_temp_party_rec.PARTY_ID          ,
         p_OLD_RELATIONSHIP_TYPE_CODE    => l_curr_party_rec.RELATIONSHIP_TYPE_CODE,
         p_NEW_RELATIONSHIP_TYPE_CODE    => l_temp_party_rec.RELATIONSHIP_TYPE_CODE,
         p_OLD_CONTACT_FLAG              => l_curr_party_rec.CONTACT_FLAG     ,
         p_NEW_CONTACT_FLAG              => l_temp_party_rec.CONTACT_FLAG     ,
         p_OLD_CONTACT_IP_ID             => l_curr_party_rec.CONTACT_IP_ID    ,
         p_NEW_CONTACT_IP_ID             => l_temp_party_rec.CONTACT_IP_ID    ,
         p_OLD_ACTIVE_START_DATE         => l_curr_party_rec.ACTIVE_START_DATE,
         p_NEW_ACTIVE_START_DATE         => l_temp_party_rec.ACTIVE_START_DATE,
         p_OLD_ACTIVE_END_DATE           => l_curr_party_rec.ACTIVE_END_DATE  ,
         p_NEW_ACTIVE_END_DATE           => l_temp_party_rec.ACTIVE_END_DATE  ,
         p_OLD_CONTEXT                   => l_curr_party_rec.context          ,
         p_NEW_CONTEXT                   => l_temp_party_rec.context          ,
         p_OLD_ATTRIBUTE1                => l_curr_party_rec.ATTRIBUTE1       ,
         p_NEW_ATTRIBUTE1                => l_temp_party_rec.ATTRIBUTE1       ,
         p_OLD_ATTRIBUTE2                => l_curr_party_rec.ATTRIBUTE2       ,
         p_NEW_ATTRIBUTE2                => l_temp_party_rec.ATTRIBUTE2       ,
         p_OLD_ATTRIBUTE3                => l_curr_party_rec.ATTRIBUTE3       ,
         p_NEW_ATTRIBUTE3                => l_temp_party_rec.ATTRIBUTE3       ,
         p_OLD_ATTRIBUTE4                => l_curr_party_rec.ATTRIBUTE4       ,
         p_NEW_ATTRIBUTE4                => l_temp_party_rec.ATTRIBUTE4       ,
         p_OLD_ATTRIBUTE5                => l_curr_party_rec.ATTRIBUTE5       ,
         p_NEW_ATTRIBUTE5                => l_temp_party_rec.ATTRIBUTE5       ,
         p_OLD_ATTRIBUTE6                => l_curr_party_rec.ATTRIBUTE6       ,
         p_NEW_ATTRIBUTE6                => l_temp_party_rec.ATTRIBUTE6       ,
         p_OLD_ATTRIBUTE7                => l_curr_party_rec.ATTRIBUTE7       ,
         p_NEW_ATTRIBUTE7                => l_temp_party_rec.ATTRIBUTE7       ,
         p_OLD_ATTRIBUTE8                => l_curr_party_rec.ATTRIBUTE8       ,
         p_NEW_ATTRIBUTE8                => l_temp_party_rec.ATTRIBUTE8       ,
         p_OLD_ATTRIBUTE9                => l_curr_party_rec.ATTRIBUTE9       ,
         p_NEW_ATTRIBUTE9                => l_temp_party_rec.ATTRIBUTE9       ,
         p_OLD_ATTRIBUTE10               => l_curr_party_rec.ATTRIBUTE10      ,
         p_NEW_ATTRIBUTE10               => l_temp_party_rec.ATTRIBUTE10      ,
         p_OLD_ATTRIBUTE11               => l_curr_party_rec.ATTRIBUTE11      ,
         p_NEW_ATTRIBUTE11               => l_temp_party_rec.ATTRIBUTE11      ,
         p_OLD_ATTRIBUTE12               => l_curr_party_rec.ATTRIBUTE12      ,
         p_NEW_ATTRIBUTE12               => l_temp_party_rec.ATTRIBUTE12      ,
         p_OLD_ATTRIBUTE13               => l_curr_party_rec.ATTRIBUTE13      ,
         p_NEW_ATTRIBUTE13               => l_temp_party_rec.ATTRIBUTE13      ,
         p_OLD_ATTRIBUTE14               => l_curr_party_rec.ATTRIBUTE14      ,
         p_NEW_ATTRIBUTE14               => l_temp_party_rec.ATTRIBUTE14      ,
         p_OLD_ATTRIBUTE15               => l_curr_party_rec.ATTRIBUTE15      ,
         p_NEW_ATTRIBUTE15               => l_temp_party_rec.ATTRIBUTE15      ,
         p_FULL_DUMP_FLAG                => 'Y'                               ,
         p_CREATED_BY                    => FND_GLOBAL.USER_ID                ,
         p_CREATION_DATE                 => SYSDATE                           ,
         p_LAST_UPDATED_BY               => FND_GLOBAL.USER_ID                ,
         p_LAST_UPDATE_DATE              => SYSDATE                           ,
         p_LAST_UPDATE_LOGIN             => FND_GLOBAL.LOGIN_ID               ,
         p_OBJECT_VERSION_NUMBER         => 1                                 ,
         p_OLD_PRIMARY_FLAG              => l_curr_party_rec.PRIMARY_FLAG     ,
         p_NEW_PRIMARY_FLAG              => l_temp_party_rec.PRIMARY_FLAG     ,
         p_OLD_PREFERRED_FLAG            => l_curr_party_rec.PREFERRED_FLAG   ,
         p_NEW_PREFERRED_FLAG            => l_temp_party_rec.PREFERRED_FLAG     );
       ELSE

          -- If the mod value is not equal to zero then dump only the changed columns
          -- while the unchanged values have old and new values as null
           IF (p_party_rec.party_source_table = fnd_api.g_miss_char) OR
               NVL(p_party_rec.party_source_table, fnd_api.g_miss_char) = NVL(l_curr_party_rec.party_source_table, fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_party_source_table := NULL;
                l_party_hist_rec.new_party_source_table := NULL;
           ELSIF
              NVL(l_curr_party_rec.party_source_table,fnd_api.g_miss_char) <> NVL(p_party_rec.party_source_table,fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_party_source_table := l_curr_party_rec.party_source_table ;
                l_party_hist_rec.new_party_source_table := p_party_rec.party_source_table ;
           END IF;
           --
           IF (p_party_rec.party_id = fnd_api.g_miss_num) OR
               NVL(p_party_rec.party_id, fnd_api.g_miss_num) = NVL(l_curr_party_rec.party_id, fnd_api.g_miss_num) THEN
                l_party_hist_rec.old_party_id := NULL;
                l_party_hist_rec.new_party_id := NULL;
           ELSIF
              NVL(l_curr_party_rec.party_id,fnd_api.g_miss_num) <> NVL(p_party_rec.party_id,fnd_api.g_miss_num) THEN
                l_party_hist_rec.old_party_id := l_curr_party_rec.party_id ;
                l_party_hist_rec.new_party_id := p_party_rec.party_id ;
           END IF;
           --
           IF (p_party_rec.relationship_type_code = fnd_api.g_miss_char) OR
               NVL(p_party_rec.relationship_type_code, fnd_api.g_miss_char) = NVL(l_curr_party_rec.relationship_type_code, fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_relationship_type_code := NULL;
                l_party_hist_rec.new_relationship_type_code := NULL;
           ELSIF
              NVL(l_curr_party_rec.relationship_type_code,fnd_api.g_miss_char) <> NVL(p_party_rec.relationship_type_code,fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_relationship_type_code := l_curr_party_rec.relationship_type_code ;
                l_party_hist_rec.new_relationship_type_code := p_party_rec.relationship_type_code ;
           END IF;
           --
           IF (p_party_rec.contact_flag = fnd_api.g_miss_char) OR
               NVL(p_party_rec.contact_flag, fnd_api.g_miss_char) = NVL(l_curr_party_rec.contact_flag, fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_contact_flag := NULL;
                l_party_hist_rec.new_contact_flag := NULL;
           ELSIF
              NVL(l_curr_party_rec.contact_flag,fnd_api.g_miss_char) <> NVL(p_party_rec.contact_flag,fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_contact_flag := l_curr_party_rec.contact_flag ;
                l_party_hist_rec.new_contact_flag := p_party_rec.contact_flag ;
           END IF;
           --
           IF (p_party_rec.contact_ip_id = fnd_api.g_miss_num) OR
               NVL(p_party_rec.contact_ip_id, fnd_api.g_miss_num) = NVL(l_curr_party_rec.contact_ip_id, fnd_api.g_miss_num) THEN
                l_party_hist_rec.old_contact_ip_id := NULL;
                l_party_hist_rec.new_contact_ip_id := NULL;
           ELSIF
              NVL(l_curr_party_rec.contact_ip_id,fnd_api.g_miss_num) <> NVL(p_party_rec.contact_ip_id,fnd_api.g_miss_num) THEN
                l_party_hist_rec.old_contact_ip_id := l_curr_party_rec.contact_ip_id ;
                l_party_hist_rec.new_contact_ip_id := p_party_rec.contact_ip_id ;
           END IF;
           --
           IF (p_party_rec.active_start_date = fnd_api.g_miss_date) OR
               NVL(p_party_rec.active_start_date, fnd_api.g_miss_date) = NVL(l_curr_party_rec.active_start_date, fnd_api.g_miss_date) THEN
                l_party_hist_rec.old_active_start_date := NULL;
                l_party_hist_rec.new_active_start_date := NULL;
           ELSIF
              NVL(l_curr_party_rec.active_start_date,fnd_api.g_miss_date) <> NVL(p_party_rec.active_start_date,fnd_api.g_miss_date) THEN
                l_party_hist_rec.old_active_start_date := l_curr_party_rec.active_start_date ;
                l_party_hist_rec.new_active_start_date := p_party_rec.active_start_date ;
           END IF;
           --
           IF (p_party_rec.active_end_date = fnd_api.g_miss_date) OR
               NVL(p_party_rec.active_end_date, fnd_api.g_miss_date) = NVL(l_curr_party_rec.active_end_date, fnd_api.g_miss_date) THEN
                l_party_hist_rec.old_active_end_date := NULL;
                l_party_hist_rec.new_active_end_date := NULL;
           ELSIF
              NVL(l_curr_party_rec.active_end_date,fnd_api.g_miss_date) <> NVL(p_party_rec.active_end_date,fnd_api.g_miss_date) THEN
                l_party_hist_rec.old_active_end_date := l_curr_party_rec.active_end_date ;
                l_party_hist_rec.new_active_end_date := p_party_rec.active_end_date ;
           END IF;
           --
           IF (p_party_rec.context = fnd_api.g_miss_char) OR
               NVL(p_party_rec.context, fnd_api.g_miss_char) = NVL(l_curr_party_rec.context, fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_context := NULL;
                l_party_hist_rec.new_context := NULL;
           ELSIF
              NVL(l_curr_party_rec.context,fnd_api.g_miss_char) <> NVL(p_party_rec.context,fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_context := l_curr_party_rec.context ;
                l_party_hist_rec.new_context := p_party_rec.context ;
           END IF;
           --
           IF (p_party_rec.attribute1 = fnd_api.g_miss_char) OR
               NVL(p_party_rec.attribute1, fnd_api.g_miss_char) = NVL(l_curr_party_rec.attribute1, fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_attribute1 := NULL;
                l_party_hist_rec.new_attribute1 := NULL;
           ELSIF
              NVL(l_curr_party_rec.attribute1,fnd_api.g_miss_char) <> NVL(p_party_rec.attribute1,fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_attribute1 := l_curr_party_rec.attribute1 ;
                l_party_hist_rec.new_attribute1 := p_party_rec.attribute1 ;
           END IF;
           --
           IF (p_party_rec.attribute2 = fnd_api.g_miss_char) OR
               NVL(p_party_rec.attribute2, fnd_api.g_miss_char) = NVL(l_curr_party_rec.attribute2, fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_attribute2 := NULL;
                l_party_hist_rec.new_attribute2 := NULL;
           ELSIF
              NVL(l_curr_party_rec.attribute2,fnd_api.g_miss_char) <> NVL(p_party_rec.attribute2,fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_attribute2 := l_curr_party_rec.attribute2 ;
                l_party_hist_rec.new_attribute2 := p_party_rec.attribute2 ;
           END IF;
           --
           IF (p_party_rec.attribute3 = fnd_api.g_miss_char) OR
               NVL(p_party_rec.attribute3, fnd_api.g_miss_char) = NVL(l_curr_party_rec.attribute3, fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_attribute3 := NULL;
                l_party_hist_rec.new_attribute3 := NULL;
           ELSIF
              NVL(l_curr_party_rec.attribute3,fnd_api.g_miss_char) <> NVL(p_party_rec.attribute3,fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_attribute3 := l_curr_party_rec.attribute3 ;
                l_party_hist_rec.new_attribute3 := p_party_rec.attribute3 ;
           END IF;
           --
           IF (p_party_rec.attribute4 = fnd_api.g_miss_char) OR
               NVL(p_party_rec.attribute4, fnd_api.g_miss_char) = NVL(l_curr_party_rec.attribute4, fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_attribute4 := NULL;
                l_party_hist_rec.new_attribute4 := NULL;
           ELSIF
              NVL(l_curr_party_rec.attribute4,fnd_api.g_miss_char) <> NVL(p_party_rec.attribute4,fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_attribute4 := l_curr_party_rec.attribute4 ;
                l_party_hist_rec.new_attribute4 := p_party_rec.attribute4 ;
           END IF;
           --
           IF (p_party_rec.attribute5 = fnd_api.g_miss_char) OR
               NVL(p_party_rec.attribute5, fnd_api.g_miss_char) = NVL(l_curr_party_rec.attribute5, fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_attribute5 := NULL;
                l_party_hist_rec.new_attribute5 := NULL;
           ELSIF
              NVL(l_curr_party_rec.attribute5,fnd_api.g_miss_char) <> NVL(p_party_rec.attribute5,fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_attribute5 := l_curr_party_rec.attribute5 ;
                l_party_hist_rec.new_attribute5 := p_party_rec.attribute5 ;
           END IF;
           --
           IF (p_party_rec.attribute6 = fnd_api.g_miss_char) OR
               NVL(p_party_rec.attribute6, fnd_api.g_miss_char) = NVL(l_curr_party_rec.attribute6, fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_attribute6 := NULL;
                l_party_hist_rec.new_attribute6 := NULL;
           ELSIF
              NVL(l_curr_party_rec.attribute6,fnd_api.g_miss_char) <> NVL(p_party_rec.attribute6,fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_attribute6 := l_curr_party_rec.attribute6 ;
                l_party_hist_rec.new_attribute6 := p_party_rec.attribute6 ;
           END IF;
           --
           IF (p_party_rec.attribute7 = fnd_api.g_miss_char) OR
               NVL(p_party_rec.attribute7, fnd_api.g_miss_char) = NVL(l_curr_party_rec.attribute7, fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_attribute7 := NULL;
                l_party_hist_rec.new_attribute7 := NULL;
           ELSIF
              NVL(l_curr_party_rec.attribute7,fnd_api.g_miss_char) <> NVL(p_party_rec.attribute7,fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_attribute7 := l_curr_party_rec.attribute7 ;
                l_party_hist_rec.new_attribute7 := p_party_rec.attribute7 ;
           END IF;
           --
           IF (p_party_rec.attribute8 = fnd_api.g_miss_char) OR
               NVL(p_party_rec.attribute8, fnd_api.g_miss_char) = NVL(l_curr_party_rec.attribute8, fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_attribute8 := NULL;
                l_party_hist_rec.new_attribute8 := NULL;
           ELSIF
              NVL(l_curr_party_rec.attribute8,fnd_api.g_miss_char) <> NVL(p_party_rec.attribute8,fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_attribute8 := l_curr_party_rec.attribute8 ;
                l_party_hist_rec.new_attribute8 := p_party_rec.attribute8 ;
           END IF;
           --
           IF (p_party_rec.attribute9 = fnd_api.g_miss_char) OR
               NVL(p_party_rec.attribute9, fnd_api.g_miss_char) = NVL(l_curr_party_rec.attribute9, fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_attribute9 := NULL;
                l_party_hist_rec.new_attribute9 := NULL;
           ELSIF
              NVL(l_curr_party_rec.attribute9,fnd_api.g_miss_char) <> NVL(p_party_rec.attribute9,fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_attribute9 := l_curr_party_rec.attribute9 ;
                l_party_hist_rec.new_attribute9 := p_party_rec.attribute9 ;
           END IF;
           --
           IF (p_party_rec.attribute10 = fnd_api.g_miss_char) OR
               NVL(p_party_rec.attribute10, fnd_api.g_miss_char) = NVL(l_curr_party_rec.attribute10, fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_attribute10 := NULL;
                l_party_hist_rec.new_attribute10 := NULL;
           ELSIF
              NVL(l_curr_party_rec.attribute10,fnd_api.g_miss_char) <> NVL(p_party_rec.attribute10,fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_attribute10 := l_curr_party_rec.attribute10 ;
                l_party_hist_rec.new_attribute10 := p_party_rec.attribute10 ;
           END IF;
           --
           IF (p_party_rec.attribute11 = fnd_api.g_miss_char) OR
               NVL(p_party_rec.attribute11, fnd_api.g_miss_char) = NVL(l_curr_party_rec.attribute11, fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_attribute11 := NULL;
                l_party_hist_rec.new_attribute11 := NULL;
           ELSIF
              NVL(l_curr_party_rec.attribute11,fnd_api.g_miss_char) <> NVL(p_party_rec.attribute11,fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_attribute11 := l_curr_party_rec.attribute11 ;
                l_party_hist_rec.new_attribute11 := p_party_rec.attribute11 ;
           END IF;
           --
           IF (p_party_rec.attribute12 = fnd_api.g_miss_char) OR
               NVL(p_party_rec.attribute12, fnd_api.g_miss_char) = NVL(l_curr_party_rec.attribute12, fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_attribute12 := NULL;
                l_party_hist_rec.new_attribute12 := NULL;
           ELSIF
              NVL(l_curr_party_rec.attribute12,fnd_api.g_miss_char) <> NVL(p_party_rec.attribute12,fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_attribute12 := l_curr_party_rec.attribute12 ;
                l_party_hist_rec.new_attribute12 := p_party_rec.attribute12 ;
           END IF;
           --
           IF (p_party_rec.attribute13 = fnd_api.g_miss_char) OR
               NVL(p_party_rec.attribute13, fnd_api.g_miss_char) = NVL(l_curr_party_rec.attribute13, fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_attribute13 := NULL;
                l_party_hist_rec.new_attribute13 := NULL;
           ELSIF
              NVL(l_curr_party_rec.attribute13,fnd_api.g_miss_char) <> NVL(p_party_rec.attribute13,fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_attribute13 := l_curr_party_rec.attribute13 ;
                l_party_hist_rec.new_attribute13 := p_party_rec.attribute13 ;
           END IF;
           --
           IF (p_party_rec.attribute14 = fnd_api.g_miss_char) OR
               NVL(p_party_rec.attribute14, fnd_api.g_miss_char) = NVL(l_curr_party_rec.attribute14, fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_attribute14 := NULL;
                l_party_hist_rec.new_attribute14 := NULL;
           ELSIF
              NVL(l_curr_party_rec.attribute14,fnd_api.g_miss_char) <> NVL(p_party_rec.attribute14,fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_attribute14 := l_curr_party_rec.attribute14 ;
                l_party_hist_rec.new_attribute14 := p_party_rec.attribute14 ;
           END IF;
           --
           IF (p_party_rec.attribute15 = fnd_api.g_miss_char) OR
               NVL(p_party_rec.attribute15, fnd_api.g_miss_char) = NVL(l_curr_party_rec.attribute15, fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_attribute15 := NULL;
                l_party_hist_rec.new_attribute15 := NULL;
           ELSIF
              NVL(l_curr_party_rec.attribute15,fnd_api.g_miss_char) <> NVL(p_party_rec.attribute15,fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_attribute15 := l_curr_party_rec.attribute15 ;
                l_party_hist_rec.new_attribute15 := p_party_rec.attribute15 ;
           END IF;
           --
           IF (p_party_rec.primary_flag = fnd_api.g_miss_char) OR
               NVL(p_party_rec.primary_flag, fnd_api.g_miss_char) = NVL(l_curr_party_rec.primary_flag, fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_primary_flag := NULL;
                l_party_hist_rec.new_primary_flag := NULL;
           ELSIF
              NVL(l_curr_party_rec.primary_flag,fnd_api.g_miss_char) <> NVL(p_party_rec.primary_flag,fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_primary_flag := l_curr_party_rec.primary_flag ;
                l_party_hist_rec.new_primary_flag := p_party_rec.primary_flag ;
           END IF;
           --
           IF (p_party_rec.preferred_flag = fnd_api.g_miss_char) OR
               NVL(p_party_rec.preferred_flag, fnd_api.g_miss_char) = NVL(l_curr_party_rec.preferred_flag, fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_preferred_flag := NULL;
                l_party_hist_rec.new_preferred_flag := NULL;
           ELSIF
              NVL(l_curr_party_rec.preferred_flag,fnd_api.g_miss_char) <> NVL(p_party_rec.preferred_flag,fnd_api.g_miss_char) THEN
                l_party_hist_rec.old_preferred_flag := l_curr_party_rec.preferred_flag ;
                l_party_hist_rec.new_preferred_flag := p_party_rec.preferred_flag ;
           END IF;

        -- Call table handlers to insert into csi_i_parties_h table
        CSI_I_PARTIES_H_PKG.Insert_Row
        (
         px_INSTANCE_PARTY_HISTORY_ID    => l_inst_party_his_id ,
         p_INSTANCE_PARTY_ID             => p_party_rec.INSTANCE_PARTY_ID ,
         p_TRANSACTION_ID                => p_txn_rec.TRANSACTION_ID ,
         p_OLD_PARTY_SOURCE_TABLE        => l_party_hist_rec.OLD_PARTY_SOURCE_TABLE ,
         p_NEW_PARTY_SOURCE_TABLE        => l_party_hist_rec.NEW_PARTY_SOURCE_TABLE ,
         p_OLD_PARTY_ID                  => l_party_hist_rec.OLD_PARTY_ID ,
         p_NEW_PARTY_ID                  => l_party_hist_rec.NEW_PARTY_ID ,
         p_OLD_RELATIONSHIP_TYPE_CODE    => l_party_hist_rec.OLD_RELATIONSHIP_TYPE_CODE ,
         p_NEW_RELATIONSHIP_TYPE_CODE    => l_party_hist_rec.NEW_RELATIONSHIP_TYPE_CODE ,
         p_OLD_CONTACT_FLAG              => l_party_hist_rec.OLD_CONTACT_FLAG ,
         p_NEW_CONTACT_FLAG              => l_party_hist_rec.NEW_CONTACT_FLAG ,
         p_OLD_CONTACT_IP_ID             => l_party_hist_rec.OLD_CONTACT_IP_ID ,
         p_NEW_CONTACT_IP_ID             => l_party_hist_rec.NEW_CONTACT_IP_ID ,
         p_OLD_ACTIVE_START_DATE         => l_party_hist_rec.OLD_ACTIVE_START_DATE ,
         p_NEW_ACTIVE_START_DATE         => l_party_hist_rec.NEW_ACTIVE_START_DATE ,
         p_OLD_ACTIVE_END_DATE           => l_party_hist_rec.OLD_ACTIVE_END_DATE ,
         p_NEW_ACTIVE_END_DATE           => l_party_hist_rec.NEW_ACTIVE_END_DATE ,
         p_OLD_CONTEXT                   => l_party_hist_rec.OLD_CONTEXT ,
         p_NEW_CONTEXT                   => l_party_hist_rec.NEW_CONTEXT ,
         p_OLD_ATTRIBUTE1                => l_party_hist_rec.OLD_ATTRIBUTE1 ,
         p_NEW_ATTRIBUTE1                => l_party_hist_rec.NEW_ATTRIBUTE1 ,
         p_OLD_ATTRIBUTE2                => l_party_hist_rec.OLD_ATTRIBUTE2 ,
         p_NEW_ATTRIBUTE2                => l_party_hist_rec.NEW_ATTRIBUTE2 ,
         p_OLD_ATTRIBUTE3                => l_party_hist_rec.OLD_ATTRIBUTE3 ,
         p_NEW_ATTRIBUTE3                => l_party_hist_rec.NEW_ATTRIBUTE3 ,
         p_OLD_ATTRIBUTE4                => l_party_hist_rec.OLD_ATTRIBUTE4 ,
         p_NEW_ATTRIBUTE4                => l_party_hist_rec.NEW_ATTRIBUTE4 ,
         p_OLD_ATTRIBUTE5                => l_party_hist_rec.OLD_ATTRIBUTE5 ,
         p_NEW_ATTRIBUTE5                => l_party_hist_rec.NEW_ATTRIBUTE5 ,
         p_OLD_ATTRIBUTE6                => l_party_hist_rec.OLD_ATTRIBUTE6 ,
         p_NEW_ATTRIBUTE6                => l_party_hist_rec.NEW_ATTRIBUTE6 ,
         p_OLD_ATTRIBUTE7                => l_party_hist_rec.OLD_ATTRIBUTE7 ,
         p_NEW_ATTRIBUTE7                => l_party_hist_rec.NEW_ATTRIBUTE7 ,
         p_OLD_ATTRIBUTE8                => l_party_hist_rec.OLD_ATTRIBUTE8 ,
         p_NEW_ATTRIBUTE8                => l_party_hist_rec.NEW_ATTRIBUTE8 ,
         p_OLD_ATTRIBUTE9                => l_party_hist_rec.OLD_ATTRIBUTE9 ,
         p_NEW_ATTRIBUTE9                => l_party_hist_rec.NEW_ATTRIBUTE9 ,
         p_OLD_ATTRIBUTE10               => l_party_hist_rec.OLD_ATTRIBUTE10 ,
         p_NEW_ATTRIBUTE10               => l_party_hist_rec.NEW_ATTRIBUTE10 ,
         p_OLD_ATTRIBUTE11               => l_party_hist_rec.OLD_ATTRIBUTE11 ,
         p_NEW_ATTRIBUTE11               => l_party_hist_rec.NEW_ATTRIBUTE11 ,
         p_OLD_ATTRIBUTE12               => l_party_hist_rec.OLD_ATTRIBUTE12 ,
         p_NEW_ATTRIBUTE12               => l_party_hist_rec.NEW_ATTRIBUTE12 ,
         p_OLD_ATTRIBUTE13               => l_party_hist_rec.OLD_ATTRIBUTE13 ,
         p_NEW_ATTRIBUTE13               => l_party_hist_rec.NEW_ATTRIBUTE13 ,
         p_OLD_ATTRIBUTE14               => l_party_hist_rec.OLD_ATTRIBUTE14 ,
         p_NEW_ATTRIBUTE14               => l_party_hist_rec.NEW_ATTRIBUTE14 ,
         p_OLD_ATTRIBUTE15               => l_party_hist_rec.OLD_ATTRIBUTE15 ,
         p_NEW_ATTRIBUTE15               => l_party_hist_rec.NEW_ATTRIBUTE15 ,
         p_FULL_DUMP_FLAG                => 'N',
         p_CREATED_BY                    => FND_GLOBAL.USER_ID ,
         p_CREATION_DATE                 => SYSDATE ,
         p_LAST_UPDATED_BY               => FND_GLOBAL.USER_ID ,
         p_LAST_UPDATE_DATE              => SYSDATE ,
         p_LAST_UPDATE_LOGIN             => FND_GLOBAL.LOGIN_ID ,
         p_OBJECT_VERSION_NUMBER         => 1 ,
         p_OLD_PRIMARY_FLAG              => l_party_hist_rec.OLD_PRIMARY_FLAG ,
         p_NEW_PRIMARY_FLAG              => l_party_hist_rec.NEW_PRIMARY_FLAG ,
         p_OLD_PREFERRED_FLAG            => l_party_hist_rec.OLD_PREFERRED_FLAG ,
         p_NEW_PREFERRED_FLAG            => l_party_hist_rec.NEW_PREFERRED_FLAG );

        END IF;

     END;
  -- End of Changes for Bug#2547034 on 09/20/02 - rtalluri

      --  Update accounting class code in csi_item_instances table

      csi_item_instance_pvt.get_and_update_acct_class
         ( p_api_version         =>     p_api_version
          ,p_commit              =>     p_commit
          ,p_init_msg_list       =>     p_init_msg_list
          ,p_validation_level    =>     p_validation_level
          ,p_instance_id         =>     l_curr_party_rec.instance_id
          ,p_txn_rec             =>     p_txn_rec
          ,x_acct_class_code     =>     l_acct_class_code
          ,x_return_status       =>     x_return_status
          ,x_msg_count           =>     x_msg_count
          ,x_msg_data            =>     x_msg_data
         );

      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         FOR i in 1..x_msg_Count LOOP
            FND_MSG_PUB.Get(p_msg_index     => i,
                            p_encoded       => 'F',
                            p_data          => x_msg_data,
                            p_msg_index_out => x_msg_index_out );
         End LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- srramakr Bug # 2232230. Expire the Contacts incase of Xfer of Ownership.
      --
      IF ((p_party_rec.PARTY_ID <> FND_API.G_MISS_NUM)
         AND (p_party_rec.PARTY_ID IS NOT NULL)
         AND (p_party_rec.PARTY_ID <> l_curr_party_rec.PARTY_ID))
      THEN
	 For cont_rec in get_cont_party_rec(p_party_rec.INSTANCE_PARTY_ID)
         LOOP
            l_cont_party_rec := l_init_party_rec;
            l_cont_party_rec.instance_party_id := cont_rec.instance_party_id;
            l_cont_party_rec.object_version_number := cont_rec.object_version_number;
            -- Calling Expire Instance Party Relationship
	    expire_inst_party_relationship
	     (    p_api_version                 =>  p_api_version
		 ,p_commit                      =>  fnd_api.g_false
		 ,p_init_msg_list               =>  fnd_api.g_false
		 ,p_validation_level            =>  fnd_api.g_valid_level_full
		 ,p_instance_party_rec          =>  l_cont_party_rec
		 ,p_txn_rec                     =>  p_txn_rec
		 ,x_return_status               =>  x_return_status
		 ,x_msg_count                   =>  x_msg_count
		 ,x_msg_data                    =>  x_msg_data
		);
	    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	       FOR i in 1..x_msg_Count LOOP
		  FND_MSG_PUB.Get(p_msg_index     => i,
				  p_encoded       => 'F',
				  p_data          => x_msg_data,
				  p_msg_index_out => x_msg_index_out );
	       End LOOP;
	       RAISE FND_API.G_EXC_ERROR;
	    END IF;
         END LOOP;
      END IF;
      -- End of API body
      -- Standard check of p_commit.
      IF FND_API.To_Boolean( p_commit ) THEN
         COMMIT WORK;
      END IF;
      -- Standard call to get message count and if count is  get message info.
      FND_MSG_PUB.Count_And_Get
                (p_count        =>      x_msg_count ,
                 p_data         =>      x_msg_data  );
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                -- ROLLBACK TO update_inst_party_rel_pvt;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count    =>      x_msg_count,
                        p_data     =>      x_msg_data );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                -- ROLLBACK TO update_inst_party_rel_pvt;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count   =>      x_msg_count,
                        p_data    =>      x_msg_data );
        WHEN OTHERS THEN
                -- ROLLBACK TO update_inst_party_rel_pvt;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF FND_MSG_PUB.Check_Msg_Level
                     (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                   FND_MSG_PUB.Add_Exc_Msg
                    ( g_pkg_name, l_api_name );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_count  =>      x_msg_count,
                        p_data   =>      x_msg_data  );

END update_inst_party_relationship ;

/*-------------------------------------------------------*/
/* Procedure name:  Expire_inst_party_relationship       */
/* Description :  Procedure used to  expire an existing  */
/*                instance -party relationships          */
/*-------------------------------------------------------*/

PROCEDURE expire_inst_party_relationship
 (    p_api_version                 IN  NUMBER
     ,p_commit                      IN  VARCHAR2
     ,p_init_msg_list               IN  VARCHAR2
     ,p_validation_level            IN  NUMBER
     ,p_instance_party_rec          IN  csi_datastructures_pub.party_rec
     ,p_txn_rec                     IN OUT NOCOPY  csi_datastructures_pub.transaction_rec
     ,x_return_status               OUT NOCOPY  VARCHAR2
     ,x_msg_count                   OUT NOCOPY  NUMBER
     ,x_msg_data                    OUT NOCOPY  VARCHAR2
    ) IS

     l_api_name      CONSTANT VARCHAR2(30)   := 'EXPIRE_INST_PARTY_RELATIONSHIP';
     l_api_version   CONSTANT NUMBER         := 1.0;
     l_csi_debug_level        NUMBER;
     l_party_rec              csi_datastructures_pub.party_rec;
     l_msg_index              NUMBER;
     l_msg_count              NUMBER;
     l_line_count             NUMBER;
     l_full_dump_frequency    NUMBER;
     l_mod_value              NUMBER;
     l_curr_party_rec         csi_datastructures_pub.party_rec;
     l_party_account_rec      csi_datastructures_pub.party_account_rec;
     l_OBJECT_VERSION_NUMBER  NUMBER;
     l_inst_party_his_id      NUMBER;
     l_temp_party_acct_rec    csi_datastructures_pub.party_account_rec;
     --
   CURSOR get_curr_party_rec (p_inst_party_id   IN  NUMBER) IS
     SELECT
     instance_party_id  ,
     instance_id        ,
     party_source_table ,
     party_id           ,
     relationship_type_code,
     contact_flag       ,
     contact_ip_id      ,
     active_start_date  ,
     active_end_date    ,
     context            ,
     attribute1         ,
     attribute2         ,
     attribute3         ,
     attribute4         ,
     attribute5         ,
     attribute6         ,
     attribute7         ,
     attribute8         ,
     attribute9         ,
     attribute10        ,
     attribute11        ,
     attribute12        ,
     attribute13        ,
     attribute14        ,
     attribute15        ,
     object_version_number,
     primary_flag       ,
     preferred_flag     ,
     null parent_tbl_index  ,
     null call_contracts,
     null interface_id,
     null contact_parent_tbl_index,
     null cascade_ownership_flag -- Added for bug 2972082
    FROM CSI_I_PARTIES
   WHERE INSTANCE_PARTY_ID = p_inst_party_id
    AND (( ACTIVE_END_DATE IS NULL) OR (ACTIVE_END_DATE >= SYSDATE))
     FOR UPDATE OF OBJECT_VERSION_NUMBER;

BEGIN
   -- Standard Start of API savepoint
   -- SAVEPOINT  expire_inst_party_rel_pvt;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (    l_api_version   ,
					   p_api_version   ,
					   l_api_name      ,
					   g_pkg_name      )
   THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
	   FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   -- Verify if the Party rel combination exists
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Check the profile option CSI_DEBUG_LEVEL for debug message reporting
   l_csi_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If CSI_DEBUG_LEVEL = 1 then dump the procedure name
   IF (l_csi_debug_level > 0) THEN
       csi_gen_utility_pvt.put_line( 'expire_inst_party_relationship');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (l_csi_debug_level > 1) THEN
       csi_gen_utility_pvt.put_line( 'expire_inst_party_relationship:'||
					    p_api_version           ||'-'||
					    p_commit                ||'-'||
					    p_init_msg_list               );

       -- Dump the records in the log file
       csi_gen_utility_pvt.dump_party_rec(p_instance_party_rec );
       csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
   END IF;
   -- Start API body
   --
   -- Check if all the required parameters are passed
    CSI_Instance_parties_vld_pvt.Check_Reqd_Param_num
	 (    p_instance_party_rec.instance_party_id ,
	       '  p_instance_party_rec.instance_party_id  ',
		  l_api_name  );
    CSI_Instance_parties_vld_pvt.Check_Reqd_Param_num
	 (    p_instance_party_rec.object_version_number ,
	       '  p_instance_party_rec.object_version_number  ',
		  l_api_name  );

   -- Check if the instance party id  is valid
   IF NOT(CSI_Instance_parties_vld_pvt.Is_Inst_partyID_Valid
		(p_Instance_party_id => p_instance_party_rec.instance_party_id
		,p_txn_type_id       => p_txn_rec.transaction_type_id
		,p_mode              => 'E'      -- Added for bug 3550541
		 )
	  )
   THEN
    -- Message added in the validation routine since additional validation added for bug # 2477417.
      --  FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INST_PARTY_ID');
      --  FND_MESSAGE.SET_TOKEN('INSTANCE_PARTY_ID',p_instance_party_rec.instance_party_id);
      --  FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
   END IF;
   -- check if the object_version_number passed matches with the one
   -- in the database else raise error
   OPEN get_curr_party_rec(p_instance_party_rec.instance_party_id);
   FETCH get_curr_party_rec INTO l_curr_party_rec;
   IF  (l_curr_party_rec.object_version_number <> p_instance_party_rec.OBJECT_VERSION_NUMBER) THEN
       FND_MESSAGE.Set_Name('CSI', 'CSI_API_OBJ_VER_MISMATCH');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
   END IF;
   --
   IF get_curr_party_rec%NOTFOUND THEN
     FND_MESSAGE.Set_Name('CSI', 'CSI_API_RECORD_LOCKED');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE get_curr_party_rec;
   -- Initialize all the parameters and call update_inst_party_relationship to expire the record
   l_party_rec.instance_party_id          :=   l_curr_party_rec.instance_party_id;
   l_party_rec.instance_id                :=   FND_API.G_MISS_NUM;
   l_party_rec.PARTY_SOURCE_TABLE         :=   FND_API.G_MISS_CHAR;
   l_party_rec.PARTY_ID                   :=   FND_API.G_MISS_NUM;
   l_party_rec.RELATIONSHIP_TYPE_CODE     :=   FND_API.G_MISS_CHAR;
   l_party_rec.CONTACT_FLAG      :=   FND_API.G_MISS_CHAR;
   l_party_rec.CONTACT_IP_ID     :=   FND_API.G_MISS_NUM;
   l_party_rec.ACTIVE_START_DATE :=   FND_API.G_MISS_DATE;
   l_party_rec.ACTIVE_END_DATE   := sysdate;
   l_party_rec.CONTEXT        :=   FND_API.G_MISS_CHAR;
   l_party_rec.ATTRIBUTE1     :=   FND_API.G_MISS_CHAR;
   l_party_rec.ATTRIBUTE2     :=   FND_API.G_MISS_CHAR;
   l_party_rec.ATTRIBUTE3     :=   FND_API.G_MISS_CHAR;
   l_party_rec.ATTRIBUTE4     :=   FND_API.G_MISS_CHAR;
   l_party_rec.ATTRIBUTE5     :=   FND_API.G_MISS_CHAR;
   l_party_rec.ATTRIBUTE6     :=   FND_API.G_MISS_CHAR;
   l_party_rec.ATTRIBUTE7     :=   FND_API.G_MISS_CHAR;
   l_party_rec.ATTRIBUTE8     :=   FND_API.G_MISS_CHAR;
   l_party_rec.ATTRIBUTE9     :=   FND_API.G_MISS_CHAR;
   l_party_rec.ATTRIBUTE10    :=   FND_API.G_MISS_CHAR;
   l_party_rec.ATTRIBUTE11    :=   FND_API.G_MISS_CHAR;
   l_party_rec.ATTRIBUTE12    :=   FND_API.G_MISS_CHAR;
   l_party_rec.ATTRIBUTE13    :=   FND_API.G_MISS_CHAR;
   l_party_rec.ATTRIBUTE14    :=   FND_API.G_MISS_CHAR;
   l_party_rec.ATTRIBUTE15    :=   FND_API.G_MISS_CHAR;
   l_party_rec.OBJECT_VERSION_NUMBER  :=  p_instance_party_rec.object_version_number;
   --
   g_expire_party_flag := 'Y';
   update_inst_party_relationship
	   ( p_api_version      => p_api_version
	    ,p_commit           => p_commit
	    ,p_init_msg_list    => p_init_msg_list
	    ,p_validation_level => p_validation_level
	    ,p_party_rec        => l_party_rec
	    ,p_txn_rec          => p_txn_rec
	    ,x_return_status    => x_return_status
	    ,x_msg_count        => x_msg_count
	    ,x_msg_data         => x_msg_data  ) ;

   g_expire_party_flag := 'N';
   IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      l_msg_index := 1;
      l_msg_count := x_msg_count;
      WHILE l_msg_count > 0 LOOP
         x_msg_data := FND_MSG_PUB.GET(
				l_msg_index,
				FND_API.G_FALSE );
         csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
		      l_msg_index := l_msg_index + 1;
		      l_msg_count := l_msg_count - 1;
      END LOOP;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   --
   -- End of API body

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
	   COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is  get message info.
   FND_MSG_PUB.Count_And_Get
	   (p_count        =>      x_msg_count ,
	    p_data         =>      x_msg_data  );
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                -- ROLLBACK TO expire_inst_party_rel_pvt;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count   =>      x_msg_count,
                        p_data    =>      x_msg_data  );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                -- ROLLBACK TO expire_inst_party_rel_pvt;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count    =>      x_msg_count,
                        p_data     =>      x_msg_data   );
        WHEN OTHERS THEN
                -- ROLLBACK TO expire_inst_party_rel_pvt;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF FND_MSG_PUB.Check_Msg_Level
                     (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                   FND_MSG_PUB.Add_Exc_Msg
                    ( g_pkg_name, l_api_name );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_count  =>      x_msg_count,
                        p_data   =>      x_msg_data  );
END  expire_inst_party_relationship;

/*-----------------------------------------------------------*/
/* Procedure name:  Create_inst_party_account                */
/* Description :  Procedure used to  create new              */
/*                instance-party account relationships       */
/*-----------------------------------------------------------*/

PROCEDURE create_inst_party_account
   (  p_api_version         IN  NUMBER
     ,p_commit              IN  VARCHAR2
     ,p_init_msg_list       IN  VARCHAR2
     ,p_validation_level    IN  NUMBER
     ,p_party_account_rec   IN OUT NOCOPY   csi_datastructures_pub.party_account_rec
     ,p_txn_rec             IN OUT NOCOPY   csi_datastructures_pub.transaction_rec
     ,x_return_status       OUT NOCOPY  VARCHAR2
     ,x_msg_count           OUT NOCOPY  NUMBER
     ,x_msg_data            OUT NOCOPY  VARCHAR2
     ,p_inst_party_tbl      IN OUT NOCOPY   csi_party_relationships_pvt.inst_party_tbl
     ,p_acct_rel_type_tbl   IN OUT NOCOPY   csi_party_relationships_pvt.acct_rel_type_tbl
     ,p_site_use_tbl        IN OUT NOCOPY   csi_party_relationships_pvt.site_use_tbl
     ,p_account_count_rec   IN OUT NOCOPY   csi_party_relationships_pvt.account_count_rec
     ,p_called_from_grp     IN  VARCHAR2
     ,p_oks_txn_inst_tbl    IN OUT NOCOPY   oks_ibint_pub.txn_instance_tbl
    ) IS

     l_api_name      CONSTANT VARCHAR2(30)   := 'CREATE_INST_PARTY_ACCOUNT';
     l_api_version   CONSTANT NUMBER             := 1.0;
     l_csi_debug_level        NUMBER;
     l_party_account_rec      csi_datastructures_pub.party_account_rec;
     l_party_rec              csi_datastructures_pub.party_rec;
     l_msg_index              NUMBER;
     l_msg_count              NUMBER;
     l_process_flag           BOOLEAN := TRUE;
     l_ip_account_history_id  NUMBER;

      l_transaction_type              VARCHAR2(10);
      l_old_oks_cp_rec                oks_ibint_pub.cp_rec_type;
      l_new_oks_cp_rec                oks_ibint_pub.cp_rec_type;
      l_contracts_status              VARCHAR2(3);
      l_internal_party_id             NUMBER;
      l_party_id                      NUMBER;
      l_record_found           BOOLEAN := FALSE;
      l_update_record          BOOLEAN := FALSE;
      l_exists_flag            VARCHAR2(1);
      l_valid_flag             VARCHAR2(1);

    CURSOR instance_csr (p_ins_id IN NUMBER) IS
      SELECT  *
      FROM    csi_item_instances
      WHERE   instance_id = p_ins_id;
    l_instance_csr    instance_csr%ROWTYPE;
    l_last_vld_org    NUMBER;      -- Added by sguthiva for bug 2307804
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  create_inst_party_acct_pvt;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (    l_api_version           ,
					   p_api_version           ,
					   l_api_name              ,
					   g_pkg_name              )
   THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
	   FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Check the profile option CSI_DEBUG_LEVEL for debug message reporting
   l_csi_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If CSI_DEBUG_LEVEL = 1 then dump the procedure name
   IF (l_csi_debug_level > 0) THEN
       csi_gen_utility_pvt.put_line( 'create_inst_party_account');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (l_csi_debug_level > 1) THEN
	  csi_gen_utility_pvt.put_line( 'create_inst_party_account:'||
					  p_api_version           ||'-'||
					  p_commit                ||'-'||
					  p_init_msg_list                );
	  -- Dump the records in the log file
	  csi_gen_utility_pvt.dump_party_account_rec(p_party_account_rec);
	  csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
   END IF;
   -- Start API body
   --
   -- Check if all the required parameters are passed
   CSI_Instance_parties_vld_pvt.Check_Reqd_Param_num
	 (    p_party_account_rec.INSTANCE_PARTY_ID,
		' p_party_account_rec.INSTANCE_PARTY_ID ',
		  l_api_name           );

   CSI_Instance_parties_vld_pvt.Check_Reqd_Param_num
	 (    p_party_account_rec.PARTY_ACCOUNT_ID,
		' p_party_account_rec.PARTY_ACCOUNT_ID ',
		  l_api_name           );
   CSI_Instance_parties_vld_pvt.Check_Reqd_Param_char
	 (     p_party_account_rec.RELATIONSHIP_TYPE_CODE,
		  'p_party_account_rec.RELATIONSHIP_TYPE_CODE',
		   l_api_name           );

   -- Initialize the counts
   IF p_account_count_rec.inst_party_count is NULL OR
      p_account_count_rec.inst_party_count = FND_API.G_MISS_NUM THEN
      p_account_count_rec.inst_party_count := 0;
   END IF;
   --
   IF p_account_count_rec.rel_type_count is NULL OR
      p_account_count_rec.rel_type_count = FND_API.G_MISS_NUM THEN
      p_account_count_rec.rel_type_count := 0;
   END IF;
   --
   IF p_account_count_rec.site_use_count is NULL OR
      p_account_count_rec.site_use_count = FND_API.G_MISS_NUM THEN
      p_account_count_rec.site_use_count := 0;
   END IF;
   --
   -- Added by sk for fixing bug 2110790
   l_update_record := FALSE;
   IF p_called_from_grp <> FND_API.G_TRUE THEN
      IF     p_party_account_rec.relationship_type_code = 'OWNER'
	AND ( p_party_account_rec.ip_account_id IS NULL OR
	      p_party_account_rec.ip_account_id = fnd_api.g_miss_num )
      THEN
	 BEGIN
	    SELECT ip_account_id,
	           active_start_date,
		    object_version_number
	    INTO   p_party_account_rec.ip_account_id,
		    p_party_account_rec.active_start_date,
		    p_party_account_rec.object_version_number
	    FROM   csi_ip_accounts
	    WHERE  instance_party_id = p_party_account_rec.instance_party_id
	    AND    relationship_type_code = 'OWNER'
	    AND   (active_end_date IS NULL OR active_end_date > SYSDATE)
	    AND    ROWNUM = 1;

	    IF p_party_account_rec.active_end_date = fnd_api.g_miss_date
	    THEN
	       p_party_account_rec.active_end_date := NULL ;
	    END IF;
            --
	    l_update_record := TRUE;
	 EXCEPTION
	    WHEN NO_DATA_FOUND THEN
	       BEGIN
		  SELECT ip_account_id,
			 active_start_date,
			 object_version_number
		  INTO   p_party_account_rec.ip_account_id,
			 p_party_account_rec.active_start_date,
			 p_party_account_rec.object_version_number
		  FROM   csi_ip_accounts
		  WHERE  instance_party_id = p_party_account_rec.instance_party_id
		  AND    relationship_type_code = 'OWNER'
		  AND    ROWNUM = 1;

		  IF p_party_account_rec.active_end_date = fnd_api.g_miss_date
		  THEN
		     p_party_account_rec.active_end_date := NULL ;
		  END IF;
		     l_update_record := TRUE;
	       EXCEPTION
		  WHEN OTHERS THEN
	             NULL;
	       END;
	    WHEN OTHERS THEN
	       NULL;
	 END;
         --
	 IF l_update_record
	 THEN
	    update_inst_party_account
		(     p_api_version         => p_api_version
		     ,p_commit              => p_commit
		     ,p_init_msg_list       => p_init_msg_list
		     ,p_validation_level    => p_validation_level
		     ,p_party_account_rec   => p_party_account_rec
		     ,p_txn_rec             => p_txn_rec
                     ,p_oks_txn_inst_tbl    => p_oks_txn_inst_tbl
		     ,x_return_status       => x_return_status
		     ,x_msg_count           => x_msg_count
		     ,x_msg_data            => x_msg_data);

	    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
			  l_msg_index := 1;
			  l_msg_count := x_msg_count;
	       WHILE l_msg_count > 0 LOOP
				   x_msg_data := FND_MSG_PUB.GET(
					       l_msg_index,
					       FND_API.G_FALSE  );
			csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
				  l_msg_index := l_msg_index + 1;
				  l_msg_count := l_msg_count - 1;
	       END LOOP;
	       RAISE FND_API.G_EXC_ERROR;
	    END IF;
         END IF;
      END IF;
   END IF; -- Called from group check
   -- End addition by sk for fixing bug 2110790
   -- Check if the account is already expired
   -- If so unexpire the account
   l_record_found := FALSE;
   IF p_called_from_grp <> FND_API.G_TRUE THEN
      IF p_party_account_rec.ip_account_id IS NULL OR
         p_party_account_rec.ip_account_id = fnd_api.g_miss_num
      THEN
         BEGIN
            SELECT ip_account_id ,
                   object_version_number
            INTO  p_party_account_rec.ip_account_id,
                  p_party_account_rec.object_version_number
            FROM  csi_ip_accounts
            WHERE instance_party_id    = p_party_account_rec.instance_party_id
            AND party_account_id       = p_party_account_rec.party_account_id
            AND relationship_type_code = p_party_account_rec.relationship_type_code
            AND active_end_date        < sysdate
            AND ROWNUM                 = 1;
            l_record_found := TRUE ;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      END IF;
   END IF; -- called from group check
   /*          --  Commented by sk for fixing the bug 2232880
         IF CSI_Instance_parties_vld_pvt.Is_Account_Expired
                       (p_party_account_rec) THEN
            IF (p_party_account_rec.ACTIVE_END_DATE = FND_API.G_MISS_DATE ) THEN
                p_party_account_rec.active_end_date := NULL;
             END IF;
  */          -- Commented by sk for fixing the bug 2232880
   -- Unexpire the account
   IF NOT(l_update_record)
   THEN      -- Added for bug 2110790
      IF l_record_found THEN
         -- Added by sk for fixing the bug 2232880
         IF   p_party_account_rec.active_end_date = fnd_api.g_miss_date
         THEN
            p_party_account_rec.active_end_date := NULL;
         END IF;
         -- End additon by sk for fixing the bug 2232880
         update_inst_party_account
                (     p_api_version         => p_api_version
                     ,p_commit              => p_commit
                     ,p_init_msg_list       => p_init_msg_list
                     ,p_validation_level    => p_validation_level
                     ,p_party_account_rec   => p_party_account_rec
                     ,p_txn_rec             => p_txn_rec
                     ,p_oks_txn_inst_tbl    => p_oks_txn_inst_tbl
                     ,x_return_status       => x_return_status
                     ,x_msg_count           => x_msg_count
                     ,x_msg_data            => x_msg_data);

         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            l_msg_index := 1;
            l_msg_count := x_msg_count;
    	    WHILE l_msg_count > 0 LOOP
		        x_msg_data := FND_MSG_PUB.GET(
   	      		    		      l_msg_index,
				              FND_API.G_FALSE 	);
                        csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
		        l_msg_index := l_msg_index + 1;
	                l_msg_count := l_msg_count - 1;
    	    END LOOP;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
        -- END IF; -- commented by sk for fixing the bug 2232880
      ELSE  -- Added by sk for fixing the bug 2232880
         -- Verify if the party account combination exists
         IF p_called_from_grp <> FND_API.G_TRUE THEN
            IF CSI_Instance_parties_vld_pvt.Is_Pty_Acct_Comb_Exists
                          (p_party_account_rec.instance_party_id   ,
                           p_party_account_rec.party_account_id    ,
                           p_party_account_rec.relationship_type_code ) THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF;

         IF  p_party_account_rec.IP_ACCOUNT_ID is  NULL OR
             p_party_account_rec.IP_ACCOUNT_ID = FND_API.G_MISS_NUM THEN
            -- If ip_account_id passed is null then generate from sequence
            -- and check if the value exists . If exists then generate again
            -- from the sequence till we get a value that does not exist
            while l_process_flag loop
               p_party_account_rec.IP_ACCOUNT_ID := CSI_Instance_parties_vld_pvt.gen_ip_account_id;
               IF NOT(CSI_Instance_parties_vld_pvt.Is_IP_account_Exists(p_party_account_rec.IP_ACCOUNT_ID,
                                                                     FALSE            )) THEN
                  l_process_flag := FALSE;
               END IF;
            end loop;
         ELSE
            -- Validate the instance_party_id if exist then raise CSI_API_INVALID_PRIMARY_KEY error
            IF CSI_Instance_parties_vld_pvt.Is_IP_account_Exists(p_party_account_rec.IP_ACCOUNT_ID ,
                                                                 TRUE                 ) THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF;
         -- Verify if the instance_party_id is valid
         -- Check the cache before hitting the Database.
         IF p_called_from_grp <> FND_API.G_TRUE THEN
	    l_exists_flag := 'N';
	    l_valid_flag := 'Y';
	    IF p_inst_party_tbl.count > 0 THEN
	       For tab_row in p_inst_party_tbl.FIRST .. p_inst_party_tbl.LAST
	       LOOP
		  IF p_inst_party_tbl(tab_row).instance_party_id = p_party_account_rec.INSTANCE_PARTY_ID THEN
		     l_valid_flag := p_inst_party_tbl(tab_row).valid_flag;
		     l_exists_flag := 'Y';
		     exit;
		  END IF;
	       END LOOP;
	       --
	       IF l_valid_flag <> 'Y' THEN
		  FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INST_PARTY_ID');
		  FND_MESSAGE.SET_TOKEN('INSTANCE_PARTY_ID',p_party_account_rec.INSTANCE_PARTY_ID);
		  FND_MSG_PUB.Add;
		  RAISE FND_API.G_EXC_ERROR;
	       END IF;
	    END IF;
	    --
	    IF l_exists_flag <> 'Y' THEN
	       p_account_count_rec.inst_party_count := p_account_count_rec.inst_party_count + 1;
	       p_inst_party_tbl(p_account_count_rec.inst_party_count).instance_party_id := p_party_account_rec.INSTANCE_PARTY_ID;
	       IF NOT(CSI_Instance_parties_vld_pvt.Is_Inst_partyID_Valid(
                                                 p_Instance_party_id => p_party_account_rec.INSTANCE_PARTY_ID
                                                ,p_txn_type_id       => p_txn_rec.transaction_type_id
                                                ,p_mode              => 'C' )      -- Added for bug 3550541
                  )
               THEN
	          p_inst_party_tbl(p_account_count_rec.inst_party_count).valid_flag := 'N';
	      -- Message added in the validation routine since additional validation added for bug # 2477417.
		--  FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INST_PARTY_ID');
		--  FND_MESSAGE.SET_TOKEN('INSTANCE_PARTY_ID',p_party_account_rec.INSTANCE_PARTY_ID);
		--  FND_MSG_PUB.Add;
		--  RAISE FND_API.G_EXC_ERROR;
	       ELSE
		  p_inst_party_tbl(p_account_count_rec.inst_party_count).valid_flag := 'Y';
	       END IF;
	    END IF;
         END IF; -- called from group check
         -- Verify Party Account ID is Valid
         IF p_called_from_grp <> FND_API.G_TRUE THEN
            IF NOT(CSI_Instance_parties_vld_pvt.Is_Pty_accountID_Valid
                          (p_party_account_rec.PARTY_ACCOUNT_ID,
                           p_party_account_rec.INSTANCE_PARTY_ID,
                           p_party_account_rec.RELATIONSHIP_TYPE_CODE,
                           p_txn_rec.transaction_type_id, -- Added for bug 3550541
                           'C'))                          -- Added for bug 3550541
            THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF;

         -- Verify the relationship_type_code is valid
         -- Check the cache before hitting the Database.
         l_exists_flag := 'N';
         l_valid_flag := 'Y';
         IF p_acct_rel_type_tbl.count > 0 THEN
            For tab_row in p_acct_rel_type_tbl.FIRST .. p_acct_rel_type_tbl.LAST
            LOOP
              IF p_acct_rel_type_tbl(tab_row).rel_type_code = p_party_account_rec.RELATIONSHIP_TYPE_CODE THEN
                 l_valid_flag := p_acct_rel_type_tbl(tab_row).valid_flag;
                 l_exists_flag := 'Y';
                 exit;
              END IF;
            END LOOP;
            --
            IF l_valid_flag <> 'Y' THEN
	       FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_ACCOUNT_TYPE');
	       FND_MESSAGE.SET_TOKEN('IP_RELATIONSHIP_TYPE_CODE',p_party_account_rec.RELATIONSHIP_TYPE_CODE);
	       FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF;
         IF l_exists_flag <> 'Y' THEN
            p_account_count_rec.rel_type_count := p_account_count_rec.rel_type_count + 1;
            p_acct_rel_type_tbl(p_account_count_rec.rel_type_count).rel_type_code :=
                                                p_party_account_rec.RELATIONSHIP_TYPE_CODE;
            IF NOT(CSI_Instance_parties_vld_pvt.Is_Acct_Rel_type_Valid
                                   (p_party_account_rec.RELATIONSHIP_TYPE_CODE)) THEN
               p_acct_rel_type_tbl(p_account_count_rec.rel_type_count).valid_flag := 'N';
               RAISE FND_API.G_EXC_ERROR;
            ELSE
               p_acct_rel_type_tbl(p_account_count_rec.rel_type_count).valid_flag := 'Y';
            END IF;
         END IF;

          -- If active_start_date is null or G_MISS value then assign sysdate
         IF ((p_party_account_rec.ACTIVE_START_DATE IS NULL ) OR
            ( p_party_account_rec.ACTIVE_START_DATE = FND_API.G_MISS_DATE)) THEN
              p_party_account_rec.ACTIVE_START_DATE := SYSDATE;
         END IF;

         -- verify if the active_start_date is valid
         IF p_called_from_grp <> FND_API.G_TRUE THEN
            IF NOT(CSI_Instance_parties_vld_pvt.Is_Acct_StartDate_Valid
                                            (p_party_account_rec.ACTIVE_START_DATE,
                                             p_party_account_rec.ACTIVE_END_DATE ,
                                             p_party_account_rec.INSTANCE_PARTY_ID  )) THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;

            -- Verify if the active_end_date is valid
            IF ((p_party_account_rec.ACTIVE_END_DATE is NOT NULL) AND
                (p_party_account_rec.ACTIVE_END_DATE <> FND_API.G_MISS_DATE )) THEN
                IF NOT(CSI_Instance_parties_vld_pvt.Is_Acct_EndDate_Valid
                                    (p_party_account_rec.ACTIVE_START_DATE,
                                     p_party_account_rec.ACTIVE_END_DATE ,
                                     p_party_account_rec.INSTANCE_PARTY_ID ,
		      	             p_party_account_rec.IP_ACCOUNT_ID ,
			             p_txn_rec.TRANSACTION_ID))  THEN
                   RAISE FND_API.G_EXC_ERROR;
                END IF;
            END IF;
         END IF; -- Called from group check

       -- Verify if bill to address is correct
         IF ((p_party_account_rec.bill_to_address IS NOT NULL) AND
             (p_party_account_rec.bill_to_address <> FND_API.G_MISS_NUM )) THEN
            -- Check the cache before hitting the Database.
            l_exists_flag := 'N';
            l_valid_flag := 'Y';
            IF p_site_use_tbl.count > 0 THEN
               For tab_row in p_site_use_tbl.FIRST .. p_site_use_tbl.LAST
               LOOP
                  IF p_site_use_tbl(tab_row).site_use_id = p_party_account_rec.bill_to_address AND
                     p_site_use_tbl(tab_row).site_use_code = 'BILL_TO' THEN
                     l_valid_flag := p_site_use_tbl(tab_row).valid_flag;
                     l_exists_flag := 'Y';
                     exit;
                  END IF;
               END LOOP;
               --
               IF l_valid_flag <> 'Y' THEN
                  FND_MESSAGE.SET_NAME('CSI','CSI_INVALID_BILL_TO_ADD_ID');
	          FND_MESSAGE.SET_TOKEN('BILL_TO_ADD_ID',p_party_account_rec.bill_to_address);
	          FND_MSG_PUB.Add;
                  RAISE FND_API.G_EXC_ERROR;
               END IF;
            END IF;
            --
            IF l_exists_flag <> 'Y' THEN
               p_account_count_rec.site_use_count := p_account_count_rec.site_use_count + 1;
               p_site_use_tbl(p_account_count_rec.site_use_count).site_use_id :=
                                                p_party_account_rec.bill_to_address;
               p_site_use_tbl(p_account_count_rec.site_use_count).site_use_code := 'BILL_TO';
               IF NOT(CSI_Instance_parties_vld_pvt.Is_bill_to_add_valid
                   ( p_party_account_rec.bill_to_address)) THEN
                  p_site_use_tbl(p_account_count_rec.site_use_count).valid_flag := 'N';
                  RAISE FND_API.G_EXC_ERROR;
               ELSE
                  p_site_use_tbl(p_account_count_rec.site_use_count).valid_flag := 'Y';
               END IF;
            END IF;
         END IF;

       -- Verify if ship to address is correct
         IF ((p_party_account_rec.ship_to_address IS NOT NULL) AND
             (p_party_account_rec.ship_to_address <> FND_API.G_MISS_NUM )) THEN
            -- Check the cache before hitting the Database.
            l_exists_flag := 'N';
            l_valid_flag := 'Y';
            IF p_site_use_tbl.count > 0 THEN
               For tab_row in p_site_use_tbl.FIRST .. p_site_use_tbl.LAST
               LOOP
                  IF p_site_use_tbl(tab_row).site_use_id = p_party_account_rec.ship_to_address AND
                     p_site_use_tbl(tab_row).site_use_code = 'SHIP_TO' THEN
                     l_valid_flag := p_site_use_tbl(tab_row).valid_flag;
                     l_exists_flag := 'Y';
                     exit;
                  END IF;
               END LOOP;
               --
               IF l_valid_flag <> 'Y' THEN
                  FND_MESSAGE.SET_NAME('CSI','CSI_INVALID_SHIP_TO_ADD_ID');
	          FND_MESSAGE.SET_TOKEN('SHIP_TO_ADD_ID',p_party_account_rec.ship_to_address);
	          FND_MSG_PUB.Add;
                  RAISE FND_API.G_EXC_ERROR;
               END IF;
            END IF;
            --
            IF l_exists_flag <> 'Y' THEN
               p_account_count_rec.site_use_count := p_account_count_rec.site_use_count + 1;
               p_site_use_tbl(p_account_count_rec.site_use_count).site_use_id :=
                                                p_party_account_rec.ship_to_address;
               p_site_use_tbl(p_account_count_rec.site_use_count).site_use_code := 'SHIP_TO';
               IF NOT(CSI_Instance_parties_vld_pvt.Is_ship_to_add_valid
                  ( p_party_account_rec.ship_to_address)) THEN
                  p_site_use_tbl(p_account_count_rec.site_use_count).valid_flag := 'N';
                  RAISE FND_API.G_EXC_ERROR;
               ELSE
                  p_site_use_tbl(p_account_count_rec.site_use_count).valid_flag := 'Y';
               END IF;
            END IF;
         END IF;

       -- Following will not be done when called from Group API.
       -- Verify if it meets Account Rules
       IF p_called_from_grp <> FND_API.G_TRUE THEN

          IF CSI_Instance_parties_vld_pvt.Acct_Rules_Check
                          (p_party_account_rec.instance_party_id   ,
                           p_party_account_rec.relationship_type_code ) THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

          -- Get the parent party record
          IF NOT(CSI_Instance_parties_vld_pvt.Get_Party_Record
                  ( p_party_account_rec.instance_party_id,
                    l_party_rec)) THEN
                 RAISE FND_API.G_EXC_ERROR;
           END IF;

          -- If it is an owner party and owner account then update csi_item_instances
          -- Account Rules check ensures that if the owner account is
          -- being created, the parent party is always a owner party
           IF ((p_party_account_rec.RELATIONSHIP_TYPE_CODE = 'OWNER')
               AND (l_party_rec.RELATIONSHIP_TYPE_CODE = 'OWNER')) THEN

                update csi_item_instances
                set   owner_party_account_id = p_party_account_rec.party_account_id
                where instance_id     = l_party_rec.instance_id;
           END IF;

        -- Call table handlers to insert into csi_ip_accounts table
        CSI_IP_ACCOUNTS_PKG.Insert_Row(
          px_IP_ACCOUNT_ID      => p_party_account_rec.ip_account_id,
          p_INSTANCE_PARTY_ID   => p_party_account_rec.INSTANCE_PARTY_ID,
          p_PARTY_ACCOUNT_ID    => p_party_account_rec.PARTY_ACCOUNT_ID,
          p_RELATIONSHIP_TYPE_CODE => p_party_account_rec.RELATIONSHIP_TYPE_CODE,
          p_ACTIVE_START_DATE   => p_party_account_rec.ACTIVE_START_DATE,
          p_ACTIVE_END_DATE     => p_party_account_rec.ACTIVE_END_DATE,
          p_CONTEXT             => p_party_account_rec.CONTEXT,
          p_ATTRIBUTE1          => p_party_account_rec.ATTRIBUTE1,
          p_ATTRIBUTE2          => p_party_account_rec.ATTRIBUTE2,
          p_ATTRIBUTE3          => p_party_account_rec.ATTRIBUTE3,
          p_ATTRIBUTE4          => p_party_account_rec.ATTRIBUTE4,
          p_ATTRIBUTE5          => p_party_account_rec.ATTRIBUTE5,
          p_ATTRIBUTE6          => p_party_account_rec.ATTRIBUTE6,
          p_ATTRIBUTE7          => p_party_account_rec.ATTRIBUTE7,
          p_ATTRIBUTE8          => p_party_account_rec.ATTRIBUTE8,
          p_ATTRIBUTE9          => p_party_account_rec.ATTRIBUTE9,
          p_ATTRIBUTE10         => p_party_account_rec.ATTRIBUTE10,
          p_ATTRIBUTE11         => p_party_account_rec.ATTRIBUTE11,
          p_ATTRIBUTE12         => p_party_account_rec.ATTRIBUTE12,
          p_ATTRIBUTE13         => p_party_account_rec.ATTRIBUTE13,
          p_ATTRIBUTE14         => p_party_account_rec.ATTRIBUTE14,
          p_ATTRIBUTE15         => p_party_account_rec.ATTRIBUTE15,
          p_CREATED_BY          => FND_GLOBAL.USER_ID             ,
          p_CREATION_DATE       => SYSDATE                        ,
          p_LAST_UPDATED_BY     => FND_GLOBAL.USER_ID             ,
          p_LAST_UPDATE_DATE    => SYSDATE                        ,
          p_LAST_UPDATE_LOGIN   => FND_GLOBAL.LOGIN_ID            ,
          p_OBJECT_VERSION_NUMBER  => 1                           ,
          p_BILL_TO_ADDRESS     => p_party_account_rec.BILL_TO_ADDRESS,
          p_SHIP_TO_ADDRESS     => p_party_account_rec.SHIP_TO_ADDRESS,
          p_REQUEST_ID          => p_party_account_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID => p_party_account_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID          => p_party_account_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE => p_party_account_rec.PROGRAM_UPDATE_DATE
          );

        -- Call create_transaction to create txn log
        CSI_TRANSACTIONS_PVT.Create_transaction
          (
             p_api_version            => p_api_version
            ,p_commit                 => p_commit
            ,p_init_msg_list          => p_init_msg_list
            ,p_validation_level       => p_validation_level
            ,p_Success_If_Exists_Flag => 'Y'
            ,P_transaction_rec       => p_txn_rec
            ,x_return_status          => x_return_status
            ,x_msg_count              => x_msg_count
            ,x_msg_data               => x_msg_data          );


         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	         l_msg_index := 1;
                 l_msg_count := x_msg_count;
   	         WHILE l_msg_count > 0 LOOP
     		       x_msg_data := FND_MSG_PUB.GET(
    	         		                l_msg_index,
	     	     		                FND_API.G_FALSE	);
	               csi_gen_utility_pvt.put_line( 'message data = '||x_msg_data);
	    	       l_msg_index := l_msg_index + 1;
		           l_msg_count := l_msg_count - 1;
	          END LOOP;
                  RAISE FND_API.G_EXC_ERROR;
         END IF;

         -- Generate a unique instance_party_history_id from the sequence
         l_ip_account_history_id := CSI_Instance_parties_vld_pvt.gen_ip_account_hist_id;

         CSI_IP_ACCOUNTS_H_PKG.Insert_Row
         (
          px_IP_ACCOUNT_HISTORY_ID        => l_ip_account_history_id          ,
          p_IP_ACCOUNT_ID                 => p_party_account_rec.ip_account_id,
          p_TRANSACTION_ID                => p_txn_rec.transaction_id        ,
          p_OLD_PARTY_ACCOUNT_ID          => NULL                            ,
          p_NEW_PARTY_ACCOUNT_ID          => p_party_account_rec.PARTY_ACCOUNT_ID,
          p_OLD_RELATIONSHIP_TYPE_CODE    => NULL                            ,
          p_NEW_RELATIONSHIP_TYPE_CODE    => p_party_account_rec.RELATIONSHIP_TYPE_CODE,
          p_OLD_ACTIVE_START_DATE         => NULL                           ,
          p_NEW_ACTIVE_START_DATE         => p_party_account_rec.ACTIVE_START_DATE,
          p_OLD_ACTIVE_END_DATE           => NULL                           ,
          p_NEW_ACTIVE_END_DATE           => p_party_account_rec.ACTIVE_END_DATE,
          p_OLD_CONTEXT                   => NULL                           ,
          p_NEW_CONTEXT                   => p_party_account_rec.CONTEXT    ,
          p_OLD_ATTRIBUTE1                => NULL                           ,
          p_NEW_ATTRIBUTE1                => p_party_account_rec.ATTRIBUTE1 ,
          p_OLD_ATTRIBUTE2                => NULL                           ,
          p_NEW_ATTRIBUTE2                => p_party_account_rec.ATTRIBUTE2 ,
          p_OLD_ATTRIBUTE3                => NULL                           ,
          p_NEW_ATTRIBUTE3                => p_party_account_rec.ATTRIBUTE3 ,
          p_OLD_ATTRIBUTE4                => NULL                           ,
          p_NEW_ATTRIBUTE4                => p_party_account_rec.ATTRIBUTE4 ,
          p_OLD_ATTRIBUTE5                => NULL                           ,
          p_NEW_ATTRIBUTE5                => p_party_account_rec.ATTRIBUTE5 ,
          p_OLD_ATTRIBUTE6                => NULL                           ,
          p_NEW_ATTRIBUTE6                => p_party_account_rec.ATTRIBUTE6 ,
          p_OLD_ATTRIBUTE7                => NULL                           ,
          p_NEW_ATTRIBUTE7                => p_party_account_rec.ATTRIBUTE7 ,
          p_OLD_ATTRIBUTE8                => NULL                           ,
          p_NEW_ATTRIBUTE8                => p_party_account_rec.ATTRIBUTE8 ,
          p_OLD_ATTRIBUTE9                => NULL                           ,
          p_NEW_ATTRIBUTE9                => p_party_account_rec.ATTRIBUTE9 ,
          p_OLD_ATTRIBUTE10               => NULL                           ,
          p_NEW_ATTRIBUTE10               => p_party_account_rec.ATTRIBUTE10,
          p_OLD_ATTRIBUTE11               => NULL                           ,
          p_NEW_ATTRIBUTE11               => p_party_account_rec.ATTRIBUTE11,
          p_OLD_ATTRIBUTE12               => NULL                           ,
          p_NEW_ATTRIBUTE12               => p_party_account_rec.ATTRIBUTE12,
          p_OLD_ATTRIBUTE13               => NULL                           ,
          p_NEW_ATTRIBUTE13               => p_party_account_rec.ATTRIBUTE13,
          p_OLD_ATTRIBUTE14               => NULL                           ,
          p_NEW_ATTRIBUTE14               => p_party_account_rec.ATTRIBUTE14,
          p_OLD_ATTRIBUTE15               => NULL                           ,
          p_NEW_ATTRIBUTE15               => p_party_account_rec.ATTRIBUTE15,
          p_FULL_DUMP_FLAG                => 'N'                            ,
          p_CREATED_BY                    => FND_GLOBAL.USER_ID             ,
          p_CREATION_DATE                 => SYSDATE                        ,
          p_LAST_UPDATED_BY               => FND_GLOBAL.USER_ID             ,
          p_LAST_UPDATE_DATE              => SYSDATE                        ,
          p_LAST_UPDATE_LOGIN             => FND_GLOBAL.LOGIN_ID            ,
          p_OBJECT_VERSION_NUMBER         => 1                              ,
          p_OLD_BILL_TO_ADDRESS           => NULL                           ,
          p_NEW_BILL_TO_ADDRESS           => p_party_account_rec.BILL_TO_ADDRESS,
          p_OLD_SHIP_TO_ADDRESS           => NULL                           ,
          p_NEW_SHIP_TO_ADDRESS           => p_party_account_rec.SHIP_TO_ADDRESS,
          p_OLD_INSTANCE_PARTY_ID         => NULL                           ,
          p_NEW_INSTANCE_PARTY_ID         => p_party_account_rec.INSTANCE_PARTY_ID);

       END IF; -- p_called_from_grp check
       -- Call Contracts
       -- End commentation by sguthiva for bug 2307804
       -- Added by sguthiva for bug 2307804
       IF (    (p_party_account_rec.call_contracts <> fnd_api.g_false)
             AND (p_party_account_rec.relationship_type_code = 'OWNER' )
          )
       THEN
          -- The following code has been written to make sure
          -- before calling contracts we pass a valid vld_organization_id
          IF p_party_account_rec.vld_organization_id IS NULL OR
             p_party_account_rec.vld_organization_id = fnd_api.g_miss_num
          THEN
             BEGIN
                SELECT last_vld_organization_id
                INTO   l_last_vld_org
                FROM   csi_item_instances
                WHERE  instance_id = l_party_rec.instance_id;
             EXCEPTION
                WHEN OTHERS THEN
                   NULL;
             END;
          ELSE
             l_last_vld_org := p_party_account_rec.vld_organization_id;
          END IF;
          --
          IF p_txn_rec.transaction_type_id <> 7   -- Added for bug 3973706
          THEN
             csi_item_instance_pvt.Call_to_Contracts(
                              p_transaction_type   =>   'NEW'
                             ,p_instance_id        =>   l_party_rec.instance_id
                             ,p_new_instance_id    =>   NULL
                             ,p_vld_org_id         =>   l_last_vld_org
                             ,p_quantity           =>   NULL
                             ,p_party_account_id1  =>   NULL         -- old party account id
                             ,p_party_account_id2  =>   NULL         -- new party account id
                             ,p_transaction_date   =>   p_txn_rec.transaction_date -- SYSDATE
                             ,p_source_transaction_date   =>   p_txn_rec.source_transaction_date
                             ,p_grp_call_contracts =>   p_party_account_rec.grp_call_contracts -- srramakr
                             ,p_oks_txn_inst_tbl   =>   p_oks_txn_inst_tbl
                             ,x_return_status      =>   x_return_status
                             ,x_msg_count          =>   x_msg_count
                             ,x_msg_data           =>   x_msg_data
                              );

             IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS)
             THEN
                l_msg_index := 1;
                l_msg_count := x_msg_count;
                WHILE l_msg_count > 0 LOOP
                   x_msg_data := FND_MSG_PUB.GET(
                                                 l_msg_index,
                                                 FND_API.G_FALSE   );
                   csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
                   l_msg_index := l_msg_index + 1;
                   l_msg_count := l_msg_count - 1;
                END LOOP;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
          END IF; -- Added for bug 3973706
       END IF;
    END IF; -- Added by sk for fixing the bug 2232880
  END IF; -- Added by sk for bug 2110790
        -- End addition by sguthiva for bug 2307804
        --
        -- End of API body
        -- Standard check of p_commit.

        IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
        END IF;


        -- Standard call to get message count and if count is  get message info.
        FND_MSG_PUB.Count_And_Get
                (p_count        =>      x_msg_count ,
                 p_data         =>      x_msg_data  );
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO create_inst_party_acct_pvt;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get
                (       p_count      =>      x_msg_count,
                        p_data       =>      x_msg_data  );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
               ROLLBACK TO create_inst_party_acct_pvt;
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count   =>      x_msg_count,
                        p_data    =>      x_msg_data  );
        WHEN OTHERS THEN
                ROLLBACK TO create_inst_party_acct_pvt;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF FND_MSG_PUB.Check_Msg_Level
                     (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                   FND_MSG_PUB.Add_Exc_Msg
                    ( g_pkg_name, l_api_name );
                END IF;
               FND_MSG_PUB.Count_And_Get
                (       p_count     =>      x_msg_count,
                        p_data      =>      x_msg_data );

END create_inst_party_account;

/*-----------------------------------------------------------*/
/* Procedure name:  Update_inst_party_account                */
/* Description :  Procedure used to update the existing      */
/*                instance-party account relationships       */
/*-----------------------------------------------------------*/

PROCEDURE update_inst_party_account
 (    p_api_version                 IN  NUMBER
     ,p_commit                      IN  VARCHAR2
     ,p_init_msg_list               IN  VARCHAR2
     ,p_validation_level            IN  NUMBER
     ,p_party_account_rec           IN  csi_datastructures_pub.party_account_rec
     ,p_txn_rec                     IN  OUT NOCOPY  csi_datastructures_pub.transaction_rec
     ,p_oks_txn_inst_tbl            IN OUT NOCOPY   oks_ibint_pub.txn_instance_tbl
     ,x_return_status               OUT NOCOPY  VARCHAR2
     ,x_msg_count                   OUT NOCOPY  NUMBER
     ,x_msg_data                    OUT NOCOPY  VARCHAR2
    ) IS

      l_api_name      CONSTANT VARCHAR2(30)   := 'UPDATE_INST_PARTY_ACCOUNT';
      l_api_version   CONSTANT NUMBER         := 1.0;
      l_csi_debug_level        NUMBER;
--       l_curr_party_acct_rec    csi_datastructures_pub.party_account_rec;
      l_temp_party_account_rec csi_datastructures_pub.party_account_rec;
      l_party_rec              csi_datastructures_pub.party_rec;
      l_msg_index              NUMBER;
      l_msg_count              NUMBER;
      l_mod_value              NUMBER;
      l_object_version_number  NUMBER;
      l_ip_account_history_id  NUMBER;
      l_full_dump_frequency    NUMBER;
      x_msg_index_out          NUMBER;

      -- Alternate PK variables
      l_alt_pk_inst_pty_id     NUMBER;
      l_alt_pk_pty_acct_id     NUMBER;
      l_alt_pk_rel_type_code   VARCHAR2(30);

      l_party_relation                VARCHAR2(30);
      l_transaction_type              VARCHAR2(10);
      l_old_oks_cp_rec                oks_ibint_pub.cp_rec_type;
      l_new_oks_cp_rec                oks_ibint_pub.cp_rec_type;
      l_contracts_status              VARCHAR2(3);
      l_internal_party_id             NUMBER;
      l_party_id                      NUMBER;
      l_old_party_id                  NUMBER;
      l_new_party_id                  NUMBER;
    CURSOR instance_csr (p_ins_id IN NUMBER) IS
      SELECT  *
      FROM    csi_item_instances
      WHERE   instance_id = p_ins_id;
    l_instance_csr    instance_csr%ROWTYPE;

  CURSOR get_curr_party_acct_rec (p_ip_account_id   IN  NUMBER) IS
   SELECT
     ip_account_id                    ,
     FND_API.G_MISS_NUM parent_tbl_index,
     instance_party_id                ,
     party_account_id                 ,
     relationship_type_code           ,
     bill_to_address                  ,
     ship_to_address                  ,
     active_start_date                ,
     active_end_date                  ,
     context                          ,
     attribute1                       ,
     attribute2                       ,
     attribute3                       ,
     attribute4                       ,
     attribute5                       ,
     attribute6                       ,
     attribute7                       ,
     attribute8                       ,
     attribute9                       ,
     attribute10                      ,
     attribute11                      ,
     attribute12                      ,
     attribute13                      ,
     attribute14                      ,
     attribute15                      ,
     object_version_number
    FROM CSI_IP_ACCOUNTS
   WHERE IP_ACCOUNT_ID = p_ip_account_id
   FOR UPDATE OF OBJECT_VERSION_NUMBER;
    --AND (( ACTIVE_END_DATE IS NULL) OR (ACTIVE_END_DATE >= SYSDATE));

  l_curr_party_acct_rec    get_curr_party_acct_rec%ROWTYPE;


  CURSOR pty_acct_csr (p_act_hist_id NUMBER) IS
  SELECT  ip_account_history_id
         ,ip_account_id
         ,transaction_id
         ,old_party_account_id
         ,new_party_account_id
         ,old_relationship_type_code
         ,new_relationship_type_code
         ,old_active_start_date
         ,new_active_start_date
         ,old_active_end_date
         ,new_active_end_date
         ,old_context
         ,new_context
         ,old_attribute1
         ,new_attribute1
         ,old_attribute2
         ,new_attribute2
         ,old_attribute3
         ,new_attribute3
         ,old_attribute4
         ,new_attribute4
         ,old_attribute5
         ,new_attribute5
         ,old_attribute6
         ,new_attribute6
         ,old_attribute7
         ,new_attribute7
         ,old_attribute8
         ,new_attribute8
         ,old_attribute9
         ,new_attribute9
         ,old_attribute10
         ,new_attribute10
         ,old_attribute11
         ,new_attribute11
         ,old_attribute12
         ,new_attribute12
         ,old_attribute13
         ,new_attribute13
         ,old_attribute14
         ,new_attribute14
         ,old_attribute15
         ,new_attribute15
         ,object_version_number
         ,old_bill_to_address
         ,new_bill_to_address
         ,old_ship_to_address
         ,new_ship_to_address
         ,full_dump_flag
         ,old_instance_party_id
         ,new_instance_party_id
  FROM   csi_ip_accounts_h
  WHERE  csi_ip_accounts_h.ip_account_history_id = p_act_hist_id
  FOR UPDATE OF object_version_number ;
  l_pty_acct_csr         pty_acct_csr%ROWTYPE;
  l_ip_acct_hist_id      NUMBER;
  l_old_pty_acct_id      NUMBER; -- Added by sguthiva for bug 2307804
  l_new_pty_acct_id      NUMBER; -- Added by sguthiva for bug 2307804
  l_last_vld_org         NUMBER; -- Added by sguthiva for bug 2307804
  l_party_account_id     NUMBER; -- Added by sguthiva for bug 2307804
  l_account_hist_rec     csi_datastructures_pub.account_history_rec;
  l_rel_type_code        VARCHAR2(30);
  l_acct_end_date        DATE;
  l_temp_acct_date       DATE;
  l_found_for_update     VARCHAR2(1):='N';
  l_dummy                VARCHAR2(1);
  l_instance_party_id    NUMBER;
BEGIN
        -- Standard Start of API savepoint
        -- SAVEPOINT  update_inst_party_acct_pvt;


        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (    l_api_version           ,
                                                p_api_version           ,
                                                l_api_name              ,
                                                g_pkg_name              )
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Check the profile option CSI_DEBUG_LEVEL for debug message reporting
        l_csi_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

        -- If CSI_DEBUG_LEVEL = 1 then dump the procedure name
        IF (l_csi_debug_level > 0) THEN
            csi_gen_utility_pvt.put_line( 'update_inst_party_account');
        END IF;

        -- If the debug level = 2 then dump all the parameters values.
        IF (l_csi_debug_level > 1) THEN
                csi_gen_utility_pvt.put_line( 'update_inst_party_account '||'-'||
                                                p_api_version           ||'-'||
                                                p_commit                ||'-'||
                                                p_init_msg_list               );
            -- Dump the records in the log file
            csi_gen_utility_pvt.dump_party_account_rec(p_party_account_rec);
            csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
        END IF;

        -- Start API body
        --
        -- Check if all the required parameters are passed
    	 CSI_Instance_parties_vld_pvt.Check_Reqd_Param_num
 	      (    p_party_account_rec.ip_account_id ,
		    '  p_party_account_rec.IP_ACCOUNT_ID ',
		       l_api_name                 );
        --
        IF p_party_account_rec.party_account_id IS NULL THEN
           FND_MESSAGE.SET_NAME('CSI','CSI_API_MANDATORY_ACCOUNT');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        --
    	-- Check if the instance party id  is valid
      -- Commented by sk for bug 2232880
      -- End of commentation by sk for bug 2232880

        -- check if the object_version_number passed matches with the one
        -- in the database else raise error
        OPEN get_curr_party_acct_rec(p_party_account_rec.IP_ACCOUNT_ID);
        FETCH get_curr_party_acct_rec INTO l_curr_party_acct_rec;
        IF  (l_curr_party_acct_rec.object_version_number <> p_party_account_rec.OBJECT_VERSION_NUMBER) THEN
            FND_MESSAGE.Set_Name('CSI', 'CSI_API_OBJ_VER_MISMATCH');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF get_curr_party_acct_rec%NOTFOUND THEN
          FND_MESSAGE.Set_Name('CSI', 'CSI_API_RECORD_LOCKED');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE get_curr_party_acct_rec;

        -- Added by sguthiva for bug 2307804
        IF l_curr_party_acct_rec.active_end_date IS NULL OR
           l_curr_party_acct_rec.active_end_date > SYSDATE
        THEN
             l_old_pty_acct_id :=l_curr_party_acct_rec.party_account_id;-- added 18apr
        ELSE
             l_old_pty_acct_id := NULL;
        END IF;
        -- End addition by sguthiva for bug 2307804

        IF p_party_account_rec.INSTANCE_PARTY_ID <> FND_API.G_MISS_NUM THEN
    	    -- Check if the instance party id  is valid
            IF NOT(CSI_Instance_parties_vld_pvt.Is_Inst_partyID_Valid
                                     (p_Instance_party_id => p_party_account_rec.INSTANCE_PARTY_ID
                                     ,p_txn_type_id       => p_txn_rec.transaction_type_id
                                     ,p_mode              => 'U'      -- Added for bug 3550541
                                      )
                   )
            THEN
            -- Message added in the validation routine since additional validation added for bug # 2477417.
	           --  FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INST_PARTY_ID');
	           --  FND_MESSAGE.SET_TOKEN('INSTANCE_PARTY_ID',p_party_account_rec.INSTANCE_PARTY_ID);
	           --  FND_MSG_PUB.Add;
                     RAISE FND_API.G_EXC_ERROR;
            END IF;
            IF p_party_account_rec.INSTANCE_PARTY_ID  <> l_curr_party_acct_rec.INSTANCE_PARTY_ID THEN
            -- Start addition
               IF p_txn_rec.transaction_type_id <> 7
               THEN
                  FND_MESSAGE.Set_Name('CSI', 'CSI_API_UPD_NOT_ALLOWED');
                  FND_MESSAGE.Set_Token('COLUMN', 'INSTANCE_PARTY_ID');
                  FND_MSG_PUB.ADD;
                  RAISE FND_API.G_EXC_ERROR;
               ELSE
                  BEGIN
                     SELECT relationship_type_code
                     INTO   l_rel_type_code
                     FROM   csi_i_parties
                     WHERE  instance_party_id=l_curr_party_acct_rec.instance_party_id;

                     IF (l_rel_type_code='OWNER' AND
                         l_curr_party_acct_rec.relationship_type_code='OWNER' )/* OR
                        (l_curr_party_acct_rec.active_end_date IS NOT NULL AND
                         l_curr_party_acct_rec.active_end_date < SYSDATE AND
                         (p_party_account_rec.active_end_date = fnd_api.g_miss_date OR
                          p_party_account_rec.active_end_date < SYSDATE )) */
                    -- Commented the above code for bug 3539990 (reported in 11.5.9)
                     THEN
                         FND_MESSAGE.Set_Name('CSI', 'CSI_API_UPD_NOT_ALLOWED');
                         FND_MESSAGE.Set_Token('COLUMN', 'INSTANCE_PARTY_ID');
                         FND_MSG_PUB.ADD;
                         RAISE FND_API.G_EXC_ERROR;
                     END IF;
                  EXCEPTION
                     WHEN FND_API.G_EXC_ERROR THEN
                          RAISE FND_API.G_EXC_ERROR;
                  END;

               END IF;
               -- End addition
            END IF;
        ELSE
           -- srramakr Updates not allowed for Expired instance. Bug # 2477417
           IF NOT(CSI_Instance_parties_vld_pvt.Is_Inst_partyID_Valid
                                     (p_Instance_party_id => l_curr_party_acct_rec.INSTANCE_PARTY_ID
                                     ,p_txn_type_id       => p_txn_rec.transaction_type_id
                                     ,p_mode              => 'U'      -- Added for bug 3550541
                                      )
                  )
           THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF;
        l_party_relation := CSI_Instance_parties_vld_pvt.Get_Party_relation
                         (l_curr_party_acct_rec.Instance_party_id);
        --
        IF p_party_account_rec.active_start_date IS NULL THEN
           FND_MESSAGE.Set_Name('CSI', 'CSI_API_UPD_NOT_ALLOWED');
           FND_MESSAGE.Set_Token('COLUMN', 'ACTIVE_START_DATE');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        --
        IF p_party_account_rec.active_start_date <> FND_API.G_MISS_DATE THEN
             IF p_party_account_rec.active_start_date <> l_curr_party_acct_rec.active_start_date THEN
                FND_MESSAGE.Set_Name('CSI', 'CSI_API_UPD_NOT_ALLOWED');
                FND_MESSAGE.Set_Token('COLUMN', 'ACTIVE_START_DATE');
                FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
             END IF;
        END IF;

        -- Verify if the active_end_date is valid
        -- Don't allow expiry of owner accounts
        IF  ( p_party_account_rec.ACTIVE_END_DATE <> FND_API.G_MISS_DATE) THEN
           IF ((l_curr_party_acct_rec.relationship_type_code = 'OWNER')
              AND (l_party_relation = 'OWNER')) THEN
              -- Added by sguthiva for bug 2307804
                 IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
                     csi_gen_utility_pvt.populate_install_param_rec;
                  END IF;
                  --
                  l_internal_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;
                  --
                  IF l_internal_party_id IS NULL THEN
                     FND_MESSAGE.SET_NAME('CSI','CSI_API_UNINSTALLED_PARAMETER');
                     FND_MSG_PUB.ADD;
                     RAISE FND_API.G_EXC_ERROR;
                  END IF;
                  --
              -- End addition by sguthiva for bug 2307804
                IF p_party_account_rec.expire_flag = fnd_api.g_false -- Added by sguthiva for bug 2307804
               -- IF csi_party_relationships_pvt.g_force_expire_flag   = 'N' -- Commented by sguthiva for bug 2307804
                THEN
                   FND_MESSAGE.Set_Name('CSI', 'CSI_API_EXP_NOT_ALLOWED');
                   FND_MESSAGE.Set_Token('COLUMN', 'OWNER ACCOUNT');
                   FND_MSG_PUB.ADD;
                   RAISE FND_API.G_EXC_ERROR;
                END IF;
           ELSE

            -- Verify if the active_end_date is valid
             IF p_party_account_rec.expire_flag = fnd_api.g_false  THEN    -- Added by sguthiva for bug 2307804
           -- IF (g_expire_account_flag <> 'Y') THEN                       -- Commented by sguthiva for bug 2307804
               IF NOT(CSI_Instance_parties_vld_pvt.Is_Acct_EndDate_Valid
                                 (l_curr_party_acct_rec.ACTIVE_START_DATE,
                                  p_party_account_rec.ACTIVE_END_DATE ,
                                  p_party_account_rec.INSTANCE_PARTY_ID ,
			          p_party_account_rec.IP_ACCOUNT_ID ,
			          p_txn_rec.TRANSACTION_ID))  THEN
                  RAISE FND_API.G_EXC_ERROR;
               END IF;


               -- Added following code for bug 3855525.
               IF p_party_account_rec.ACTIVE_END_DATE IS NOT NULL AND
                  p_party_account_rec.ACTIVE_END_DATE <> FND_API.G_MISS_DATE AND                  l_curr_party_acct_rec.ACTIVE_START_DATE IS NOT NULL AND
                  l_curr_party_acct_rec.ACTIVE_START_DATE <> FND_API.G_MISS_DATE AND
                  p_party_account_rec.ACTIVE_END_DATE < l_curr_party_acct_rec.ACTIVE_START_DATE
               THEN
                   FND_MESSAGE.Set_Name('CSI', 'CSI_ENDDT_GT_STDT');

                   FND_MESSAGE.Set_Token('END_DATE',p_party_account_rec.ACTIVE_END_DATE);
                   FND_MESSAGE.Set_Token('START_DATE',l_curr_party_acct_rec.ACTIVE_START_DATE);
                   FND_MSG_PUB.ADD;
                   RAISE FND_API.G_EXC_ERROR;
               END IF;
               -- End code addition for bug 3855525.

             END IF;
           END IF;
        END IF;


        -- Verify the relationship_type_code is valid
        -- Don't allow change of owner accounts
        IF p_party_account_rec.relationship_type_code <> FND_API.G_MISS_CHAR THEN
           IF ((p_party_account_rec.relationship_type_code <> l_curr_party_acct_rec.relationship_type_code)
              AND (l_curr_party_acct_rec.relationship_type_code = 'OWNER')
              AND (l_party_relation = 'OWNER')) THEN
                FND_MESSAGE.Set_Name('CSI', 'CSI_API_UPD_NOT_ALLOWED');
                FND_MESSAGE.Set_Token('COLUMN', 'OWNER ACCOUNT');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
           ELSE
               -- Verify the relationship_type_code is valid
              IF NOT(CSI_Instance_parties_vld_pvt.Is_Acct_Rel_type_Valid
                                (p_party_account_rec.RELATIONSHIP_TYPE_CODE)) THEN
                 RAISE FND_API.G_EXC_ERROR;
              END IF;
           END IF;
        END IF;

  -- Need to add the following as account/party merge transaction
  -- is allowed to change the instance_party_id.
    IF p_txn_rec.transaction_type_id=7 AND
      (p_party_account_rec.instance_party_id IS NOT NULL AND
       p_party_account_rec.instance_party_id <> fnd_api.g_miss_num)
    THEN
      l_instance_party_id := p_party_account_rec.instance_party_id;
    ELSE
      l_instance_party_id := l_curr_party_acct_rec.INSTANCE_PARTY_ID;
    END IF;

        -- verify if party_account_id  is valid
        IF p_party_account_rec.PARTY_ACCOUNT_ID <> FND_API.G_MISS_NUM THEN
         -- Added the following condition for bug 3830149 (rel 11.5.9)
         IF (p_party_account_rec.ACTIVE_END_DATE IS NULL OR
             p_party_account_rec.ACTIVE_END_DATE = FND_API.G_MISS_DATE)
             OR
            (p_party_account_rec.ACTIVE_END_DATE IS NOT NULL AND
             p_party_account_rec.ACTIVE_END_DATE <> FND_API.G_MISS_DATE AND
             p_party_account_rec.ACTIVE_END_DATE > SYSDATE)
         THEN
          IF NOT(CSI_Instance_parties_vld_pvt.Is_Pty_accountID_Valid
                       (p_party_account_rec.PARTY_ACCOUNT_ID,
                        l_instance_party_id, --l_curr_party_acct_rec.INSTANCE_PARTY_ID,
                        p_party_account_rec.RELATIONSHIP_TYPE_CODE,
                        p_txn_rec.transaction_type_id, -- Added for bug 3550541
                        'U'                            -- Added for bug 3550541
                        )
                 )
          THEN
               RAISE FND_API.G_EXC_ERROR;
          END IF;
         ELSE
           -- Since party_account_id validation is not required during expiration of accounts
           -- ,Hence we added the above filter condition.
           -- Refer bug 3830149 for more explaination.
           NULL;
         END IF;
        END IF;

       -- Verify if bill to address is correct
        IF p_party_account_rec.bill_to_address <> FND_API.G_MISS_NUM THEN
           IF NOT(CSI_Instance_parties_vld_pvt.Is_bill_to_add_valid
               ( p_party_account_rec.bill_to_address)) THEN
               RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF;


       -- Verify if ship to address is correct
        IF p_party_account_rec.ship_to_address <> FND_API.G_MISS_NUM THEN
            IF NOT(CSI_Instance_parties_vld_pvt.Is_ship_to_add_valid
               ( p_party_account_rec.ship_to_address)) THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        END IF;

       -- Validate alternate primary key
       -- Verify if the party account combination exists
       IF  ((p_party_account_rec.instance_party_id   IS NULL) OR
            (p_party_account_rec.instance_party_id = FND_API.G_MISS_NUM)) THEN
          l_alt_pk_inst_pty_id := l_curr_party_acct_rec.instance_party_id;
       ELSE
          l_alt_pk_inst_pty_id := p_party_account_rec.instance_party_id;
       END IF;

       IF ((p_party_account_rec.party_account_id IS NULL) OR
            (p_party_account_rec.party_account_id = FND_API.G_MISS_NUM)) THEN
            l_alt_pk_pty_acct_id :=   l_curr_party_acct_rec.party_account_id;
       ELSE
            l_alt_pk_pty_acct_id :=   p_party_account_rec.party_account_id;
       END IF;

       IF ((p_party_account_rec.relationship_type_code IS NULL) OR
            (p_party_account_rec.relationship_type_code = FND_API.G_MISS_CHAR)) THEN
            l_alt_pk_rel_type_code := l_curr_party_acct_rec.relationship_type_code;
       ELSE
            l_alt_pk_rel_type_code := p_party_account_rec.relationship_type_code;
       END IF;

        IF  ((l_alt_pk_inst_pty_id <> l_curr_party_acct_rec.instance_party_id)
            OR
            (l_alt_pk_pty_acct_id <> l_curr_party_acct_rec.party_account_id)
            OR
            (l_alt_pk_rel_type_code <> l_curr_party_acct_rec.relationship_type_code))
        THEN
             -- Verify if the party account combination exists
           IF p_txn_rec.transaction_type_id=7
           THEN
           l_found_for_update:='T';
             BEGIN
              SELECT 'x'
                INTO l_dummy
                FROM csi_ip_accounts
               WHERE instance_party_id      = l_alt_pk_inst_pty_id
                 AND party_account_id       = l_alt_pk_pty_acct_id
                 AND relationship_type_code = l_alt_pk_rel_type_code
                 AND ((active_end_date IS NULL) OR (active_end_date >= sysdate))
                 AND ROWNUM=1;

             -- If found then there exists a record in csi_i_parties, Hence
            -- I need to expire(if active) this record.
               BEGIN
                  SELECT active_end_date
                    INTO l_temp_acct_date
                    FROM csi_ip_accounts
                   WHERE ip_account_id=p_party_account_rec.ip_account_id
                     AND ((active_end_date IS NULL) OR (active_end_date > sysdate));
                   -- Active record found so make it inactive.
                       l_temp_acct_date:=sysdate;
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                   -- Means the record is already in inactive state.
                      l_temp_acct_date := p_party_account_rec.active_end_date;
               END;

             EXCEPTION
               WHEN OTHERS THEN
               -- No changes are needed.
                  l_temp_acct_date := p_party_account_rec.active_end_date;
             END;

           ELSE
             IF CSI_Instance_parties_vld_pvt.Is_Pty_Acct_Comb_Exists
                            (l_alt_pk_inst_pty_id ,
                             l_alt_pk_pty_acct_id ,
                             l_alt_pk_rel_type_code ) THEN
                    RAISE FND_API.G_EXC_ERROR;
             END IF;
           END IF;
         END IF;

       -- Verify if it meets Account Rules
        IF  ((l_alt_pk_inst_pty_id <> l_curr_party_acct_rec.instance_party_id)
            OR
            (l_alt_pk_rel_type_code <> l_curr_party_acct_rec.relationship_type_code))
        THEN
           IF CSI_Instance_parties_vld_pvt.Acct_Rules_Check
                       (l_alt_pk_inst_pty_id ,
                        l_alt_pk_rel_type_code ) THEN
             RAISE FND_API.G_EXC_ERROR;
           END IF;
         END IF;

        -- Get party record for later use in contaracts
        IF NOT(CSI_Instance_parties_vld_pvt.Get_Party_Record
           (l_curr_party_acct_rec.instance_party_id,
           l_party_rec)) THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

       -- If it is an owner party and owner account then update csi_item_instances
        IF p_party_account_rec.relationship_type_code <> FND_API.G_MISS_CHAR THEN
           IF ((p_party_account_rec.relationship_type_code = 'OWNER')
              AND (l_party_relation = 'OWNER')) THEN
            -- Added by sguthiva for bug 2307804
             IF p_party_account_rec.party_account_id <> fnd_api.g_miss_num
              AND p_party_account_rec.party_account_id IS NOT NULL
             THEN
                update csi_item_instances
                set   owner_party_account_id =  p_party_account_rec.party_account_id
                where  instance_id     = l_party_rec.instance_id;
             END IF;
            END IF;
            -- End addition by sguthiva for bug 2307804
        END IF;

           IF p_txn_rec.transaction_type_id=7 AND
              l_found_for_update='T'
           THEN
              l_acct_end_date:=l_temp_acct_date;
           ELSE
              l_acct_end_date:=p_party_account_rec.active_end_date;
           END IF;

        -- Increment the object_version_number before updating
        l_OBJECT_VERSION_NUMBER := l_curr_party_acct_rec.OBJECT_VERSION_NUMBER + 1 ;

        -- Calling table table handler to update
        CSI_IP_ACCOUNTS_PKG.Update_Row
        (
          p_IP_ACCOUNT_ID       => p_party_account_rec.ip_account_id,
          p_INSTANCE_PARTY_ID   => p_party_account_rec.INSTANCE_PARTY_ID,
          p_PARTY_ACCOUNT_ID    => p_party_account_rec.PARTY_ACCOUNT_ID,
          p_RELATIONSHIP_TYPE_CODE => p_party_account_rec.RELATIONSHIP_TYPE_CODE,
          p_ACTIVE_START_DATE   => p_party_account_rec.ACTIVE_START_DATE,
          p_ACTIVE_END_DATE     => l_acct_end_date, --p_party_account_rec.ACTIVE_END_DATE,
          p_CONTEXT             => p_party_account_rec.CONTEXT,
          p_ATTRIBUTE1          => p_party_account_rec.ATTRIBUTE1,
          p_ATTRIBUTE2          => p_party_account_rec.ATTRIBUTE2,
          p_ATTRIBUTE3          => p_party_account_rec.ATTRIBUTE3,
          p_ATTRIBUTE4          => p_party_account_rec.ATTRIBUTE4,
          p_ATTRIBUTE5          => p_party_account_rec.ATTRIBUTE5,
          p_ATTRIBUTE6          => p_party_account_rec.ATTRIBUTE6,
          p_ATTRIBUTE7          => p_party_account_rec.ATTRIBUTE7,
          p_ATTRIBUTE8          => p_party_account_rec.ATTRIBUTE8,
          p_ATTRIBUTE9          => p_party_account_rec.ATTRIBUTE9,
          p_ATTRIBUTE10         => p_party_account_rec.ATTRIBUTE10,
          p_ATTRIBUTE11         => p_party_account_rec.ATTRIBUTE11,
          p_ATTRIBUTE12         => p_party_account_rec.ATTRIBUTE12,
          p_ATTRIBUTE13         => p_party_account_rec.ATTRIBUTE13,
          p_ATTRIBUTE14         => p_party_account_rec.ATTRIBUTE14,
          p_ATTRIBUTE15         => p_party_account_rec.ATTRIBUTE15,
          p_CREATED_BY          => FND_API.G_MISS_NUM, -- FND_GLOBAL.USER_ID,
          p_CREATION_DATE       => FND_API.G_MISS_DATE, -- SYSDATE,
          p_LAST_UPDATED_BY     => FND_GLOBAL.USER_ID             ,
          p_LAST_UPDATE_DATE    => SYSDATE                        ,
          p_LAST_UPDATE_LOGIN   => FND_GLOBAL.LOGIN_ID            ,
          p_OBJECT_VERSION_NUMBER => l_OBJECT_VERSION_NUMBER      ,
          p_BILL_TO_ADDRESS     => p_party_account_rec.BILL_TO_ADDRESS,
          p_SHIP_TO_ADDRESS     => p_party_account_rec.SHIP_TO_ADDRESS,
          p_REQUEST_ID          => p_party_account_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID => p_party_account_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID          => p_party_account_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE => p_party_account_rec.PROGRAM_UPDATE_DATE);

         -- Call create_transaction to create txn log
         CSI_TRANSACTIONS_PVT.Create_transaction
          (
             p_api_version            => p_api_version
            ,p_commit                 => p_commit
            ,p_init_msg_list          => p_init_msg_list
            ,p_validation_level       => p_validation_level
            ,p_Success_If_Exists_Flag => 'Y'
            ,P_transaction_rec        => p_txn_rec
            ,x_return_status          => x_return_status
            ,x_msg_count              => x_msg_count
            ,x_msg_data               => x_msg_data         );

         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN

              FOR i in 1..x_msg_Count LOOP
                FND_MSG_PUB.Get(p_msg_index     => i,
                                p_encoded       => 'F',
                                p_data          => x_msg_data,
                                p_msg_index_out => x_msg_index_out );
                csi_gen_utility_pvt.put_line( 'message data = '||x_msg_data);
              End LOOP;
              RAISE FND_API.G_EXC_ERROR;
         END IF;



         -- Generate a unique instance_party_history_id from the sequence
         l_ip_account_history_id := CSI_Instance_parties_vld_pvt.gen_ip_account_hist_id;

         -- Get the full_dump_frequency from csi_install_parameter
       IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
          csi_gen_utility_pvt.populate_install_param_rec;
       END IF;
       --
       l_full_dump_frequency := csi_datastructures_pub.g_install_param_rec.history_full_dump_frequency;
       --
       IF l_full_dump_frequency IS NULL THEN
          FND_MESSAGE.SET_NAME('CSI','CSI_API_GET_FULL_DUMP_FAILED');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       --
         select mod(l_object_version_number,l_full_dump_frequency)
         into   l_mod_value
         from   dual;

         -- assign the party rec
         l_temp_party_account_rec := p_party_account_rec;
         l_temp_party_account_rec.active_end_date:=l_acct_end_date;
      -- Start of changes for Bug#2547034 on 09/20/02 - rtalluri
       BEGIN
        SELECT  ip_account_history_id
        INTO    l_ip_acct_hist_id
        FROM    csi_ip_accounts_h h
        WHERE   h.transaction_id = p_txn_rec.transaction_id
        AND     h.ip_account_id = p_party_account_rec.ip_account_id;

        OPEN   pty_acct_csr(l_ip_acct_hist_id);
        FETCH  pty_acct_csr INTO l_pty_acct_csr ;
        CLOSE  pty_acct_csr;
        IF l_pty_acct_csr.full_dump_flag = 'Y'
        THEN
        CSI_IP_ACCOUNTS_H_PKG.Update_Row
         (
          p_IP_ACCOUNT_HISTORY_ID         => l_ip_acct_hist_id                        ,
          p_IP_ACCOUNT_ID                 => fnd_api.g_miss_num                       ,
          p_TRANSACTION_ID                => fnd_api.g_miss_num                       ,
          p_OLD_PARTY_ACCOUNT_ID          => fnd_api.g_miss_num                       ,
          p_NEW_PARTY_ACCOUNT_ID          => l_temp_party_account_rec.PARTY_ACCOUNT_ID,
          p_OLD_RELATIONSHIP_TYPE_CODE    => fnd_api.g_miss_char                      ,
          p_NEW_RELATIONSHIP_TYPE_CODE    => l_temp_party_account_rec.RELATIONSHIP_TYPE_CODE,
          p_OLD_ACTIVE_START_DATE         => fnd_api.g_miss_date                      ,
          p_NEW_ACTIVE_START_DATE         => l_temp_party_account_rec.ACTIVE_START_DATE,
          p_OLD_ACTIVE_END_DATE           => fnd_api.g_miss_date                      ,
          p_NEW_ACTIVE_END_DATE           => l_temp_party_account_rec.ACTIVE_END_DATE ,
          p_OLD_CONTEXT                   => fnd_api.g_miss_char                      ,
          p_NEW_CONTEXT                   => l_temp_party_account_rec.CONTEXT         ,
          p_OLD_ATTRIBUTE1                => fnd_api.g_miss_char                      ,
          p_NEW_ATTRIBUTE1                => l_temp_party_account_rec.ATTRIBUTE1      ,
          p_OLD_ATTRIBUTE2                => fnd_api.g_miss_char                      ,
          p_NEW_ATTRIBUTE2                => l_temp_party_account_rec.ATTRIBUTE2      ,
          p_OLD_ATTRIBUTE3                => fnd_api.g_miss_char                      ,
          p_NEW_ATTRIBUTE3                => l_temp_party_account_rec.ATTRIBUTE3      ,
          p_OLD_ATTRIBUTE4                => fnd_api.g_miss_char                      ,
          p_NEW_ATTRIBUTE4                => l_temp_party_account_rec.ATTRIBUTE4      ,
          p_OLD_ATTRIBUTE5                => fnd_api.g_miss_char                      ,
          p_NEW_ATTRIBUTE5                => l_temp_party_account_rec.ATTRIBUTE5      ,
          p_OLD_ATTRIBUTE6                => fnd_api.g_miss_char                      ,
          p_NEW_ATTRIBUTE6                => l_temp_party_account_rec.ATTRIBUTE6      ,
          p_OLD_ATTRIBUTE7                => fnd_api.g_miss_char                      ,
          p_NEW_ATTRIBUTE7                => l_temp_party_account_rec.ATTRIBUTE7      ,
          p_OLD_ATTRIBUTE8                => fnd_api.g_miss_char                      ,
          p_NEW_ATTRIBUTE8                => l_temp_party_account_rec.ATTRIBUTE8      ,
          p_OLD_ATTRIBUTE9                => fnd_api.g_miss_char                      ,
          p_NEW_ATTRIBUTE9                => l_temp_party_account_rec.ATTRIBUTE9      ,
          p_OLD_ATTRIBUTE10               => fnd_api.g_miss_char                      ,
          p_NEW_ATTRIBUTE10               => l_temp_party_account_rec.ATTRIBUTE10     ,
          p_OLD_ATTRIBUTE11               => fnd_api.g_miss_char                      ,
          p_NEW_ATTRIBUTE11               => l_temp_party_account_rec.ATTRIBUTE11     ,
          p_OLD_ATTRIBUTE12               => fnd_api.g_miss_char                      ,
          p_NEW_ATTRIBUTE12               => l_temp_party_account_rec.ATTRIBUTE12     ,
          p_OLD_ATTRIBUTE13               => fnd_api.g_miss_char                      ,
          p_NEW_ATTRIBUTE13               => l_temp_party_account_rec.ATTRIBUTE13     ,
          p_OLD_ATTRIBUTE14               => fnd_api.g_miss_char                      ,
          p_NEW_ATTRIBUTE14               => l_temp_party_account_rec.ATTRIBUTE14     ,
          p_OLD_ATTRIBUTE15               => fnd_api.g_miss_char                      ,
          p_NEW_ATTRIBUTE15               => l_temp_party_account_rec.ATTRIBUTE15     ,
          p_FULL_DUMP_FLAG                => fnd_api.g_miss_char                      ,
          p_CREATED_BY                    => FND_API.G_MISS_NUM                       ,
          p_CREATION_DATE                 => FND_API.G_MISS_DATE                      ,
          p_LAST_UPDATED_BY               => FND_GLOBAL.USER_ID                       ,
          p_LAST_UPDATE_DATE              => SYSDATE                                  ,
          p_LAST_UPDATE_LOGIN             => FND_GLOBAL.LOGIN_ID                      ,
          p_OBJECT_VERSION_NUMBER         => fnd_api.g_miss_num                       ,
          p_OLD_BILL_TO_ADDRESS           => fnd_api.g_miss_num                       ,
          p_NEW_BILL_TO_ADDRESS           => l_temp_party_account_rec.BILL_TO_ADDRESS ,
          p_OLD_SHIP_TO_ADDRESS           => fnd_api.g_miss_num                       ,
          p_NEW_SHIP_TO_ADDRESS           => l_temp_party_account_rec.SHIP_TO_ADDRESS ,
          p_OLD_INSTANCE_PARTY_ID         => fnd_api.g_miss_num                       ,
          p_NEW_INSTANCE_PARTY_ID         => l_temp_party_account_rec.INSTANCE_PARTY_ID);


        ELSE

             IF    ( l_pty_acct_csr.old_party_account_id IS NULL
                AND  l_pty_acct_csr.new_party_account_id IS NULL ) THEN
                     IF  ( l_temp_party_account_rec.party_account_id = l_curr_party_acct_rec.party_account_id )
                      OR ( l_temp_party_account_rec.party_account_id = fnd_api.g_miss_num ) THEN
                           l_pty_acct_csr.old_party_account_id := NULL;
                           l_pty_acct_csr.new_party_account_id := NULL;
                     ELSE
                           l_pty_acct_csr.old_party_account_id := fnd_api.g_miss_num;
                           l_pty_acct_csr.new_party_account_id := l_temp_party_account_rec.party_account_id;
                     END IF;
             ELSE
                     l_pty_acct_csr.old_party_account_id := fnd_api.g_miss_num;
                     l_pty_acct_csr.new_party_account_id := l_temp_party_account_rec.party_account_id;
             END IF;
             --
             IF    ( l_pty_acct_csr.old_relationship_type_code IS NULL
                AND  l_pty_acct_csr.new_relationship_type_code IS NULL ) THEN
                     IF  ( l_temp_party_account_rec.relationship_type_code = l_curr_party_acct_rec.relationship_type_code )
                      OR ( l_temp_party_account_rec.relationship_type_code = fnd_api.g_miss_char ) THEN
                           l_pty_acct_csr.old_relationship_type_code := NULL;
                           l_pty_acct_csr.new_relationship_type_code := NULL;
                     ELSE
                           l_pty_acct_csr.old_relationship_type_code := fnd_api.g_miss_char;
                           l_pty_acct_csr.new_relationship_type_code := l_temp_party_account_rec.relationship_type_code;
                     END IF;
             ELSE
                     l_pty_acct_csr.old_relationship_type_code := fnd_api.g_miss_char;
                     l_pty_acct_csr.new_relationship_type_code := l_temp_party_account_rec.relationship_type_code;
             END IF;
             --
             IF    ( l_pty_acct_csr.old_bill_to_address IS NULL
                AND  l_pty_acct_csr.new_bill_to_address IS NULL ) THEN
                     IF  ( l_temp_party_account_rec.bill_to_address = l_curr_party_acct_rec.bill_to_address )
                      OR ( l_temp_party_account_rec.bill_to_address = fnd_api.g_miss_num ) THEN
                           l_pty_acct_csr.old_bill_to_address := NULL;
                           l_pty_acct_csr.new_bill_to_address := NULL;
                     ELSE
                           l_pty_acct_csr.old_bill_to_address := fnd_api.g_miss_num;
                           l_pty_acct_csr.new_bill_to_address := l_temp_party_account_rec.bill_to_address;
                     END IF;
             ELSE
                     l_pty_acct_csr.old_bill_to_address := fnd_api.g_miss_num;
                     l_pty_acct_csr.new_bill_to_address := l_temp_party_account_rec.bill_to_address;
             END IF;
             --
             IF    ( l_pty_acct_csr.old_ship_to_address IS NULL
                AND  l_pty_acct_csr.new_ship_to_address IS NULL ) THEN
                     IF  ( l_temp_party_account_rec.ship_to_address = l_curr_party_acct_rec.ship_to_address )
                      OR ( l_temp_party_account_rec.ship_to_address = fnd_api.g_miss_num ) THEN
                           l_pty_acct_csr.old_ship_to_address := NULL;
                           l_pty_acct_csr.new_ship_to_address := NULL;
                     ELSE
                           l_pty_acct_csr.old_ship_to_address := fnd_api.g_miss_num;
                           l_pty_acct_csr.new_ship_to_address := l_temp_party_account_rec.ship_to_address;
                     END IF;
             ELSE
                     l_pty_acct_csr.old_ship_to_address := fnd_api.g_miss_num;
                     l_pty_acct_csr.new_ship_to_address := l_temp_party_account_rec.ship_to_address;
             END IF;
             --
             IF    ( l_pty_acct_csr.old_active_start_date IS NULL
                AND  l_pty_acct_csr.new_active_start_date IS NULL ) THEN
                     IF  ( l_temp_party_account_rec.active_start_date = l_curr_party_acct_rec.active_start_date )
                      OR ( l_temp_party_account_rec.active_start_date = fnd_api.g_miss_date ) THEN
                           l_pty_acct_csr.old_active_start_date := NULL;
                           l_pty_acct_csr.new_active_start_date := NULL;
                     ELSE
                           l_pty_acct_csr.old_active_start_date := fnd_api.g_miss_date;
                           l_pty_acct_csr.new_active_start_date := l_temp_party_account_rec.active_start_date;
                     END IF;
             ELSE
                     l_pty_acct_csr.old_active_start_date := fnd_api.g_miss_date;
                     l_pty_acct_csr.new_active_start_date := l_temp_party_account_rec.active_start_date;
             END IF;
             --
             IF    ( l_pty_acct_csr.old_active_end_date IS NULL
                AND  l_pty_acct_csr.new_active_end_date IS NULL ) THEN
                     IF  ( l_temp_party_account_rec.active_end_date = l_curr_party_acct_rec.active_end_date )
                      OR ( l_temp_party_account_rec.active_end_date = fnd_api.g_miss_date ) THEN
                           l_pty_acct_csr.old_active_end_date := NULL;
                           l_pty_acct_csr.new_active_end_date := NULL;
                     ELSE
                           l_pty_acct_csr.old_active_end_date := fnd_api.g_miss_date;
                           l_pty_acct_csr.new_active_end_date := l_temp_party_account_rec.active_end_date;
                     END IF;
             ELSE
                     l_pty_acct_csr.old_active_end_date := fnd_api.g_miss_date;
                     l_pty_acct_csr.new_active_end_date := l_temp_party_account_rec.active_end_date;
             END IF;
             --
             IF    ( l_pty_acct_csr.old_context IS NULL
                AND  l_pty_acct_csr.new_context IS NULL ) THEN
                     IF  ( l_temp_party_account_rec.context = l_curr_party_acct_rec.context )
                      OR ( l_temp_party_account_rec.context = fnd_api.g_miss_char ) THEN
                           l_pty_acct_csr.old_context := NULL;
                           l_pty_acct_csr.new_context := NULL;
                     ELSE
                           l_pty_acct_csr.old_context := fnd_api.g_miss_char;
                           l_pty_acct_csr.new_context := l_temp_party_account_rec.context;
                     END IF;
             ELSE
                     l_pty_acct_csr.old_context := fnd_api.g_miss_char;
                     l_pty_acct_csr.new_context := l_temp_party_account_rec.context;
             END IF;
             --
             IF    ( l_pty_acct_csr.old_attribute1 IS NULL
                AND  l_pty_acct_csr.new_attribute1 IS NULL ) THEN
                     IF  ( l_temp_party_account_rec.attribute1 = l_curr_party_acct_rec.attribute1 )
                      OR ( l_temp_party_account_rec.attribute1 = fnd_api.g_miss_char ) THEN
                           l_pty_acct_csr.old_attribute1 := NULL;
                           l_pty_acct_csr.new_attribute1 := NULL;
                     ELSE
                           l_pty_acct_csr.old_attribute1 := fnd_api.g_miss_char;
                           l_pty_acct_csr.new_attribute1 := l_temp_party_account_rec.attribute1;
                     END IF;
             ELSE
                     l_pty_acct_csr.old_attribute1 := fnd_api.g_miss_char;
                     l_pty_acct_csr.new_attribute1 := l_temp_party_account_rec.attribute1;
             END IF;
             --
             IF    ( l_pty_acct_csr.old_attribute2 IS NULL
                AND  l_pty_acct_csr.new_attribute2 IS NULL ) THEN
                     IF  ( l_temp_party_account_rec.attribute2 = l_curr_party_acct_rec.attribute2 )
                      OR ( l_temp_party_account_rec.attribute2 = fnd_api.g_miss_char ) THEN
                           l_pty_acct_csr.old_attribute2 := NULL;
                           l_pty_acct_csr.new_attribute2 := NULL;
                     ELSE
                           l_pty_acct_csr.old_attribute2 := fnd_api.g_miss_char;
                           l_pty_acct_csr.new_attribute2 := l_temp_party_account_rec.attribute2;
                     END IF;
             ELSE
                     l_pty_acct_csr.old_attribute2 := fnd_api.g_miss_char;
                     l_pty_acct_csr.new_attribute2 := l_temp_party_account_rec.attribute2;
             END IF;
             --
             IF    ( l_pty_acct_csr.old_attribute3 IS NULL
                AND  l_pty_acct_csr.new_attribute3 IS NULL ) THEN
                     IF  ( l_temp_party_account_rec.attribute3 = l_curr_party_acct_rec.attribute3 )
                      OR ( l_temp_party_account_rec.attribute3 = fnd_api.g_miss_char ) THEN
                           l_pty_acct_csr.old_attribute3 := NULL;
                           l_pty_acct_csr.new_attribute3 := NULL;
                     ELSE
                           l_pty_acct_csr.old_attribute3 := fnd_api.g_miss_char;
                           l_pty_acct_csr.new_attribute3 := l_temp_party_account_rec.attribute3;
                     END IF;
             ELSE
                     l_pty_acct_csr.old_attribute3 := fnd_api.g_miss_char;
                     l_pty_acct_csr.new_attribute3 := l_temp_party_account_rec.attribute3;
             END IF;
             --
             IF    ( l_pty_acct_csr.old_attribute4 IS NULL
                AND  l_pty_acct_csr.new_attribute4 IS NULL ) THEN
                     IF  ( l_temp_party_account_rec.attribute4 = l_curr_party_acct_rec.attribute4 )
                      OR ( l_temp_party_account_rec.attribute4 = fnd_api.g_miss_char ) THEN
                           l_pty_acct_csr.old_attribute4 := NULL;
                           l_pty_acct_csr.new_attribute4 := NULL;
                     ELSE
                           l_pty_acct_csr.old_attribute4 := fnd_api.g_miss_char;
                           l_pty_acct_csr.new_attribute4 := l_temp_party_account_rec.attribute4;
                     END IF;
             ELSE
                     l_pty_acct_csr.old_attribute4 := fnd_api.g_miss_char;
                     l_pty_acct_csr.new_attribute4 := l_temp_party_account_rec.attribute4;
             END IF;
             --
             IF    ( l_pty_acct_csr.old_attribute5 IS NULL
                AND  l_pty_acct_csr.new_attribute5 IS NULL ) THEN
                     IF  ( l_temp_party_account_rec.attribute5 = l_curr_party_acct_rec.attribute5 )
                      OR ( l_temp_party_account_rec.attribute5 = fnd_api.g_miss_char ) THEN
                           l_pty_acct_csr.old_attribute5 := NULL;
                           l_pty_acct_csr.new_attribute5 := NULL;
                     ELSE
                           l_pty_acct_csr.old_attribute5 := fnd_api.g_miss_char;
                           l_pty_acct_csr.new_attribute5 := l_temp_party_account_rec.attribute5;
                     END IF;
             ELSE
                     l_pty_acct_csr.old_attribute5 := fnd_api.g_miss_char;
                     l_pty_acct_csr.new_attribute5 := l_temp_party_account_rec.attribute5;
             END IF;
             --
             IF    ( l_pty_acct_csr.old_attribute6 IS NULL
                AND  l_pty_acct_csr.new_attribute6 IS NULL ) THEN
                     IF  ( l_temp_party_account_rec.attribute6 = l_curr_party_acct_rec.attribute6 )
                      OR ( l_temp_party_account_rec.attribute6 = fnd_api.g_miss_char ) THEN
                           l_pty_acct_csr.old_attribute6 := NULL;
                           l_pty_acct_csr.new_attribute6 := NULL;
                     ELSE
                           l_pty_acct_csr.old_attribute6 := fnd_api.g_miss_char;
                           l_pty_acct_csr.new_attribute6 := l_temp_party_account_rec.attribute6;
                     END IF;
             ELSE
                     l_pty_acct_csr.old_attribute6 := fnd_api.g_miss_char;
                     l_pty_acct_csr.new_attribute6 := l_temp_party_account_rec.attribute6;
             END IF;
             --
             IF    ( l_pty_acct_csr.old_attribute7 IS NULL
                AND  l_pty_acct_csr.new_attribute7 IS NULL ) THEN
                     IF  ( l_temp_party_account_rec.attribute7 = l_curr_party_acct_rec.attribute7 )
                      OR ( l_temp_party_account_rec.attribute7 = fnd_api.g_miss_char ) THEN
                           l_pty_acct_csr.old_attribute7 := NULL;
                           l_pty_acct_csr.new_attribute7 := NULL;
                     ELSE
                           l_pty_acct_csr.old_attribute7 := fnd_api.g_miss_char;
                           l_pty_acct_csr.new_attribute7 := l_temp_party_account_rec.attribute7;
                     END IF;
             ELSE
                     l_pty_acct_csr.old_attribute7 := fnd_api.g_miss_char;
                     l_pty_acct_csr.new_attribute7 := l_temp_party_account_rec.attribute7;
             END IF;
             --
             IF    ( l_pty_acct_csr.old_attribute8 IS NULL
                AND  l_pty_acct_csr.new_attribute8 IS NULL ) THEN
                     IF  ( l_temp_party_account_rec.attribute8 = l_curr_party_acct_rec.attribute8 )
                      OR ( l_temp_party_account_rec.attribute8 = fnd_api.g_miss_char ) THEN
                           l_pty_acct_csr.old_attribute8 := NULL;
                           l_pty_acct_csr.new_attribute8 := NULL;
                     ELSE
                           l_pty_acct_csr.old_attribute8 := fnd_api.g_miss_char;
                           l_pty_acct_csr.new_attribute8 := l_temp_party_account_rec.attribute8;
                     END IF;
             ELSE
                     l_pty_acct_csr.old_attribute8 := fnd_api.g_miss_char;
                     l_pty_acct_csr.new_attribute8 := l_temp_party_account_rec.attribute8;
             END IF;
             --
             IF    ( l_pty_acct_csr.old_attribute9 IS NULL
                AND  l_pty_acct_csr.new_attribute9 IS NULL ) THEN
                     IF  ( l_temp_party_account_rec.attribute9 = l_curr_party_acct_rec.attribute9 )
                      OR ( l_temp_party_account_rec.attribute9 = fnd_api.g_miss_char ) THEN
                           l_pty_acct_csr.old_attribute9 := NULL;
                           l_pty_acct_csr.new_attribute9 := NULL;
                     ELSE
                           l_pty_acct_csr.old_attribute9 := fnd_api.g_miss_char;
                           l_pty_acct_csr.new_attribute9 := l_temp_party_account_rec.attribute9;
                     END IF;
             ELSE
                     l_pty_acct_csr.old_attribute9 := fnd_api.g_miss_char;
                     l_pty_acct_csr.new_attribute9 := l_temp_party_account_rec.attribute9;
             END IF;
             --
             IF    ( l_pty_acct_csr.old_attribute10 IS NULL
                AND  l_pty_acct_csr.new_attribute10 IS NULL ) THEN
                     IF  ( l_temp_party_account_rec.attribute10 = l_curr_party_acct_rec.attribute10 )
                      OR ( l_temp_party_account_rec.attribute10 = fnd_api.g_miss_char ) THEN
                           l_pty_acct_csr.old_attribute10 := NULL;
                           l_pty_acct_csr.new_attribute10 := NULL;
                     ELSE
                           l_pty_acct_csr.old_attribute10 := fnd_api.g_miss_char;
                           l_pty_acct_csr.new_attribute10 := l_temp_party_account_rec.attribute10;
                     END IF;
             ELSE
                     l_pty_acct_csr.old_attribute10 := fnd_api.g_miss_char;
                     l_pty_acct_csr.new_attribute10 := l_temp_party_account_rec.attribute10;
             END IF;
             --
             IF    ( l_pty_acct_csr.old_attribute11 IS NULL
                AND  l_pty_acct_csr.new_attribute11 IS NULL ) THEN
                     IF  ( l_temp_party_account_rec.attribute11 = l_curr_party_acct_rec.attribute11 )
                      OR ( l_temp_party_account_rec.attribute11 = fnd_api.g_miss_char ) THEN
                           l_pty_acct_csr.old_attribute11 := NULL;
                           l_pty_acct_csr.new_attribute11 := NULL;
                     ELSE
                           l_pty_acct_csr.old_attribute11 := fnd_api.g_miss_char;
                           l_pty_acct_csr.new_attribute11 := l_temp_party_account_rec.attribute11;
                     END IF;
             ELSE
                     l_pty_acct_csr.old_attribute11 := fnd_api.g_miss_char;
                     l_pty_acct_csr.new_attribute11 := l_temp_party_account_rec.attribute11;
             END IF;
             --
             IF    ( l_pty_acct_csr.old_attribute12 IS NULL
                AND  l_pty_acct_csr.new_attribute12 IS NULL ) THEN
                     IF  ( l_temp_party_account_rec.attribute12 = l_curr_party_acct_rec.attribute12 )
                      OR ( l_temp_party_account_rec.attribute12 = fnd_api.g_miss_char ) THEN
                           l_pty_acct_csr.old_attribute12 := NULL;
                           l_pty_acct_csr.new_attribute12 := NULL;
                     ELSE
                           l_pty_acct_csr.old_attribute12 := fnd_api.g_miss_char;
                           l_pty_acct_csr.new_attribute12 := l_temp_party_account_rec.attribute12;
                     END IF;
             ELSE
                     l_pty_acct_csr.old_attribute12 := fnd_api.g_miss_char;
                     l_pty_acct_csr.new_attribute12 := l_temp_party_account_rec.attribute12;
             END IF;
             --
             IF    ( l_pty_acct_csr.old_attribute13 IS NULL
                AND  l_pty_acct_csr.new_attribute13 IS NULL ) THEN
                     IF  ( l_temp_party_account_rec.attribute13 = l_curr_party_acct_rec.attribute13 )
                      OR ( l_temp_party_account_rec.attribute13 = fnd_api.g_miss_char ) THEN
                           l_pty_acct_csr.old_attribute13 := NULL;
                           l_pty_acct_csr.new_attribute13 := NULL;
                     ELSE
                           l_pty_acct_csr.old_attribute13 := fnd_api.g_miss_char;
                           l_pty_acct_csr.new_attribute13 := l_temp_party_account_rec.attribute13;
                     END IF;
             ELSE
                     l_pty_acct_csr.old_attribute13 := fnd_api.g_miss_char;
                     l_pty_acct_csr.new_attribute13 := l_temp_party_account_rec.attribute13;
             END IF;
             --
             IF    ( l_pty_acct_csr.old_attribute14 IS NULL
                AND  l_pty_acct_csr.new_attribute14 IS NULL ) THEN
                     IF  ( l_temp_party_account_rec.attribute14 = l_curr_party_acct_rec.attribute14 )
                      OR ( l_temp_party_account_rec.attribute14 = fnd_api.g_miss_char ) THEN
                           l_pty_acct_csr.old_attribute14 := NULL;
                           l_pty_acct_csr.new_attribute14 := NULL;
                     ELSE
                           l_pty_acct_csr.old_attribute14 := fnd_api.g_miss_char;
                           l_pty_acct_csr.new_attribute14 := l_temp_party_account_rec.attribute14;
                     END IF;
             ELSE
                     l_pty_acct_csr.old_attribute14 := fnd_api.g_miss_char;
                     l_pty_acct_csr.new_attribute14 := l_temp_party_account_rec.attribute14;
             END IF;
             --
             IF    ( l_pty_acct_csr.old_attribute15 IS NULL
                AND  l_pty_acct_csr.new_attribute15 IS NULL ) THEN
                     IF  ( l_temp_party_account_rec.attribute15 = l_curr_party_acct_rec.attribute15 )
                      OR ( l_temp_party_account_rec.attribute15 = fnd_api.g_miss_char ) THEN
                           l_pty_acct_csr.old_attribute15 := NULL;
                           l_pty_acct_csr.new_attribute15 := NULL;
                     ELSE
                           l_pty_acct_csr.old_attribute15 := fnd_api.g_miss_char;
                           l_pty_acct_csr.new_attribute15 := l_temp_party_account_rec.attribute15;
                     END IF;
             ELSE
                     l_pty_acct_csr.old_attribute15 := fnd_api.g_miss_char;
                     l_pty_acct_csr.new_attribute15 := l_temp_party_account_rec.attribute15;
             END IF;
             --
             IF    ( l_pty_acct_csr.old_instance_party_id IS NULL
                AND  l_pty_acct_csr.new_instance_party_id IS NULL ) THEN
                     IF  ( l_temp_party_account_rec.instance_party_id = l_curr_party_acct_rec.instance_party_id )
                      OR ( l_temp_party_account_rec.instance_party_id = fnd_api.g_miss_num ) THEN
                           l_pty_acct_csr.old_instance_party_id := NULL;
                           l_pty_acct_csr.new_instance_party_id := NULL;
                     ELSE
                           l_pty_acct_csr.old_instance_party_id := fnd_api.g_miss_num;
                           l_pty_acct_csr.new_instance_party_id := l_temp_party_account_rec.instance_party_id;
                     END IF;
             ELSE
                     l_pty_acct_csr.old_instance_party_id := fnd_api.g_miss_num;
                     l_pty_acct_csr.new_instance_party_id := l_temp_party_account_rec.instance_party_id;
             END IF;

          CSI_IP_ACCOUNTS_H_PKG.Update_Row
         (
          p_IP_ACCOUNT_HISTORY_ID         => l_ip_acct_hist_id                        ,
          p_IP_ACCOUNT_ID                 => fnd_api.g_miss_num                       ,
          p_TRANSACTION_ID                => fnd_api.g_miss_num                       ,
          p_OLD_PARTY_ACCOUNT_ID          => l_pty_acct_csr.old_party_account_id      ,
          p_NEW_PARTY_ACCOUNT_ID          => l_pty_acct_csr.NEW_PARTY_ACCOUNT_ID,
          p_OLD_RELATIONSHIP_TYPE_CODE    => l_pty_acct_csr.old_relationship_type_code,
          p_NEW_RELATIONSHIP_TYPE_CODE    => l_pty_acct_csr.NEW_RELATIONSHIP_TYPE_CODE,
          p_OLD_ACTIVE_START_DATE         => l_pty_acct_csr.old_active_start_date     ,
          p_NEW_ACTIVE_START_DATE         => l_pty_acct_csr.NEW_ACTIVE_START_DATE,
          p_OLD_ACTIVE_END_DATE           => l_pty_acct_csr.old_active_end_date       ,
          p_NEW_ACTIVE_END_DATE           => l_pty_acct_csr.NEW_ACTIVE_END_DATE ,
          p_OLD_CONTEXT                   => l_pty_acct_csr.old_context               ,
          p_NEW_CONTEXT                   => l_pty_acct_csr.NEW_CONTEXT         ,
          p_OLD_ATTRIBUTE1                => l_pty_acct_csr.old_attribute1            ,
          p_NEW_ATTRIBUTE1                => l_pty_acct_csr.NEW_ATTRIBUTE1      ,
          p_OLD_ATTRIBUTE2                => l_pty_acct_csr.old_attribute2            ,
          p_NEW_ATTRIBUTE2                => l_pty_acct_csr.NEW_ATTRIBUTE2      ,
          p_OLD_ATTRIBUTE3                => l_pty_acct_csr.old_attribute3            ,
          p_NEW_ATTRIBUTE3                => l_pty_acct_csr.NEW_ATTRIBUTE3      ,
          p_OLD_ATTRIBUTE4                => l_pty_acct_csr.old_attribute4            ,
          p_NEW_ATTRIBUTE4                => l_pty_acct_csr.NEW_ATTRIBUTE4      ,
          p_OLD_ATTRIBUTE5                => l_pty_acct_csr.old_attribute5            ,
          p_NEW_ATTRIBUTE5                => l_pty_acct_csr.NEW_ATTRIBUTE5      ,
          p_OLD_ATTRIBUTE6                => l_pty_acct_csr.old_attribute6            ,
          p_NEW_ATTRIBUTE6                => l_pty_acct_csr.NEW_ATTRIBUTE6      ,
          p_OLD_ATTRIBUTE7                => l_pty_acct_csr.old_attribute7            ,
          p_NEW_ATTRIBUTE7                => l_pty_acct_csr.NEW_ATTRIBUTE7      ,
          p_OLD_ATTRIBUTE8                => l_pty_acct_csr.old_attribute8            ,
          p_NEW_ATTRIBUTE8                => l_pty_acct_csr.NEW_ATTRIBUTE8      ,
          p_OLD_ATTRIBUTE9                => l_pty_acct_csr.old_attribute9            ,
          p_NEW_ATTRIBUTE9                => l_pty_acct_csr.NEW_ATTRIBUTE9      ,
          p_OLD_ATTRIBUTE10               => l_pty_acct_csr.old_attribute10           ,
          p_NEW_ATTRIBUTE10               => l_pty_acct_csr.NEW_ATTRIBUTE10     ,
          p_OLD_ATTRIBUTE11               => l_pty_acct_csr.old_attribute11           ,
          p_NEW_ATTRIBUTE11               => l_pty_acct_csr.NEW_ATTRIBUTE11     ,
          p_OLD_ATTRIBUTE12               => l_pty_acct_csr.old_attribute12           ,
          p_NEW_ATTRIBUTE12               => l_pty_acct_csr.NEW_ATTRIBUTE12     ,
          p_OLD_ATTRIBUTE13               => l_pty_acct_csr.old_attribute13           ,
          p_NEW_ATTRIBUTE13               => l_pty_acct_csr.NEW_ATTRIBUTE13     ,
          p_OLD_ATTRIBUTE14               => l_pty_acct_csr.old_attribute14           ,
          p_NEW_ATTRIBUTE14               => l_pty_acct_csr.NEW_ATTRIBUTE14     ,
          p_OLD_ATTRIBUTE15               => l_pty_acct_csr.old_attribute15           ,
          p_NEW_ATTRIBUTE15               => l_pty_acct_csr.NEW_ATTRIBUTE15     ,
          p_FULL_DUMP_FLAG                => fnd_api.g_miss_char                      ,
          p_CREATED_BY                    => FND_API.G_MISS_NUM                 ,
          p_CREATION_DATE                 => FND_API.G_MISS_DATE                      ,
          p_LAST_UPDATED_BY               => FND_GLOBAL.USER_ID                       ,
          p_LAST_UPDATE_DATE              => SYSDATE                                  ,
          p_LAST_UPDATE_LOGIN             => FND_GLOBAL.LOGIN_ID                      ,
          p_OBJECT_VERSION_NUMBER         => fnd_api.g_miss_num                       ,
          p_OLD_BILL_TO_ADDRESS           => l_pty_acct_csr.old_bill_to_address       ,
          p_NEW_BILL_TO_ADDRESS           => l_pty_acct_csr.NEW_BILL_TO_ADDRESS ,
          p_OLD_SHIP_TO_ADDRESS           => l_pty_acct_csr.old_ship_to_address       ,
          p_NEW_SHIP_TO_ADDRESS           => l_pty_acct_csr.NEW_SHIP_TO_ADDRESS,
          p_OLD_INSTANCE_PARTY_ID         => l_pty_acct_csr.old_instance_party_id     ,
          p_NEW_INSTANCE_PARTY_ID         => l_pty_acct_csr.new_instance_party_id     );

        END IF;
      EXCEPTION

        WHEN NO_DATA_FOUND THEN
        IF (l_mod_value = 0) THEN
          -- If the mod value is 0 then dump all the columns both changed and unchanged
          -- changed columns have old and new values while the unchanged values have old and new values
          -- exactly same

          IF (p_party_account_rec.instance_party_id = FND_API.G_MISS_NUM) THEN
              l_temp_party_account_rec.instance_party_id := l_curr_party_acct_rec.instance_party_id ;
          END IF;
          IF (p_party_account_rec.party_account_id = FND_API.G_MISS_NUM) THEN
              l_temp_party_account_rec.party_account_id := l_curr_party_acct_rec.party_account_id ;
          END IF;
          IF (p_party_account_rec.relationship_type_code = FND_API.G_MISS_CHAR) THEN
              l_temp_party_account_rec.relationship_type_code := l_curr_party_acct_rec.relationship_type_code ;
          END IF;
          IF (p_party_account_rec.ACTIVE_START_DATE = FND_API.G_MISS_DATE) THEN
              l_temp_party_account_rec.ACTIVE_START_DATE := l_curr_party_acct_rec.ACTIVE_START_DATE ;
          END IF;
          IF  --(p_party_account_rec.ACTIVE_END_DATE = FND_API.G_MISS_DATE)
              (l_acct_end_date = FND_API.G_MISS_DATE)
          THEN
              l_temp_party_account_rec.ACTIVE_END_DATE := l_curr_party_acct_rec.ACTIVE_END_DATE ;
          END IF;
          IF  (p_party_account_rec.context = FND_API.G_MISS_CHAR) THEN
              l_temp_party_account_rec.CONTEXT := l_curr_party_acct_rec.CONTEXT ;
          END IF;
          IF  (p_party_account_rec.ATTRIBUTE1 = FND_API.G_MISS_CHAR) THEN
              l_temp_party_account_rec.ATTRIBUTE1 := l_curr_party_acct_rec.ATTRIBUTE1 ;
          END IF;
          IF  (p_party_account_rec.ATTRIBUTE2 = FND_API.G_MISS_CHAR) THEN
              l_temp_party_account_rec.ATTRIBUTE2 := l_curr_party_acct_rec.ATTRIBUTE2 ;
          END IF;
          IF  (p_party_account_rec.ATTRIBUTE3 = FND_API.G_MISS_CHAR) THEN
              l_temp_party_account_rec.ATTRIBUTE3 := l_curr_party_acct_rec.ATTRIBUTE3 ;
          END IF;
          IF  (p_party_account_rec.ATTRIBUTE4 = FND_API.G_MISS_CHAR) THEN
              l_temp_party_account_rec.ATTRIBUTE4 := l_curr_party_acct_rec.ATTRIBUTE4 ;
          END IF;
          IF  (p_party_account_rec.ATTRIBUTE5 = FND_API.G_MISS_CHAR) THEN
              l_temp_party_account_rec.ATTRIBUTE5 := l_curr_party_acct_rec.ATTRIBUTE5 ;
          END IF;
          IF  (p_party_account_rec.ATTRIBUTE6 = FND_API.G_MISS_CHAR) THEN
              l_temp_party_account_rec.ATTRIBUTE6 := l_curr_party_acct_rec.ATTRIBUTE6 ;
          END IF;
          IF  (p_party_account_rec.ATTRIBUTE7 = FND_API.G_MISS_CHAR) THEN
              l_temp_party_account_rec.ATTRIBUTE7 := l_curr_party_acct_rec.ATTRIBUTE7 ;
          END IF;
          IF  (p_party_account_rec.ATTRIBUTE8 = FND_API.G_MISS_CHAR) THEN
              l_temp_party_account_rec.ATTRIBUTE8 := l_curr_party_acct_rec.ATTRIBUTE8 ;
          END IF;
          IF  (p_party_account_rec.ATTRIBUTE9 = FND_API.G_MISS_CHAR) THEN
              l_temp_party_account_rec.ATTRIBUTE9 := l_curr_party_acct_rec.ATTRIBUTE9 ;
          END IF;
          IF  (p_party_account_rec.ATTRIBUTE10 = FND_API.G_MISS_CHAR) THEN
              l_temp_party_account_rec.ATTRIBUTE10 := l_curr_party_acct_rec.ATTRIBUTE10 ;
          END IF;
          IF  (p_party_account_rec.ATTRIBUTE11 = FND_API.G_MISS_CHAR) THEN
              l_temp_party_account_rec.ATTRIBUTE11 := l_curr_party_acct_rec.ATTRIBUTE11 ;
          END IF;
          IF  (p_party_account_rec.ATTRIBUTE12 = FND_API.G_MISS_CHAR) THEN
              l_temp_party_account_rec.ATTRIBUTE12 := l_curr_party_acct_rec.ATTRIBUTE12 ;
          END IF;
          IF  (p_party_account_rec.ATTRIBUTE13 = FND_API.G_MISS_CHAR) THEN
              l_temp_party_account_rec.ATTRIBUTE13 := l_curr_party_acct_rec.ATTRIBUTE13 ;
          END IF;
          IF  (p_party_account_rec.ATTRIBUTE14 = FND_API.G_MISS_CHAR) THEN
              l_temp_party_account_rec.ATTRIBUTE14 := l_curr_party_acct_rec.ATTRIBUTE14 ;
          END IF;
          IF  (p_party_account_rec.ATTRIBUTE15 = FND_API.G_MISS_CHAR) THEN
              l_temp_party_account_rec.ATTRIBUTE15 := l_curr_party_acct_rec.ATTRIBUTE15 ;
          END IF;

        -- Call table handlers to insert into csi_i_parties_h table
        CSI_IP_ACCOUNTS_H_PKG.Insert_Row
         (
          px_IP_ACCOUNT_HISTORY_ID        => l_ip_account_history_id          ,
          p_IP_ACCOUNT_ID                 => p_party_account_rec.ip_account_id,
          p_TRANSACTION_ID                => p_txn_rec.transaction_id        ,
          p_OLD_PARTY_ACCOUNT_ID          => l_curr_party_acct_rec.party_account_id,
          p_NEW_PARTY_ACCOUNT_ID          => l_temp_party_account_rec.PARTY_ACCOUNT_ID,
          p_OLD_RELATIONSHIP_TYPE_CODE    => l_curr_party_acct_rec.RELATIONSHIP_TYPE_CODE,
          p_NEW_RELATIONSHIP_TYPE_CODE    => l_temp_party_account_rec.RELATIONSHIP_TYPE_CODE,
          p_OLD_ACTIVE_START_DATE         => l_curr_party_acct_rec.ACTIVE_START_DATE,
          p_NEW_ACTIVE_START_DATE         => l_temp_party_account_rec.ACTIVE_START_DATE,
          p_OLD_ACTIVE_END_DATE           => l_curr_party_acct_rec.ACTIVE_END_DATE,
          p_NEW_ACTIVE_END_DATE           => l_temp_party_account_rec.ACTIVE_END_DATE,
          p_OLD_CONTEXT                   => l_curr_party_acct_rec.CONTEXT,
          p_NEW_CONTEXT                   => l_temp_party_account_rec.CONTEXT    ,
          p_OLD_ATTRIBUTE1                => l_curr_party_acct_rec.ATTRIBUTE1,
          p_NEW_ATTRIBUTE1                => l_temp_party_account_rec.ATTRIBUTE1 ,
          p_OLD_ATTRIBUTE2                => l_curr_party_acct_rec.ATTRIBUTE2,
          p_NEW_ATTRIBUTE2                => l_temp_party_account_rec.ATTRIBUTE2 ,
          p_OLD_ATTRIBUTE3                => l_curr_party_acct_rec.ATTRIBUTE3,
          p_NEW_ATTRIBUTE3                => l_temp_party_account_rec.ATTRIBUTE3 ,
          p_OLD_ATTRIBUTE4                => l_curr_party_acct_rec.ATTRIBUTE4,
          p_NEW_ATTRIBUTE4                => l_temp_party_account_rec.ATTRIBUTE4 ,
          p_OLD_ATTRIBUTE5                => l_curr_party_acct_rec.ATTRIBUTE5,
          p_NEW_ATTRIBUTE5                => l_temp_party_account_rec.ATTRIBUTE5 ,
          p_OLD_ATTRIBUTE6                => l_curr_party_acct_rec.ATTRIBUTE6,
          p_NEW_ATTRIBUTE6                => l_temp_party_account_rec.ATTRIBUTE6 ,
          p_OLD_ATTRIBUTE7                => l_curr_party_acct_rec.ATTRIBUTE7,
          p_NEW_ATTRIBUTE7                => l_temp_party_account_rec.ATTRIBUTE7 ,
          p_OLD_ATTRIBUTE8                => l_curr_party_acct_rec.ATTRIBUTE8,
          p_NEW_ATTRIBUTE8                => l_temp_party_account_rec.ATTRIBUTE8 ,
          p_OLD_ATTRIBUTE9                => l_curr_party_acct_rec.ATTRIBUTE9,
          p_NEW_ATTRIBUTE9                => l_temp_party_account_rec.ATTRIBUTE9 ,
          p_OLD_ATTRIBUTE10               => l_curr_party_acct_rec.ATTRIBUTE10,
          p_NEW_ATTRIBUTE10               => l_temp_party_account_rec.ATTRIBUTE10,
          p_OLD_ATTRIBUTE11               => l_curr_party_acct_rec.ATTRIBUTE11,
          p_NEW_ATTRIBUTE11               => l_temp_party_account_rec.ATTRIBUTE11,
          p_OLD_ATTRIBUTE12               => l_curr_party_acct_rec.ATTRIBUTE12,
          p_NEW_ATTRIBUTE12               => l_temp_party_account_rec.ATTRIBUTE12,
          p_OLD_ATTRIBUTE13               => l_curr_party_acct_rec.ATTRIBUTE13,
          p_NEW_ATTRIBUTE13               => l_temp_party_account_rec.ATTRIBUTE13,
          p_OLD_ATTRIBUTE14               => l_curr_party_acct_rec.ATTRIBUTE14,
          p_NEW_ATTRIBUTE14               => l_temp_party_account_rec.ATTRIBUTE14,
          p_OLD_ATTRIBUTE15               => l_curr_party_acct_rec.ATTRIBUTE15,
          p_NEW_ATTRIBUTE15               => l_temp_party_account_rec.ATTRIBUTE15,
          p_FULL_DUMP_FLAG                => 'Y'                            ,
          p_CREATED_BY                    => FND_GLOBAL.USER_ID             ,
          p_CREATION_DATE                 => SYSDATE                        ,
          p_LAST_UPDATED_BY               => FND_GLOBAL.USER_ID             ,
          p_LAST_UPDATE_DATE              => SYSDATE                        ,
          p_LAST_UPDATE_LOGIN             => FND_GLOBAL.LOGIN_ID            ,
          p_OBJECT_VERSION_NUMBER         => 1      ,
          p_OLD_BILL_TO_ADDRESS           => l_curr_party_acct_rec.BILL_TO_ADDRESS,
          p_NEW_BILL_TO_ADDRESS           => l_temp_party_account_rec.BILL_TO_ADDRESS,
          p_OLD_SHIP_TO_ADDRESS           => l_curr_party_acct_rec.SHIP_TO_ADDRESS ,
          p_NEW_SHIP_TO_ADDRESS           => l_temp_party_account_rec.SHIP_TO_ADDRESS,
          p_OLD_INSTANCE_PARTY_ID         => l_curr_party_acct_rec.INSTANCE_PARTY_ID ,
          p_NEW_INSTANCE_PARTY_ID         => l_temp_party_account_rec.INSTANCE_PARTY_ID);

       ELSE
          -- If the mod value is not equal to zero then dump only the changed columns
          -- while the unchanged values have old and new values as null
           IF (p_party_account_rec.party_account_id = fnd_api.g_miss_num) OR
               NVL(p_party_account_rec.party_account_id, fnd_api.g_miss_num) = NVL(l_curr_party_acct_rec.party_account_id, fnd_api.g_miss_num) THEN
                l_account_hist_rec.old_party_account_id := NULL;
                l_account_hist_rec.new_party_account_id := NULL;
           ELSIF
              NVL(l_curr_party_acct_rec.party_account_id,fnd_api.g_miss_num) <> NVL(p_party_account_rec.party_account_id,fnd_api.g_miss_num) THEN
                l_account_hist_rec.old_party_account_id := l_curr_party_acct_rec.party_account_id ;
                l_account_hist_rec.new_party_account_id := p_party_account_rec.party_account_id ;
           END IF;
           --
           IF (p_party_account_rec.relationship_type_code = fnd_api.g_miss_char) OR
               NVL(p_party_account_rec.relationship_type_code, fnd_api.g_miss_char) = NVL(l_curr_party_acct_rec.relationship_type_code, fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_relationship_type_code := NULL;
                l_account_hist_rec.new_relationship_type_code := NULL;
           ELSIF
              NVL(l_curr_party_acct_rec.relationship_type_code,fnd_api.g_miss_char) <> NVL(p_party_account_rec.relationship_type_code,fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_relationship_type_code := l_curr_party_acct_rec.relationship_type_code ;
                l_account_hist_rec.new_relationship_type_code := p_party_account_rec.relationship_type_code ;
           END IF;
           --
           IF (p_party_account_rec.bill_to_address = fnd_api.g_miss_num) OR
               NVL(p_party_account_rec.bill_to_address, fnd_api.g_miss_num) = NVL(l_curr_party_acct_rec.bill_to_address, fnd_api.g_miss_num) THEN
                l_account_hist_rec.old_bill_to_address := NULL;
                l_account_hist_rec.new_bill_to_address := NULL;
           ELSIF
              NVL(l_curr_party_acct_rec.bill_to_address,fnd_api.g_miss_num) <> NVL(p_party_account_rec.bill_to_address,fnd_api.g_miss_num) THEN
                l_account_hist_rec.old_bill_to_address := l_curr_party_acct_rec.bill_to_address ;
                l_account_hist_rec.new_bill_to_address := p_party_account_rec.bill_to_address ;
           END IF;
           --
           IF (p_party_account_rec.ship_to_address = fnd_api.g_miss_num) OR
               NVL(p_party_account_rec.ship_to_address, fnd_api.g_miss_num) = NVL(l_curr_party_acct_rec.ship_to_address, fnd_api.g_miss_num) THEN
                l_account_hist_rec.old_ship_to_address := NULL;
                l_account_hist_rec.new_ship_to_address := NULL;
           ELSIF
              NVL(l_curr_party_acct_rec.ship_to_address,fnd_api.g_miss_num) <> NVL(p_party_account_rec.ship_to_address,fnd_api.g_miss_num) THEN
                l_account_hist_rec.old_ship_to_address := l_curr_party_acct_rec.ship_to_address ;
                l_account_hist_rec.new_ship_to_address := p_party_account_rec.ship_to_address ;
           END IF;
           --
           IF (p_party_account_rec.active_start_date = fnd_api.g_miss_date) OR
               NVL(p_party_account_rec.active_start_date, fnd_api.g_miss_date) = NVL(l_curr_party_acct_rec.active_start_date, fnd_api.g_miss_date) THEN
                l_account_hist_rec.old_active_start_date := NULL;
                l_account_hist_rec.new_active_start_date := NULL;
           ELSIF
              NVL(l_curr_party_acct_rec.active_start_date,fnd_api.g_miss_date) <> NVL(p_party_account_rec.active_start_date,fnd_api.g_miss_date) THEN
                l_account_hist_rec.old_active_start_date := l_curr_party_acct_rec.active_start_date ;
                l_account_hist_rec.new_active_start_date := p_party_account_rec.active_start_date ;
           END IF;
           --
           IF --(p_party_account_rec.active_end_date = fnd_api.g_miss_date) OR
              (l_acct_end_date= fnd_api.g_miss_date) OR
               --NVL(p_party_account_rec.active_end_date, fnd_api.g_miss_date) = NVL(l_curr_party_acct_rec.active_end_date, fnd_api.g_miss_date) THEN
               NVL(l_acct_end_date, fnd_api.g_miss_date) = NVL(l_curr_party_acct_rec.active_end_date, fnd_api.g_miss_date) THEN
                l_account_hist_rec.old_active_end_date := NULL;
                l_account_hist_rec.new_active_end_date := NULL;
           ELSIF
              --NVL(l_curr_party_acct_rec.active_end_date,fnd_api.g_miss_date) <> NVL(p_party_account_rec.active_end_date,fnd_api.g_miss_date) THEN
              NVL(l_curr_party_acct_rec.active_end_date,fnd_api.g_miss_date) <> NVL(l_acct_end_date,fnd_api.g_miss_date) THEN
                l_account_hist_rec.old_active_end_date := l_curr_party_acct_rec.active_end_date ;
                l_account_hist_rec.new_active_end_date := l_acct_end_date; --p_party_account_rec.active_end_date ;
           END IF;
           --
           IF (p_party_account_rec.context = fnd_api.g_miss_char) OR
               NVL(p_party_account_rec.context, fnd_api.g_miss_char) = NVL(l_curr_party_acct_rec.context, fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_context := NULL;
                l_account_hist_rec.new_context := NULL;
           ELSIF
              NVL(l_curr_party_acct_rec.context,fnd_api.g_miss_char) <> NVL(p_party_account_rec.context,fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_context := l_curr_party_acct_rec.context ;
                l_account_hist_rec.new_context := p_party_account_rec.context ;
           END IF;
           --
           IF (p_party_account_rec.attribute1 = fnd_api.g_miss_char) OR
               NVL(p_party_account_rec.attribute1, fnd_api.g_miss_char) = NVL(l_curr_party_acct_rec.attribute1, fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_attribute1 := NULL;
                l_account_hist_rec.new_attribute1 := NULL;
           ELSIF
              NVL(l_curr_party_acct_rec.attribute1,fnd_api.g_miss_char) <> NVL(p_party_account_rec.attribute1,fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_attribute1 := l_curr_party_acct_rec.attribute1 ;
                l_account_hist_rec.new_attribute1 := p_party_account_rec.attribute1 ;
           END IF;
           --
           IF (p_party_account_rec.attribute2 = fnd_api.g_miss_char) OR
               NVL(p_party_account_rec.attribute2, fnd_api.g_miss_char) = NVL(l_curr_party_acct_rec.attribute2, fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_attribute2 := NULL;
                l_account_hist_rec.new_attribute2 := NULL;
           ELSIF
              NVL(l_curr_party_acct_rec.attribute2,fnd_api.g_miss_char) <> NVL(p_party_account_rec.attribute2,fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_attribute2 := l_curr_party_acct_rec.attribute2 ;
                l_account_hist_rec.new_attribute2 := p_party_account_rec.attribute2 ;
           END IF;
           --
           IF (p_party_account_rec.attribute3 = fnd_api.g_miss_char) OR
               NVL(p_party_account_rec.attribute3, fnd_api.g_miss_char) = NVL(l_curr_party_acct_rec.attribute3, fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_attribute3 := NULL;
                l_account_hist_rec.new_attribute3 := NULL;
           ELSIF
              NVL(l_curr_party_acct_rec.attribute3,fnd_api.g_miss_char) <> NVL(p_party_account_rec.attribute3,fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_attribute3 := l_curr_party_acct_rec.attribute3 ;
                l_account_hist_rec.new_attribute3 := p_party_account_rec.attribute3 ;
           END IF;
           --
           IF (p_party_account_rec.attribute4 = fnd_api.g_miss_char) OR
               NVL(p_party_account_rec.attribute4, fnd_api.g_miss_char) = NVL(l_curr_party_acct_rec.attribute4, fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_attribute4 := NULL;
                l_account_hist_rec.new_attribute4 := NULL;
           ELSIF
              NVL(l_curr_party_acct_rec.attribute4,fnd_api.g_miss_char) <> NVL(p_party_account_rec.attribute4,fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_attribute4 := l_curr_party_acct_rec.attribute4 ;
                l_account_hist_rec.new_attribute4 := p_party_account_rec.attribute4 ;
           END IF;
           --
           IF (p_party_account_rec.attribute5 = fnd_api.g_miss_char) OR
               NVL(p_party_account_rec.attribute5, fnd_api.g_miss_char) = NVL(l_curr_party_acct_rec.attribute5, fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_attribute5 := NULL;
                l_account_hist_rec.new_attribute5 := NULL;
           ELSIF
              NVL(l_curr_party_acct_rec.attribute5,fnd_api.g_miss_char) <> NVL(p_party_account_rec.attribute5,fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_attribute5 := l_curr_party_acct_rec.attribute5 ;
                l_account_hist_rec.new_attribute5 := p_party_account_rec.attribute5 ;
           END IF;
           --
           IF (p_party_account_rec.attribute6 = fnd_api.g_miss_char) OR
               NVL(p_party_account_rec.attribute6, fnd_api.g_miss_char) = NVL(l_curr_party_acct_rec.attribute6, fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_attribute6 := NULL;
                l_account_hist_rec.new_attribute6 := NULL;
           ELSIF
              NVL(l_curr_party_acct_rec.attribute6,fnd_api.g_miss_char) <> NVL(p_party_account_rec.attribute6,fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_attribute6 := l_curr_party_acct_rec.attribute6 ;
                l_account_hist_rec.new_attribute6 := p_party_account_rec.attribute6 ;
           END IF;
           --
           IF (p_party_account_rec.attribute7 = fnd_api.g_miss_char) OR
               NVL(p_party_account_rec.attribute7, fnd_api.g_miss_char) = NVL(l_curr_party_acct_rec.attribute7, fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_attribute7 := NULL;
                l_account_hist_rec.new_attribute7 := NULL;
           ELSIF
              NVL(l_curr_party_acct_rec.attribute7,fnd_api.g_miss_char) <> NVL(p_party_account_rec.attribute7,fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_attribute7 := l_curr_party_acct_rec.attribute7 ;
                l_account_hist_rec.new_attribute7 := p_party_account_rec.attribute7 ;
           END IF;
           --
           IF (p_party_account_rec.attribute8 = fnd_api.g_miss_char) OR
               NVL(p_party_account_rec.attribute8, fnd_api.g_miss_char) = NVL(l_curr_party_acct_rec.attribute8, fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_attribute8 := NULL;
                l_account_hist_rec.new_attribute8 := NULL;
           ELSIF
              NVL(l_curr_party_acct_rec.attribute8,fnd_api.g_miss_char) <> NVL(p_party_account_rec.attribute8,fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_attribute8 := l_curr_party_acct_rec.attribute8 ;
                l_account_hist_rec.new_attribute8 := p_party_account_rec.attribute8 ;
           END IF;
           --
           IF (p_party_account_rec.attribute9 = fnd_api.g_miss_char) OR
               NVL(p_party_account_rec.attribute9, fnd_api.g_miss_char) = NVL(l_curr_party_acct_rec.attribute9, fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_attribute9 := NULL;
                l_account_hist_rec.new_attribute9 := NULL;
           ELSIF
              NVL(l_curr_party_acct_rec.attribute9,fnd_api.g_miss_char) <> NVL(p_party_account_rec.attribute9,fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_attribute9 := l_curr_party_acct_rec.attribute9 ;
                l_account_hist_rec.new_attribute9 := p_party_account_rec.attribute9 ;
           END IF;
           --
           IF (p_party_account_rec.attribute10 = fnd_api.g_miss_char) OR
               NVL(p_party_account_rec.attribute10, fnd_api.g_miss_char) = NVL(l_curr_party_acct_rec.attribute10, fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_attribute10 := NULL;
                l_account_hist_rec.new_attribute10 := NULL;
           ELSIF
              NVL(l_curr_party_acct_rec.attribute10,fnd_api.g_miss_char) <> NVL(p_party_account_rec.attribute10,fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_attribute10 := l_curr_party_acct_rec.attribute10 ;
                l_account_hist_rec.new_attribute10 := p_party_account_rec.attribute10 ;
           END IF;
           --
           IF (p_party_account_rec.attribute11 = fnd_api.g_miss_char) OR
               NVL(p_party_account_rec.attribute11, fnd_api.g_miss_char) = NVL(l_curr_party_acct_rec.attribute11, fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_attribute11 := NULL;
                l_account_hist_rec.new_attribute11 := NULL;
           ELSIF
              NVL(l_curr_party_acct_rec.attribute11,fnd_api.g_miss_char) <> NVL(p_party_account_rec.attribute11,fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_attribute11 := l_curr_party_acct_rec.attribute11 ;
                l_account_hist_rec.new_attribute11 := p_party_account_rec.attribute11 ;
           END IF;
           --
           IF (p_party_account_rec.attribute12 = fnd_api.g_miss_char) OR
               NVL(p_party_account_rec.attribute12, fnd_api.g_miss_char) = NVL(l_curr_party_acct_rec.attribute12, fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_attribute12 := NULL;
                l_account_hist_rec.new_attribute12 := NULL;
           ELSIF
              NVL(l_curr_party_acct_rec.attribute12,fnd_api.g_miss_char) <> NVL(p_party_account_rec.attribute12,fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_attribute12 := l_curr_party_acct_rec.attribute12 ;
                l_account_hist_rec.new_attribute12 := p_party_account_rec.attribute12 ;
           END IF;
           --
           IF (p_party_account_rec.attribute13 = fnd_api.g_miss_char) OR
               NVL(p_party_account_rec.attribute13, fnd_api.g_miss_char) = NVL(l_curr_party_acct_rec.attribute13, fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_attribute13 := NULL;
                l_account_hist_rec.new_attribute13 := NULL;
           ELSIF
              NVL(l_curr_party_acct_rec.attribute13,fnd_api.g_miss_char) <> NVL(p_party_account_rec.attribute13,fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_attribute13 := l_curr_party_acct_rec.attribute13 ;
                l_account_hist_rec.new_attribute13 := p_party_account_rec.attribute13 ;
           END IF;
           --
           IF (p_party_account_rec.attribute14 = fnd_api.g_miss_char) OR
               NVL(p_party_account_rec.attribute14, fnd_api.g_miss_char) = NVL(l_curr_party_acct_rec.attribute14, fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_attribute14 := NULL;
                l_account_hist_rec.new_attribute14 := NULL;
           ELSIF
              NVL(l_curr_party_acct_rec.attribute14,fnd_api.g_miss_char) <> NVL(p_party_account_rec.attribute14,fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_attribute14 := l_curr_party_acct_rec.attribute14 ;
                l_account_hist_rec.new_attribute14 := p_party_account_rec.attribute14 ;
           END IF;
           --
           IF (p_party_account_rec.attribute15 = fnd_api.g_miss_char) OR
               NVL(p_party_account_rec.attribute15, fnd_api.g_miss_char) = NVL(l_curr_party_acct_rec.attribute15, fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_attribute15 := NULL;
                l_account_hist_rec.new_attribute15 := NULL;
           ELSIF
              NVL(l_curr_party_acct_rec.attribute15,fnd_api.g_miss_char) <> NVL(p_party_account_rec.attribute15,fnd_api.g_miss_char) THEN
                l_account_hist_rec.old_attribute15 := l_curr_party_acct_rec.attribute15 ;
                l_account_hist_rec.new_attribute15 := p_party_account_rec.attribute15 ;
           END IF;
    -- Added
           IF (p_party_account_rec.instance_party_id = fnd_api.g_miss_num) OR
               NVL(p_party_account_rec.instance_party_id, fnd_api.g_miss_num) = NVL(l_curr_party_acct_rec.instance_party_id, fnd_api.g_miss_num) THEN
                l_account_hist_rec.old_instance_party_id := NULL;
                l_account_hist_rec.new_instance_party_id := NULL;
           ELSIF
              NVL(l_curr_party_acct_rec.instance_party_id,fnd_api.g_miss_num) <> NVL(p_party_account_rec.instance_party_id,fnd_api.g_miss_num) THEN
                l_account_hist_rec.old_instance_party_id := l_curr_party_acct_rec.instance_party_id ;
                l_account_hist_rec.new_instance_party_id := p_party_account_rec.instance_party_id ;
           END IF;
   -- End addition
        -- Call table handlers to insert into csi_i_parties_h table
         CSI_IP_ACCOUNTS_H_PKG.Insert_Row
         (
          px_IP_ACCOUNT_HISTORY_ID        => l_ip_account_history_id ,
          p_IP_ACCOUNT_ID                 => p_party_account_rec.IP_ACCOUNT_ID ,
          p_TRANSACTION_ID                => p_txn_rec.TRANSACTION_ID ,
          p_OLD_PARTY_ACCOUNT_ID          => l_account_hist_rec.OLD_PARTY_ACCOUNT_ID ,
          p_NEW_PARTY_ACCOUNT_ID          => l_account_hist_rec.NEW_PARTY_ACCOUNT_ID ,
          p_OLD_RELATIONSHIP_TYPE_CODE    => l_account_hist_rec.OLD_RELATIONSHIP_TYPE_CODE ,
          p_NEW_RELATIONSHIP_TYPE_CODE    => l_account_hist_rec.NEW_RELATIONSHIP_TYPE_CODE ,
          p_OLD_ACTIVE_START_DATE         => l_account_hist_rec.OLD_ACTIVE_START_DATE ,
          p_NEW_ACTIVE_START_DATE         => l_account_hist_rec.NEW_ACTIVE_START_DATE ,
          p_OLD_ACTIVE_END_DATE           => l_account_hist_rec.OLD_ACTIVE_END_DATE ,
          p_NEW_ACTIVE_END_DATE           => l_account_hist_rec.NEW_ACTIVE_END_DATE ,
          p_OLD_CONTEXT                   => l_account_hist_rec.OLD_CONTEXT ,
          p_NEW_CONTEXT                   => l_account_hist_rec.NEW_CONTEXT ,
          p_OLD_ATTRIBUTE1                => l_account_hist_rec.OLD_ATTRIBUTE1 ,
          p_NEW_ATTRIBUTE1                => l_account_hist_rec.NEW_ATTRIBUTE1 ,
          p_OLD_ATTRIBUTE2                => l_account_hist_rec.OLD_ATTRIBUTE2 ,
          p_NEW_ATTRIBUTE2                => l_account_hist_rec.NEW_ATTRIBUTE2 ,
          p_OLD_ATTRIBUTE3                => l_account_hist_rec.OLD_ATTRIBUTE3 ,
          p_NEW_ATTRIBUTE3                => l_account_hist_rec.NEW_ATTRIBUTE3 ,
          p_OLD_ATTRIBUTE4                => l_account_hist_rec.OLD_ATTRIBUTE4 ,
          p_NEW_ATTRIBUTE4                => l_account_hist_rec.NEW_ATTRIBUTE4 ,
          p_OLD_ATTRIBUTE5                => l_account_hist_rec.OLD_ATTRIBUTE5 ,
          p_NEW_ATTRIBUTE5                => l_account_hist_rec.NEW_ATTRIBUTE5 ,
          p_OLD_ATTRIBUTE6                => l_account_hist_rec.OLD_ATTRIBUTE6 ,
          p_NEW_ATTRIBUTE6                => l_account_hist_rec.NEW_ATTRIBUTE6 ,
          p_OLD_ATTRIBUTE7                => l_account_hist_rec.OLD_ATTRIBUTE7 ,
          p_NEW_ATTRIBUTE7                => l_account_hist_rec.NEW_ATTRIBUTE7 ,
          p_OLD_ATTRIBUTE8                => l_account_hist_rec.OLD_ATTRIBUTE8 ,
          p_NEW_ATTRIBUTE8                => l_account_hist_rec.NEW_ATTRIBUTE8 ,
          p_OLD_ATTRIBUTE9                => l_account_hist_rec.OLD_ATTRIBUTE9 ,
          p_NEW_ATTRIBUTE9                => l_account_hist_rec.NEW_ATTRIBUTE9 ,
          p_OLD_ATTRIBUTE10               => l_account_hist_rec.OLD_ATTRIBUTE10 ,
          p_NEW_ATTRIBUTE10               => l_account_hist_rec.NEW_ATTRIBUTE10 ,
          p_OLD_ATTRIBUTE11               => l_account_hist_rec.OLD_ATTRIBUTE11 ,
          p_NEW_ATTRIBUTE11               => l_account_hist_rec.NEW_ATTRIBUTE11 ,
          p_OLD_ATTRIBUTE12               => l_account_hist_rec.OLD_ATTRIBUTE12 ,
          p_NEW_ATTRIBUTE12               => l_account_hist_rec.NEW_ATTRIBUTE12 ,
          p_OLD_ATTRIBUTE13               => l_account_hist_rec.OLD_ATTRIBUTE13 ,
          p_NEW_ATTRIBUTE13               => l_account_hist_rec.NEW_ATTRIBUTE13 ,
          p_OLD_ATTRIBUTE14               => l_account_hist_rec.OLD_ATTRIBUTE14 ,
          p_NEW_ATTRIBUTE14               => l_account_hist_rec.NEW_ATTRIBUTE14 ,
          p_OLD_ATTRIBUTE15               => l_account_hist_rec.OLD_ATTRIBUTE15 ,
          p_NEW_ATTRIBUTE15               => l_account_hist_rec.NEW_ATTRIBUTE15 ,
          p_FULL_DUMP_FLAG                => 'N' ,
          p_CREATED_BY                    => FND_GLOBAL.USER_ID ,
          p_CREATION_DATE                 => SYSDATE ,
          p_LAST_UPDATED_BY               => FND_GLOBAL.USER_ID ,
          p_LAST_UPDATE_DATE              => SYSDATE ,
          p_LAST_UPDATE_LOGIN             => FND_GLOBAL.LOGIN_ID ,
          p_OBJECT_VERSION_NUMBER         => 1 ,
          p_OLD_BILL_TO_ADDRESS           => l_account_hist_rec.OLD_BILL_TO_ADDRESS ,
          p_NEW_BILL_TO_ADDRESS           => l_account_hist_rec.NEW_BILL_TO_ADDRESS ,
          p_OLD_SHIP_TO_ADDRESS           => l_account_hist_rec.OLD_SHIP_TO_ADDRESS ,
          p_NEW_SHIP_TO_ADDRESS           => l_account_hist_rec.NEW_SHIP_TO_ADDRESS ,
          p_OLD_INSTANCE_PARTY_ID         => l_account_hist_rec.OLD_INSTANCE_PARTY_ID ,
          p_NEW_INSTANCE_PARTY_ID         => l_account_hist_rec.NEW_INSTANCE_PARTY_ID );

        END IF;
       END;
       -- End of modification for Bug#2547034 on 09/20/02 - rtalluri

    -- Call Contracts
    -- Commented by sguthiva for bug 2307804
    -- End commentation by sguthiva for bug 2307804
    -- Added by sguthiva for bug 2307804
    IF p_party_account_rec.relationship_type_code = 'OWNER'
    THEN
       -- The following code has been written to make sure
       -- before calling contracts we pass a valid vld_organization_id
       IF p_party_account_rec.vld_organization_id IS NULL OR
          p_party_account_rec.vld_organization_id = fnd_api.g_miss_num
       THEN
          BEGIN
             SELECT last_vld_organization_id
             INTO   l_last_vld_org
             FROM   csi_item_instances
             WHERE  instance_id = l_party_rec.instance_id;
          EXCEPTION
             WHEN OTHERS THEN
                NULL;
          END;
       ELSE
          l_last_vld_org := p_party_account_rec.vld_organization_id;
       END IF;
       --
       IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
          csi_gen_utility_pvt.populate_install_param_rec;
       END IF;
       --
       l_internal_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;
       --
       IF l_internal_party_id IS NULL THEN
          FND_MESSAGE.SET_NAME('CSI','CSI_API_UNINSTALLED_PARAMETER');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Commenting as we are not using this code
       /*
       l_old_party_id := null;
       l_new_party_id := null;
       Begin
          select old_party_id,new_party_id
          into l_old_party_id,l_new_party_id
          from CSI_I_PARTIES_H
          where instance_party_id = l_party_rec.instance_party_id
          and   transaction_id = p_txn_rec.transaction_id;
       Exception
          when no_data_found then
             l_old_party_id := null;
             l_new_party_id := null;
       End;
       --
       */
       IF l_old_pty_acct_id IS NOT NULL AND
          l_party_rec.Party_id <> l_internal_party_id -- changed from p_party_account_rec.party_account_id
          AND p_party_account_rec.party_account_id <> l_old_pty_acct_id
          AND p_party_account_rec.party_account_id <> fnd_api.g_miss_num
       THEN
          l_transaction_type := 'TRF';
          l_new_pty_acct_id := p_party_account_rec.party_account_id;
       ELSIF l_old_pty_acct_id IS NULL AND
             l_party_rec.party_id <> l_internal_party_id -- changed from p_party_account_rec.party_account_id
             AND p_party_account_rec.party_account_id IS NOT NULL
             AND p_party_account_rec.party_account_id <> fnd_api.g_miss_num
       THEN
          l_transaction_type := 'NEW';
          l_new_pty_acct_id := NULL;
          /*  ELSIF p_party_account_rec.party_account_id = l_internal_party_id
              OR  ( l_old_pty_acct_id <> l_internal_party_id
                AND p_party_account_rec.active_end_date <= sysdate
                AND p_party_account_rec.active_end_date <> fnd_api.g_miss_date )
            THEN */
          -- srramakr commneted the above code and checked for old and new party ID
       ELSIF /*l_old_party_id IS NOT NULL AND
          l_new_party_id IS NOT NULL AND
          l_old_party_id <> l_internal_party_id AND
          l_new_party_id = l_internal_party_id */
          p_party_account_rec.active_end_date IS NOT NULL AND
          p_party_account_rec.active_end_date <> fnd_api.g_miss_date AND
          p_party_account_rec.active_end_date <= sysdate
      THEN -- external to internal
          IF p_txn_rec.transaction_type_id in (53,54) THEN -- RMA
             l_transaction_type := 'RET';
          ELSE
             l_transaction_type := 'TRM';
          END IF;

          l_old_pty_acct_id := NULL;
          l_new_pty_acct_id := NULL;

          UPDATE csi_item_instances
          SET    owner_party_account_id = NULL
          WHERE  instance_id     = l_party_rec.instance_id;
       END IF;
       --
       IF  l_transaction_type IS NOT NULL AND
           p_party_account_rec.call_contracts <> fnd_api.g_false AND
           p_txn_rec.transaction_type_id <> 7   -- Added for bug 3973706
       THEN
          IF l_transaction_type = 'TRF' THEN
             -- Added the following code for bug 2972082
             IF nvl(p_party_account_rec.cascade_ownership_flag,'N')='Y' THEN
                csi_gen_utility_pvt.put_line('Since the transaction is a cascade ownership call ');
                csi_gen_utility_pvt.put_line('(external to external ownership, component owner is different from parent),');
                csi_gen_utility_pvt.put_line('Hence call contracts with TRM and NEW transaction types. ');
                csi_gen_utility_pvt.put_line( 'Calling contracts with TRM transaction type for instance '||l_party_rec.instance_id);
		csi_item_instance_pvt.Call_to_Contracts(
		         p_transaction_type   =>   'TRM'
		        ,p_instance_id        =>   l_party_rec.instance_id
		        ,p_new_instance_id    =>   NULL
		        ,p_vld_org_id         =>   l_last_vld_org
		        ,p_quantity           =>   NULL
		        ,p_party_account_id1  =>   NULL
		        ,p_party_account_id2  =>   NULL
		        ,p_transaction_date   =>   p_txn_rec.transaction_date -- SYSDATE
			,p_txn_type_id        => p_txn_rec.transaction_type_id  --added for BUG# 5752271
		        ,p_source_transaction_date   =>   p_txn_rec.source_transaction_date
		        ,p_grp_call_contracts =>   p_party_account_rec.grp_call_contracts -- srramakr
                        ,p_oks_txn_inst_tbl   =>   p_oks_txn_inst_tbl
		        ,x_return_status      =>   x_return_status
		        ,x_msg_count          =>   x_msg_count
		        ,x_msg_data           =>   x_msg_data
		         );

                IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                   csi_gen_utility_pvt.put_line('Cascade Ownership - Call to contracts with TRM txn type has errored ');
                   l_msg_index := 1;
                   l_msg_count := x_msg_count;
                   WHILE l_msg_count > 0 LOOP
                     x_msg_data := FND_MSG_PUB.GET(
                                           l_msg_index,
                                           FND_API.G_FALSE   );
                      csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
                      l_msg_index := l_msg_index + 1;
                      l_msg_count := l_msg_count - 1;
                   END LOOP;
                   RAISE FND_API.G_EXC_ERROR;
                END IF;
                csi_gen_utility_pvt.put_line( 'Calling contracts with NEW transaction type for instance '||l_party_rec.instance_id);

		csi_item_instance_pvt.Call_to_Contracts(
		         p_transaction_type   =>   'NEW'
		        ,p_instance_id        =>   l_party_rec.instance_id
		        ,p_new_instance_id    =>   NULL
		        ,p_vld_org_id         =>   l_last_vld_org
		        ,p_quantity           =>   NULL
		        ,p_party_account_id1  =>   NULL
		        ,p_party_account_id2  =>   NULL
		        ,p_transaction_date   =>   p_txn_rec.transaction_date -- SYSDATE
		        ,p_source_transaction_date   =>   p_txn_rec.source_transaction_date -- SYSDATE
		        ,p_grp_call_contracts =>   p_party_account_rec.grp_call_contracts -- srramakr
			,p_txn_type_id        => p_txn_rec.transaction_type_id  --added for BUG# 5752271
                        ,p_oks_txn_inst_tbl   =>   p_oks_txn_inst_tbl
		        ,x_return_status      =>   x_return_status
		        ,x_msg_count          =>   x_msg_count
		        ,x_msg_data           =>   x_msg_data
		         );
                IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                   csi_gen_utility_pvt.put_line('Cascade Ownership - Call to contracts with NEW txn type has errored ');
                   l_msg_index := 1;
                   l_msg_count := x_msg_count;
                   WHILE l_msg_count > 0 LOOP
                     x_msg_data := FND_MSG_PUB.GET(
                                           l_msg_index,
                                           FND_API.G_FALSE   );
                      csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
                      l_msg_index := l_msg_index + 1;
                      l_msg_count := l_msg_count - 1;
                   END LOOP;
                   RAISE FND_API.G_EXC_ERROR;
                END IF;
                -- End addition for bug 2972082
             ELSE
		csi_item_instance_pvt.Call_to_Contracts(
		         p_transaction_type   =>   l_transaction_type
		        ,p_instance_id        =>   l_party_rec.instance_id
		        ,p_new_instance_id    =>   NULL
		        ,p_vld_org_id         =>   l_last_vld_org
		        ,p_quantity           =>   NULL
		        ,p_party_account_id1  =>   l_old_pty_acct_id
		        ,p_party_account_id2  =>   l_new_pty_acct_id
		        ,p_transaction_date   =>   p_txn_rec.transaction_date       -- added by sguthiva
		        ,p_source_transaction_date   =>   p_txn_rec.source_transaction_date       -- added by jpwilson
		        ,p_transaction_id     =>   p_txn_rec.transaction_id
		        ,p_grp_call_contracts =>   p_party_account_rec.grp_call_contracts -- srramakr
			,p_txn_type_id        => p_txn_rec.transaction_type_id  --added for BUG# 5752271
		        ,p_system_id          =>   p_party_account_rec.system_id
                        ,p_oks_txn_inst_tbl   =>   p_oks_txn_inst_tbl
		        ,x_return_status      =>   x_return_status
		        ,x_msg_count          =>   x_msg_count
		        ,x_msg_data           =>   x_msg_data
		         );
             END IF;
	  ELSE
	     csi_item_instance_pvt.Call_to_Contracts(
		      p_transaction_type   =>   l_transaction_type
		     ,p_instance_id        =>   l_party_rec.instance_id
		     ,p_new_instance_id    =>   NULL
		     ,p_vld_org_id         =>   l_last_vld_org
		     ,p_quantity           =>   NULL
		     ,p_party_account_id1  =>   l_old_pty_acct_id
		     ,p_party_account_id2  =>   l_new_pty_acct_id
		     ,p_transaction_date   =>   p_txn_rec.transaction_date -- SYSDATE
		     ,p_source_transaction_date   =>   p_txn_rec.source_transaction_date
		     ,p_grp_call_contracts =>   p_party_account_rec.grp_call_contracts -- srramakr
                     ,p_oks_txn_inst_tbl   =>   p_oks_txn_inst_tbl
		     ,x_return_status      =>   x_return_status
		     ,x_msg_count          =>   x_msg_count
		     ,x_msg_data           =>   x_msg_data
		      );
		  END IF;
	     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		l_msg_index := 1;
		l_msg_count := x_msg_count;
		WHILE l_msg_count > 0 LOOP
			x_msg_data := FND_MSG_PUB.GET(
					       l_msg_index,
					       FND_API.G_FALSE   );
			csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
			l_msg_index := l_msg_index + 1;
			l_msg_count := l_msg_count - 1;
		END LOOP;
		RAISE FND_API.G_EXC_ERROR;
             END IF;
          END IF;
       END IF;
       -- End addition by sguthiva for bug 2307804
       --
       -- End of API body
       -- Standard check of p_commit.
       IF FND_API.To_Boolean( p_commit ) THEN
          COMMIT WORK;
       END IF;
       -- Standard call to get message count and if count is  get message info.
       FND_MSG_PUB.Count_And_Get
                (p_count        =>      x_msg_count ,
                 p_data         =>      x_msg_data  );
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                -- ROLLBACK TO update_inst_party_acct_pvt;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count    =>      x_msg_count,
                        p_data     =>      x_msg_data  );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                -- ROLLBACK TO update_inst_party_acct_pvt;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count  =>      x_msg_count,
                        p_data   =>      x_msg_data );
        WHEN OTHERS THEN
                -- ROLLBACK TO update_inst_party_acct_pvt;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF FND_MSG_PUB.Check_Msg_Level
                     (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                   FND_MSG_PUB.Add_Exc_Msg
                    ( g_pkg_name, l_api_name );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_count   =>      x_msg_count,
                        p_data    =>      x_msg_data );
END update_inst_party_account ;

/*--------------------------------------------------------------*/
/* Procedure name: Expire_inst_party_account                    */
/* Description :  Procedure used to expire an existing          */
/*                    instance-party account relationships      */
/*--------------------------------------------------------------*/

PROCEDURE expire_inst_party_account
 (    p_api_version                 IN  NUMBER
     ,p_commit                      IN  VARCHAR2
     ,p_init_msg_list               IN  VARCHAR2
     ,p_validation_level            IN  NUMBER
     ,p_party_account_rec           IN  csi_datastructures_pub.party_account_rec
     ,p_txn_rec                     IN OUT NOCOPY  csi_datastructures_pub.transaction_rec
     ,x_return_status               OUT NOCOPY  VARCHAR2
     ,x_msg_count                   OUT NOCOPY  NUMBER
     ,x_msg_data                    OUT NOCOPY  VARCHAR2
    ) IS

     l_api_name      CONSTANT VARCHAR2(30)   :=  'EXPIRE_INST_PARTY_ACCOUNT';
     l_api_version   CONSTANT NUMBER         :=  1.0;
     l_csi_debug_level        NUMBER;
     l_party_account_rec      csi_datastructures_pub.party_account_rec;
    --  l_curr_party_acct_rec    csi_datastructures_pub.party_account_rec;
     l_msg_count              NUMBER;
     l_msg_data               VARCHAR2(100);
     l_txn_id                 NUMBER;
     l_msg_index              NUMBER;
     l_OBJECT_VERSION_NUMBER  NUMBER;
     x_msg_index_out          NUMBER;
     l_ip_account_history_id  NUMBER;
     l_full_dump_frequency    NUMBER;
     l_mod_value              NUMBER;
     --
     px_oks_txn_inst_tbl      oks_ibint_pub.txn_instance_tbl;

  CURSOR get_curr_party_acct_rec (p_ip_account_id   IN  NUMBER) IS
   SELECT
     ip_account_id                    ,
     FND_API.G_MISS_NUM parent_tbl_index,
     instance_party_id                ,
     party_account_id                 ,
     relationship_type_code           ,
     bill_to_address                  ,
     ship_to_address                  ,
     active_start_date                ,
     active_end_date                  ,
     context                          ,
     attribute1                       ,
     attribute2                       ,
     attribute3                       ,
     attribute4                       ,
     attribute5                       ,
     attribute6                       ,
     attribute7                       ,
     attribute8                       ,
     attribute9                       ,
     attribute10                      ,
     attribute11                      ,
     attribute12                      ,
     attribute13                      ,
     attribute14                      ,
     attribute15                      ,
     object_version_number
   FROM CSI_IP_ACCOUNTS
   WHERE IP_ACCOUNT_ID = p_ip_account_id
   AND (( ACTIVE_END_DATE IS NULL) OR (ACTIVE_END_DATE >= SYSDATE))
   FOR UPDATE OF OBJECT_VERSION_NUMBER;

   l_curr_party_acct_rec    get_curr_party_acct_rec%ROWTYPE;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  expire_inst_party_acct_pvt;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (    l_api_version           ,
					   p_api_version           ,
					   l_api_name              ,
					   g_pkg_name              )
   THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
	   FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Check the profile option CSI_DEBUG_LEVEL for debug message reporting
   l_csi_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If CSI_DEBUG_LEVEL = 1 then dump the procedure name
   IF (l_csi_debug_level > 0) THEN
       csi_gen_utility_pvt.put_line( 'expire_inst_party_account');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (l_csi_debug_level > 1) THEN
	 csi_gen_utility_pvt.put_line( 'expire_inst_party_account:'||
					 p_api_version           ||'-'||
					 p_commit                ||'-'||
					 p_init_msg_list              );


       -- Dump the records in the log file
       csi_gen_utility_pvt.dump_party_account_rec(p_party_account_rec);
       csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
   END IF;
   -- Start API body
   --
   -- Check if all the required parameters are passed
   CSI_Instance_parties_vld_pvt.Check_Reqd_Param_num
	 (    p_party_account_rec.ip_account_id,
	      '  p_party_account_rec.ip_account_id ',
	      l_api_name                 );

   CSI_Instance_parties_vld_pvt.Check_Reqd_Param_num
	 (   p_party_account_rec.object_version_number,
	       ' p_party_account_rec.object_version_number ',
		 l_api_name                 );


   -- Check if the instance party id  is valid
   IF NOT(CSI_Instance_parties_vld_pvt.Is_Ip_account_Valid
	       (p_party_account_rec.ip_account_id))THEN
	      FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_IP_ACCOUNT_ID');
	      FND_MESSAGE.SET_TOKEN('IP_ACCOUNT_ID',p_party_account_rec.ip_account_id);
	      FND_MSG_PUB.Add;
	 RAISE FND_API.G_EXC_ERROR;
   END IF;
   -- check if the object_version_number passed matches with the one
   -- in the database else raise error
   OPEN get_curr_party_acct_rec(p_party_account_rec.ip_account_id);
   FETCH get_curr_party_acct_rec INTO l_curr_party_acct_rec;

   IF  (l_curr_party_acct_rec.object_version_number <> p_party_account_rec.OBJECT_VERSION_NUMBER) THEN
       FND_MESSAGE.Set_Name('CSI', 'CSI_API_OBJ_VER_MISMATCH');
       FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   --
   IF get_curr_party_acct_rec%NOTFOUND THEN
      FND_MESSAGE.Set_Name('CSI', 'CSI_API_RECORD_LOCKED');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE get_curr_party_acct_rec;
   -- Initialize all the parameters and call upate_inst_party_account to expire the record

   l_party_account_rec.IP_ACCOUNT_ID      := l_curr_party_acct_rec.ip_account_id;
   l_party_account_rec.INSTANCE_PARTY_ID := FND_API.G_MISS_NUM;
   l_party_account_rec.PARTY_ACCOUNT_ID := l_curr_party_acct_rec.party_account_id; -- Added by sguthiva for bug 2307804
   l_party_account_rec.RELATIONSHIP_TYPE_CODE := l_curr_party_acct_rec.relationship_type_code;-- Added by sguthiva for bug 2307804          l_party_account_rec.ACTIVE_START_DATE   := FND_API.G_MISS_DATE;
    -- Bug 3804960
    -- srramakr Need to use the same the date used by the item instance
    IF p_txn_rec.src_txn_creation_date IS NULL OR
       p_txn_rec.src_txn_creation_date = FND_API.G_MISS_DATE THEN
       l_party_account_rec.active_end_date := sysdate;
    ELSE
       l_party_account_rec.active_end_date := p_txn_rec.src_txn_creation_date;
    END IF;
    -- End of 3804960
    l_party_account_rec.CONTEXT       := FND_API.G_MISS_CHAR;
    l_party_account_rec.ATTRIBUTE1    := FND_API.G_MISS_CHAR;
    l_party_account_rec.ATTRIBUTE2    := FND_API.G_MISS_CHAR;
    l_party_account_rec.ATTRIBUTE3    := FND_API.G_MISS_CHAR;
    l_party_account_rec.ATTRIBUTE4    := FND_API.G_MISS_CHAR;
    l_party_account_rec.ATTRIBUTE5    := FND_API.G_MISS_CHAR;
    l_party_account_rec.ATTRIBUTE6    := FND_API.G_MISS_CHAR;
    l_party_account_rec.ATTRIBUTE7    := FND_API.G_MISS_CHAR;
    l_party_account_rec.ATTRIBUTE8    := FND_API.G_MISS_CHAR;
    l_party_account_rec.ATTRIBUTE9    := FND_API.G_MISS_CHAR;
    l_party_account_rec.ATTRIBUTE10   := FND_API.G_MISS_CHAR;
    l_party_account_rec.ATTRIBUTE11   := FND_API.G_MISS_CHAR;
    l_party_account_rec.ATTRIBUTE12   := FND_API.G_MISS_CHAR;
    l_party_account_rec.ATTRIBUTE13   := FND_API.G_MISS_CHAR;
    l_party_account_rec.ATTRIBUTE14   := FND_API.G_MISS_CHAR;
    l_party_account_rec.ATTRIBUTE15   := FND_API.G_MISS_CHAR;
    l_party_account_rec.BILL_TO_ADDRESS := FND_API.G_MISS_NUM;
    l_party_account_rec.SHIP_TO_ADDRESS := FND_API.G_MISS_NUM;
    l_party_account_rec.OBJECT_VERSION_NUMBER := p_party_account_rec.OBJECT_VERSION_NUMBER;
    l_party_account_rec.expire_flag := p_party_account_rec.expire_flag; -- Added by sguthiva for bug 2307804
    l_party_account_rec.call_contracts := p_party_account_rec.call_contracts; -- Added by sguthiva for bug 2307804
    -- g_expire_account_flag    := 'Y'; -- Added by sguthiva for bug 2307804
    --
    update_inst_party_account
	(  p_api_version         => p_api_version
	  ,p_commit              => p_commit
	  ,p_init_msg_list       => p_init_msg_list
	  ,p_validation_level    => p_validation_level
	  ,p_party_account_rec   => l_party_account_rec
	  ,p_txn_rec             => p_txn_rec
	  ,p_oks_txn_inst_tbl    => px_oks_txn_inst_tbl
	  ,x_return_status       => x_return_status
	  ,x_msg_count           => x_msg_count
	  ,x_msg_data            => x_msg_data);
    --
    --g_expire_account_flag    := 'N';  -- Added by sguthiva for bug 2307804
    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
       l_msg_index := 1;
       l_msg_count := x_msg_count;
       WHILE l_msg_count > 0 LOOP
	    x_msg_data := FND_MSG_PUB.GET(
					 l_msg_index,
					 FND_API.G_FALSE 	);
	    csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
	    l_msg_index := l_msg_index + 1;
	    l_msg_count := l_msg_count - 1;
       END LOOP;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    --
    -- Commented the tablehandler call since Update API got invoked
    --
    -- End of API body
    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get
                (p_count        =>      x_msg_count ,
                 p_data         =>      x_msg_data );
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO expire_inst_party_acct_pvt;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count   =>      x_msg_count,
                        p_data    =>      x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO expire_inst_party_acct_pvt;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count  =>      x_msg_count,
                        p_data   =>      x_msg_data );
        WHEN OTHERS THEN
                ROLLBACK TO expire_inst_party_acct_pvt;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF FND_MSG_PUB.Check_Msg_Level
                     (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                   FND_MSG_PUB.Add_Exc_Msg
                    ( g_pkg_name, l_api_name );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_count   =>      x_msg_count,
                        p_data    =>      x_msg_data  );
END expire_inst_party_account ;


/*------------------------------------------------------------*/
/* Procedure name: get_contact_details                        */
/* Description :  Get the details of a contact party          */
/*------------------------------------------------------------*/

PROCEDURE get_contact_details
 (
      p_api_version                 IN  NUMBER
     ,p_commit                      IN  VARCHAR2
     ,p_init_msg_list               IN  VARCHAR2
     ,p_validation_level            IN  NUMBER
     ,p_contact_party_id            IN  NUMBER
     ,p_contact_flag                IN  VARCHAR2
     ,p_party_tbl                   IN  VARCHAR2
     ,x_contact_details             OUT NOCOPY  csi_datastructures_pub.contact_details_rec
     ,x_return_status               OUT NOCOPY  VARCHAR2
     ,x_msg_count                   OUT NOCOPY  NUMBER
     ,x_msg_data                    OUT NOCOPY  VARCHAR2
    ) IS

     l_api_name      CONSTANT VARCHAR2(30)   :=  'GET_CONTACT_DETAILS_PVT';
     l_api_version   CONSTANT NUMBER         :=  1.0;
     l_csi_debug_level        NUMBER;


BEGIN
        -- Standard Start of API savepoint
        -- SAVEPOINT  get_contact_details_pvt;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (    l_api_version           ,
                                                p_api_version           ,
                                                l_api_name              ,
                                                g_pkg_name              )
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Check the profile option CSI_DEBUG_LEVEL for debug message reporting
        l_csi_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

        -- If CSI_DEBUG_LEVEL = 1 then dump the procedure name
        IF (l_csi_debug_level > 0) THEN
            csi_gen_utility_pvt.put_line( 'get_contact_details');
        END IF;


        -- Start API body

        IF (   ( p_contact_party_id IS NULL OR p_contact_party_id = fnd_api.g_miss_num )
            OR ( p_party_tbl IS NULL OR p_party_tbl = fnd_api.g_miss_char )
           )
        THEN
            fnd_message.set_name('CSI', 'CSI_API_INVALID_PARAMETERS');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE fnd_api.g_exc_error;
        END IF;


        IF upper(p_party_tbl) = 'HZ_PARTIES'
        THEN
           BEGIN

              SELECT   hp.party_name party_name,

                decode( hcp_wp.phone_country_code, null, null, hcp_wp.phone_country_code || '-'
    )
             || decode( hcp_wp.phone_area_code, null, null, '(' || hcp_wp.phone_Area_code || ')'
    )
             || hcp_wp.phone_number
             || decode( hcp_wp.phone_extension, null, null, ' x'|| hcp_wp.phone_extension)
    work_phone_number,

                decode( hcp_hp.phone_country_code, null, null, hcp_hp.phone_country_code || '-'
    )
             || decode( hcp_hp.phone_area_code, null, null, '(' || hcp_hp.phone_Area_code || ')'
    )
             || hcp_hp.phone_number
             || decode( hcp_hp.phone_extension, null, null, ' x'|| hcp_hp.phone_extension)
    home_phone_number,

                decode( hcp_mb.phone_country_code, null, null, hcp_mb.phone_country_code || '-'
    )
             || decode( hcp_mb.phone_area_code, null, null, '(' || hcp_mb.phone_Area_code || ')'
    )
             || hcp_mb.phone_number
             || decode( hcp_mb.phone_extension, null, null, ' x'|| hcp_mb.phone_extension)
    mobile_number,

                decode( hcp_pg.phone_country_code, null, null, hcp_pg.phone_country_code || '-'
    )
             || decode( hcp_pg.phone_area_code, null, null, '(' || hcp_pg.phone_Area_code || ')'
    )
             || hcp_pg.phone_number
             || decode( hcp_pg.phone_extension, null, null, ' x'|| hcp_pg.phone_extension)
    pager_number,

                decode( hcp_fx.phone_country_code, null, null, hcp_fx.phone_country_code || '-'
    )
             || decode( hcp_fx.phone_area_code, null, null, '(' || hcp_fx.phone_Area_code || ')'
    )
             || hcp_fx.phone_number
             || decode( hcp_fx.phone_extension, null, null, ' x'|| hcp_fx.phone_extension)
    fax_number,

                HP.ADDRESS1, HP.ADDRESS2, HP.ADDRESS3, HP.ADDRESS4, HP.CITY, HP.POSTAL_CODE,
                HP.STATE, HP.COUNTRY,
                hcp_em.email_address

            INTO   x_contact_details.party_name,
                   x_contact_details.officephone,
                   x_contact_details.homephone,
                   x_contact_details.mobile,
                   x_contact_details.page,
                   x_contact_details.fax,
                   x_contact_details.address1,
                   x_contact_details.address2,
                   x_contact_details.address3,
                   x_contact_details.address4,
                   x_contact_details.city,
                   x_contact_details.postal_code,
                   x_contact_details.state,
                   x_contact_details.country,
                   x_contact_details.email

             FROM
                   HZ_PARTIES HP,
                   CSI_I_PARTIES CIP,
                 --  CSI_IPA_RELATION_TYPES CIR,
                   HZ_CONTACT_POINTS HCP_WP,
                   HZ_CONTACT_POINTS HCP_HP,
                   HZ_CONTACT_POINTS HCP_PG,
                   HZ_CONTACT_POINTS HCP_EM,
                   HZ_CONTACT_POINTS HCP_FX,
                   HZ_CONTACT_POINTS HCP_MB,
                 --  CSI_LOOKUPS CL,
                   HZ_RELATIONSHIPS HR,
                   CSI_I_PARTIES CIPO
             WHERE CIP.INSTANCE_PARTY_ID =  p_contact_party_id -- party_id for the contact
               AND CIP.PARTY_ID = HR.SUBJECT_ID
               AND CIP.CONTACT_IP_ID = CIPO.INSTANCE_PARTY_ID
               AND CIPO.PARTY_ID = HR.OBJECT_ID
               AND HR.SUBJECT_ID = HP.PARTY_ID
               AND CIP.CONTACT_FLAG = 'Y'
               AND CIP.PARTY_SOURCE_TABLE = 'HZ_PARTIES'
            --   AND CIP.RELATIONSHIP_TYPE_CODE = CIR.IPA_RELATION_TYPE_CODE(+)
            --   AND CL.LOOKUP_CODE(+) = CIP.PARTY_SOURCE_TABLE
               AND HR.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
               AND HR.OBJECT_TABLE_NAME = 'HZ_PARTIES'

               AND HCP_WP.OWNER_TABLE_NAME(+) = 'HZ_PARTIES'
               AND HCP_WP.OWNER_TABLE_ID(+) = HR.PARTY_ID
               AND HCP_WP.CONTACT_POINT_TYPE(+) = 'PHONE'
               AND HCP_WP.PHONE_LINE_TYPE(+) = 'GEN'
               AND HCP_WP.CONTACT_POINT_PURPOSE(+) = 'BUSINESS'

               AND HCP_HP.OWNER_TABLE_NAME(+) = 'HZ_PARTIES'
               AND HCP_HP.OWNER_TABLE_ID(+) = HR.PARTY_ID
               AND HCP_HP.CONTACT_POINT_TYPE(+) = 'PHONE'
               AND HCP_HP.PHONE_LINE_TYPE(+) = 'GEN'
               AND HCP_HP.CONTACT_POINT_PURPOSE(+) = 'PERSONAL'

               AND HCP_MB.OWNER_TABLE_NAME(+) = 'HZ_PARTIES'
               AND HCP_MB.OWNER_TABLE_ID(+) = HR.PARTY_ID
               AND HCP_MB.CONTACT_POINT_TYPE(+) = 'PHONE'
               AND HCP_MB.PHONE_LINE_TYPE(+) = 'MOBILE'
               AND HCP_MB.CONTACT_POINT_PURPOSE(+) = 'BUSINESS'

               AND HCP_PG.OWNER_TABLE_NAME(+) = 'HZ_PARTIES'
               AND HCP_PG.OWNER_TABLE_ID(+) = HR.PARTY_ID
               AND HCP_PG.CONTACT_POINT_TYPE(+) = 'PHONE'
               AND HCP_PG.PHONE_LINE_TYPE(+) = 'PAGER'
               AND HCP_PG.CONTACT_POINT_PURPOSE(+) = 'BUSINESS'

               AND HCP_FX.OWNER_TABLE_NAME(+) = 'HZ_PARTIES'
               AND HCP_FX.OWNER_TABLE_ID(+) = HR.PARTY_ID
               AND HCP_FX.CONTACT_POINT_TYPE(+) = 'PHONE'
               AND HCP_FX.PHONE_LINE_TYPE(+) = 'FAX'
               AND HCP_FX.CONTACT_POINT_PURPOSE(+) = 'BUSINESS'

               AND HCP_EM.OWNER_TABLE_NAME(+) = 'HZ_PARTIES'
               AND HCP_EM.OWNER_TABLE_ID(+) = HR.PARTY_ID
               AND HCP_EM.CONTACT_POINT_TYPE(+) = 'EMAIL'
               AND HCP_EM.PRIMARY_FLAG(+) = 'Y'
               AND ROWNUM < 2;
           EXCEPTION
               WHEN NO_DATA_FOUND THEN
                NULL;
           END;


        ELSIF upper(p_party_tbl) = 'PO_VENDORS'
        THEN
           IF p_contact_flag = 'Y' THEN
              BEGIN

                SELECT   PVC.PREFIX || ' ' || PVC.FIRST_NAME || ' ' || PVC.MIDDLE_NAME || ' '|| PVC.LAST_NAME PARTY_NAME,
                         PVC.area_code||'-'||PVC.phone, --WORKPHONE,
                         NULL, --HOMEPHONE
                         NULL, --MOBILE
                         NULL, --PAGE
                         NULL, --FAX,
                         PVS.ADDRESS_LINE1 ADDRESS1, --address_line1
                         PVS.ADDRESS_LINE2 ADDRESS2, --address_line2
                         PVS.ADDRESS_LINE3 ADDRESS3, --address_line3
                         NULL, --address_line4
                         PVS.CITY, --city,
                         PVS.ZIP POSTAL_CODE, --zip
                         PVS.STATE STATE, --state
                         PVS.COUNTRY COUNTRY, --country
                         PVC.mail_stop --EMAIL ADDRESS
                 INTO    x_contact_details.party_name,
                         x_contact_details.officephone,
                         x_contact_details.homephone,
                         x_contact_details.mobile,
                         x_contact_details.page,
                         x_contact_details.fax,
                         x_contact_details.address1,
                         x_contact_details.address2,
                         x_contact_details.address3,
                         x_contact_details.address4,
                         x_contact_details.city,
                         x_contact_details.postal_code,
                         x_contact_details.state,
                         x_contact_details.country,
                         x_contact_details.email
                 FROM    CSI_I_PARTIES CIP,
                         PO_VENDOR_CONTACTS PVC,
                         PO_VENDOR_SITES_ALL PVS
                 WHERE   CIP.INSTANCE_PARTY_ID = p_contact_party_id
                   AND   CIP.PARTY_ID = PVC.VENDOR_CONTACT_ID
                   AND   PVS.VENDOR_SITE_ID = PVC.VENDOR_SITE_ID
                 AND     rownum < 2;
              EXCEPTION
               WHEN NO_DATA_FOUND THEN
                NULL;
              END;
            END IF;

        ELSIF upper(p_party_tbl) = 'EMPLOYEE'
        THEN
              BEGIN
                 SELECT  distinct PAP.full_name, --PARTY NAME
                         PAP.work_telephone, --WORK PHONE
                         NULL , -- HOME_PHONE_NUMBER
                         NULL , --MOBILE
                         NULL , --PAGE
                         NULL , --FAX
                         NULL , --ADDRESS1
                         NULL , --ADDRESS2
                         NULL , --ADDRESS3
                         NULL , --ADDRESS4
                         NULL , --CITY
                         NULL , --POSTAL CODE
                         NULL , --STATE
                         NULL , --COUNTRY
                         PAP.email_address --EMAIL
                 INTO    x_contact_details.party_name,
                         x_contact_details.officephone,
                         x_contact_details.homephone,
                         x_contact_details.mobile,
                         x_contact_details.page,
                         x_contact_details.fax,
                         x_contact_details.address1,
                         x_contact_details.address2,
                         x_contact_details.address3,
                         x_contact_details.address4,
                         x_contact_details.city,
                         x_contact_details.postal_code,
                         x_contact_details.state,
                         x_contact_details.country,
                         x_contact_details.email
                  FROM   CSI_I_PARTIES CIP,
                         PER_ALL_PEOPLE_F PAP
                  WHERE  CIP.INSTANCE_PARTY_ID = p_contact_party_id
                  AND    CIP.PARTY_ID = PAP.PERSON_ID
                  AND    PAP.EFFECTIVE_START_DATE <= SYSDATE
                  AND    PAP.EFFECTIVE_END_DATE >= SYSDATE
                  AND    rownum < 2;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                 NULL;
              END;

        ELSIF upper(p_party_tbl) = 'GROUP'
        THEN
            BEGIN
               SELECT    distinct JG.group_name,
                         NULL , --WORK PHONE
                         NULL , --HOME_PHONE_NUMBER
                         NULL , --MOBILE
                         NULL , --PAGE
                         NULL , --FAX
                         NULL , --ADDRESS1
                         NULL , --ADDRESS2
                         NULL , --ADDRESS3
                         NULL , --ADDRESS4
                         NULL , --CITY
                         NULL , --POSTAL CODE
                         NULL , --STATE
                         NULL , --COUNTRY
                         JG.email_address --EMAIL
                 INTO    x_contact_details.party_name,
                         x_contact_details.officephone,
                         x_contact_details.homephone,
                         x_contact_details.mobile,
                         x_contact_details.page,
                         x_contact_details.fax,
                         x_contact_details.address1,
                         x_contact_details.address2,
                         x_contact_details.address3,
                         x_contact_details.address4,
                         x_contact_details.city,
                         x_contact_details.postal_code,
                         x_contact_details.state,
                         x_contact_details.country,
                         x_contact_details.email
                  FROM   CSI_I_PARTIES CIP,
                         JTF_RS_GROUPS_VL JG
                  WHERE  CIP.INSTANCE_PARTY_ID = p_contact_party_id
                    AND  CIP.PARTY_ID = JG.GROUP_ID
                    AND  rownum < 2;
              EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                   NULL;
              END;

        ELSIF upper(p_party_tbl) = 'TEAM'
        THEN
            BEGIN
               SELECT    distinct JT.TEAM_NAME,
                         NULL , --WORK PHONE
                         NULL , --HOME_PHONE_NUMBER
                         NULL , --MOBILE
                         NULL , --PAGE
                         NULL , --FAX
                         NULL , --ADDRESS1
                         NULL , --ADDRESS2
                         NULL , --ADDRESS3
                         NULL , --ADDRESS4
                         NULL , --CITY
                         NULL , --POSTAL CODE
                         NULL , --STATE
                         NULL , --COUNTRY
                         JT.email_address --EMAIL
                 INTO    x_contact_details.party_name,
                         x_contact_details.officephone,
                         x_contact_details.homephone,
                         x_contact_details.mobile,
                         x_contact_details.page,
                         x_contact_details.fax,
                         x_contact_details.address1,
                         x_contact_details.address2,
                         x_contact_details.address3,
                         x_contact_details.address4,
                         x_contact_details.city,
                         x_contact_details.postal_code,
                         x_contact_details.state,
                         x_contact_details.country,
                         x_contact_details.email
                 FROM    CSI_I_PARTIES CIP,
                         JTF_RS_TEAMS_VL JT
                 WHERE   CIP.INSTANCE_PARTY_ID = p_contact_party_id
                 AND     CIP.PARTY_ID = JT.TEAM_ID
                 AND     rownum < 2;
             EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                  NULL;
             END;
        END IF;
        x_contact_details.contact_party_id := p_contact_party_id;
        --
        -- End of API body

        -- Standard check of p_commit.
        /*
        IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
        END IF;
        */

        -- Standard call to get message count and if count is  get message info.
        FND_MSG_PUB.Count_And_Get
                (p_count        =>      x_msg_count ,
                 p_data         =>      x_msg_data );
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
              --  ROLLBACK TO get_contact_details_pvt;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count   =>      x_msg_count,
                        p_data    =>      x_msg_data );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              --  ROLLBACK TO get_contact_details_pvt;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count  =>      x_msg_count,
                        p_data   =>      x_msg_data );
        WHEN OTHERS THEN
              --  ROLLBACK TO get_contact_details_pvt;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF FND_MSG_PUB.Check_Msg_Level
                     (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                   FND_MSG_PUB.Add_Exc_Msg
                    ( g_pkg_name, l_api_name );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_count   =>      x_msg_count,
                        p_data    =>      x_msg_data  );

END get_contact_details ;



/*------------------------------------------------------------*/
/* Procedure name:  get_inst_party_rel_hist                   */
/* Description :   Procedure used to  get party relationships */
/*                  from history given a transaction_id       */
/*------------------------------------------------------------*/

PROCEDURE get_inst_party_rel_hist
 (    p_api_version             IN  NUMBER
     ,p_commit                  IN  VARCHAR2
     ,p_init_msg_list           IN  VARCHAR2
     ,p_validation_level        IN  NUMBER
     ,p_transaction_id          IN  NUMBER
     ,x_party_history_tbl       OUT NOCOPY  csi_datastructures_pub.party_history_tbl
     ,x_return_status           OUT NOCOPY  VARCHAR2
     ,x_msg_count               OUT NOCOPY  NUMBER
     ,x_msg_data                OUT NOCOPY  VARCHAR2
    ) IS

     l_api_name      CONSTANT VARCHAR2(30)   := 'GET_INST_PARTY_REL_HIST' ;
     l_api_version   CONSTANT NUMBER         := 1.0                       ;
     l_csi_debug_level        NUMBER                                      ;
     x_msg_index_out          NUMBER;
     l_count                  NUMBER         := 0                         ;
     l_flag                   VARCHAR2(1)  :='N'                          ;
     l_instance_party_id      NUMBER                                          ;
     l_old_contact_party_id       NUMBER                                          ;
     l_new_contact_party_id       NUMBER                                      ;
     l_contact_details        csi_datastructures_pub.contact_details_rec ;
     i                       NUMBER :=1;
     l_old_party_source_tbl  VARCHAR2(30);
     l_new_party_source_tbl  VARCHAR2(30);
     l_old_contact_flag      VARCHAR2(1);
     l_new_contact_flag      VARCHAR2(1);



     CURSOR get_party_hist(i_transaction_id NUMBER)
     IS
     SELECT   ciph.INSTANCE_PARTY_ID,
              ciph.INSTANCE_PARTY_HISTORY_ID,
              ciph.TRANSACTION_ID,
              ciph.OLD_PARTY_SOURCE_TABLE,
              ciph.NEW_PARTY_SOURCE_TABLE,
              ciph.OLD_PARTY_ID,
              ciph.NEW_PARTY_ID,
              ciph.OLD_RELATIONSHIP_TYPE_CODE,
              ciph.NEW_RELATIONSHIP_TYPE_CODE,
              ciph.OLD_CONTACT_FLAG,
              ciph.NEW_CONTACT_FLAG,
              ciph.OLD_CONTACT_IP_ID,
              ciph.NEW_CONTACT_IP_ID,
              ciph.OLD_ACTIVE_START_DATE,
              ciph.NEW_ACTIVE_START_DATE,
              ciph.OLD_ACTIVE_END_DATE,
              ciph.NEW_ACTIVE_END_DATE,
              ciph.OLD_CONTEXT,
              ciph.NEW_CONTEXT,
              ciph.OLD_ATTRIBUTE1,
              ciph.NEW_ATTRIBUTE1,
              ciph.OLD_ATTRIBUTE2,
              ciph.NEW_ATTRIBUTE2,
              ciph.OLD_ATTRIBUTE3,
              ciph.NEW_ATTRIBUTE3,
              ciph.OLD_ATTRIBUTE4,
              ciph.NEW_ATTRIBUTE4,
              ciph.OLD_ATTRIBUTE5,
              ciph.NEW_ATTRIBUTE5,
              ciph.OLD_ATTRIBUTE6,
              ciph.NEW_ATTRIBUTE6,
              ciph.OLD_ATTRIBUTE7,
              ciph.NEW_ATTRIBUTE7,
              ciph.OLD_ATTRIBUTE8,
              ciph.NEW_ATTRIBUTE8,
              ciph.OLD_ATTRIBUTE9,
              ciph.NEW_ATTRIBUTE9,
              ciph.OLD_ATTRIBUTE10,
              ciph.NEW_ATTRIBUTE10,
              ciph.OLD_ATTRIBUTE11,
              ciph.NEW_ATTRIBUTE11,
              ciph.OLD_ATTRIBUTE12,
              ciph.NEW_ATTRIBUTE12,
              ciph.OLD_ATTRIBUTE13,
              ciph.NEW_ATTRIBUTE13,
              ciph.OLD_ATTRIBUTE14,
              ciph.NEW_ATTRIBUTE14,
              ciph.OLD_ATTRIBUTE15,
              ciph.NEW_ATTRIBUTE15,
              ciph.FULL_DUMP_FLAG,
              ciph.OBJECT_VERSION_NUMBER,
              ciph.OLD_PREFERRED_FLAG,
              ciph.NEW_PREFERRED_FLAG,
              ciph.OLD_PRIMARY_FLAG,
              ciph.NEW_PRIMARY_FLAG,
              cip.INSTANCE_ID,
              ciph.creation_date  --Added for bug 2781480
     FROM     csi_i_parties_h ciph,
              csi_i_parties cip
     WHERE    ciph.transaction_id = i_transaction_id
     AND      ciph.instance_party_id = cip.instance_party_id; -- Added by sk on 08-APR for fixing bug
                                                              -- 2304649 .
-- Added for bug 2781480
l_time_stamp          DATE;
l_party_query_rec     csi_datastructures_pub.party_query_rec;
l_party_header_tbl    csi_datastructures_pub.party_header_tbl;
-- End addition for bug 2781480
BEGIN
        -- Standard Start of API savepoint
     --   SAVEPOINT   get_inst_party_rel_hist;


        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (    l_api_version           ,
                                                p_api_version           ,
                                                l_api_name              ,
                                                g_pkg_name              )
        THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Check the profile option CSI_DEBUG_LEVEL for debug message reporting
        l_csi_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

        -- If CSI_DEBUG_LEVEL = 1 then dump the procedure name
        IF (l_csi_debug_level > 0) THEN
            csi_gen_utility_pvt.put_line( 'get_inst_party_rel_hist');
        END IF;

        -- If the debug level = 2 then dump all the parameters values.
        IF (l_csi_debug_level > 1) THEN
            csi_gen_utility_pvt.put_line(  'get_inst_party_rel_hist'   ||
                                                 p_api_version           ||'-'||
                                                 p_commit                ||'-'||
                                                 p_init_msg_list         ||'-'||
                                                 p_validation_level      ||'-'||
                                                 p_transaction_id               );
             -- dump the in parameter in the log file

        END IF;

        /***** srramakr commented for bug # 3304439
        -- Check for the profile option and enable trace
        l_flag:=csi_gen_utility_pvt.enable_trace(l_trace_flag => l_flag);
        -- End enable trace
        ****/

        -- Start API body

        FOR C1 IN get_party_hist(p_transaction_id) LOOP
              x_party_history_tbl(i).INSTANCE_PARTY_ID := C1.INSTANCE_PARTY_ID;
              x_party_history_tbl(i).INSTANCE_PARTY_HISTORY_ID := C1.INSTANCE_PARTY_HISTORY_ID;
              x_party_history_tbl(i).TRANSACTION_ID := C1.TRANSACTION_ID;
              x_party_history_tbl(i).OLD_PARTY_SOURCE_TABLE := C1.OLD_PARTY_SOURCE_TABLE;
              x_party_history_tbl(i).NEW_PARTY_SOURCE_TABLE := C1.NEW_PARTY_SOURCE_TABLE;
              x_party_history_tbl(i).OLD_PARTY_ID := C1.OLD_PARTY_ID;
              x_party_history_tbl(i).NEW_PARTY_ID := C1.NEW_PARTY_ID;
              x_party_history_tbl(i).OLD_RELATIONSHIP_TYPE_CODE := C1.OLD_RELATIONSHIP_TYPE_CODE;
              x_party_history_tbl(i).NEW_RELATIONSHIP_TYPE_CODE:= C1.NEW_RELATIONSHIP_TYPE_CODE;
              x_party_history_tbl(i).OLD_CONTACT_FLAG := C1.OLD_CONTACT_FLAG;
              x_party_history_tbl(i).NEW_CONTACT_FLAG := C1.NEW_CONTACT_FLAG;
              x_party_history_tbl(i).OLD_CONTACT_IP_ID := C1.OLD_CONTACT_IP_ID;
              x_party_history_tbl(i).NEW_CONTACT_IP_ID := C1.NEW_CONTACT_IP_ID;
              x_party_history_tbl(i).OLD_ACTIVE_START_DATE:= C1.OLD_ACTIVE_START_DATE;
              x_party_history_tbl(i).NEW_ACTIVE_START_DATE:= C1.NEW_ACTIVE_START_DATE;
              x_party_history_tbl(i).OLD_ACTIVE_END_DATE:= C1.OLD_ACTIVE_END_DATE;
              x_party_history_tbl(i).NEW_ACTIVE_END_DATE:= C1.NEW_ACTIVE_END_DATE;
              x_party_history_tbl(i).OLD_CONTEXT:= C1.OLD_CONTEXT;
              x_party_history_tbl(i).NEW_CONTEXT:= C1.NEW_CONTEXT;
              x_party_history_tbl(i).OLD_ATTRIBUTE1:= C1.OLD_ATTRIBUTE1;
              x_party_history_tbl(i).NEW_ATTRIBUTE1:= C1.NEW_ATTRIBUTE1;
              x_party_history_tbl(i).OLD_ATTRIBUTE2:= C1.OLD_ATTRIBUTE2;
              x_party_history_tbl(i).NEW_ATTRIBUTE2:= C1.NEW_ATTRIBUTE2;
              x_party_history_tbl(i).OLD_ATTRIBUTE3:= C1.OLD_ATTRIBUTE3;
              x_party_history_tbl(i).OLD_ATTRIBUTE3:= C1.OLD_ATTRIBUTE3;
              x_party_history_tbl(i).OLD_ATTRIBUTE4:= C1.OLD_ATTRIBUTE4;
              x_party_history_tbl(i).NEW_ATTRIBUTE4:= C1.NEW_ATTRIBUTE4;
              x_party_history_tbl(i).OLD_ATTRIBUTE5:= C1.OLD_ATTRIBUTE5;
              x_party_history_tbl(i).NEW_ATTRIBUTE5:= C1.NEW_ATTRIBUTE5;
              x_party_history_tbl(i).OLD_ATTRIBUTE6:= C1.OLD_ATTRIBUTE6;
              x_party_history_tbl(i).NEW_ATTRIBUTE6:= C1.NEW_ATTRIBUTE6;
              x_party_history_tbl(i).OLD_ATTRIBUTE7:= C1.OLD_ATTRIBUTE7;
              x_party_history_tbl(i).NEW_ATTRIBUTE7:= C1.NEW_ATTRIBUTE7;
              x_party_history_tbl(i).OLD_ATTRIBUTE8:= C1.OLD_ATTRIBUTE8;
              x_party_history_tbl(i).NEW_ATTRIBUTE8:= C1.NEW_ATTRIBUTE8;
              x_party_history_tbl(i).OLD_ATTRIBUTE9:= C1.OLD_ATTRIBUTE9;
              x_party_history_tbl(i).NEW_ATTRIBUTE9:= C1.NEW_ATTRIBUTE9;
              x_party_history_tbl(i).OLD_ATTRIBUTE10:= C1.OLD_ATTRIBUTE10;
              x_party_history_tbl(i).NEW_ATTRIBUTE10:= C1.NEW_ATTRIBUTE10;
              x_party_history_tbl(i).OLD_ATTRIBUTE11:= C1.OLD_ATTRIBUTE11;
              x_party_history_tbl(i).NEW_ATTRIBUTE11:= C1.NEW_ATTRIBUTE11;
              x_party_history_tbl(i).OLD_ATTRIBUTE12:= C1.OLD_ATTRIBUTE12;
              x_party_history_tbl(i).NEW_ATTRIBUTE12:= C1.NEW_ATTRIBUTE12;
              x_party_history_tbl(i).OLD_ATTRIBUTE13:= C1.OLD_ATTRIBUTE13;
              x_party_history_tbl(i).NEW_ATTRIBUTE13:= C1.NEW_ATTRIBUTE13;
              x_party_history_tbl(i).OLD_ATTRIBUTE14:= C1.OLD_ATTRIBUTE14;
              x_party_history_tbl(i).NEW_ATTRIBUTE14:= C1.NEW_ATTRIBUTE14;
              x_party_history_tbl(i).OLD_ATTRIBUTE15:= C1.OLD_ATTRIBUTE15;
              x_party_history_tbl(i).NEW_ATTRIBUTE15:= C1.NEW_ATTRIBUTE15;
              x_party_history_tbl(i).FULL_DUMP_FLAG:= C1.FULL_DUMP_FLAG;
              x_party_history_tbl(i).OBJECT_VERSION_NUMBER := C1.OBJECT_VERSION_NUMBER;
              x_party_history_tbl(i).OLD_PREFERRED_FLAG :=  C1.OLD_PREFERRED_FLAG;
              x_party_history_tbl(i).NEW_PREFERRED_FLAG :=  C1.NEW_PREFERRED_FLAG;
              x_party_history_tbl(i).OLD_PRIMARY_FLAG:= C1.OLD_PRIMARY_FLAG;
              x_party_history_tbl(i).NEW_PRIMARY_FLAG := C1.NEW_PRIMARY_FLAG;
              x_party_history_tbl(i).INSTANCE_ID := C1.INSTANCE_ID; -- Added by sk on 08-APR for fixing bug
                                                                    -- 2304649 .
-- Added for bug 2781480
             IF  (x_party_history_tbl(i).old_party_source_table IS NULL AND
                  x_party_history_tbl(i).new_party_source_table IS NULL ) OR
                 (x_party_history_tbl(i).old_party_id IS NULL AND
                  x_party_history_tbl(i).new_party_id IS NULL ) OR
                 (x_party_history_tbl(i).old_relationship_type_code IS NULL AND
                  x_party_history_tbl(i).new_relationship_type_code IS NULL)
             --AND (nvl(x_party_history_tbl(i).old_party_id,fnd_api.g_miss_num) <> nvl(x_party_history_tbl(i).new_party_id,fnd_api.g_miss_num)  )
             THEN
                 l_party_query_rec.instance_party_id := x_party_history_tbl(i).instance_party_id;
                 l_time_stamp:=c1.creation_date;
                csi_party_relationships_pub.get_inst_party_relationships
                   (    p_api_version             => 1.0
                       ,p_commit                  => fnd_api.g_false
                       ,p_init_msg_list           => fnd_api.g_false
                       ,p_validation_level        => fnd_api.g_valid_level_full
                       ,p_party_query_rec         => l_party_query_rec
                       ,p_resolve_id_columns      => fnd_api.g_false
                       ,p_time_stamp              => l_time_stamp
                       ,x_party_header_tbl        => l_party_header_tbl
                       ,x_return_status           => x_return_status
                       ,x_msg_count               => x_msg_count
                       ,x_msg_data                => x_msg_data
                     );

                 IF NOT(x_return_status = fnd_api.g_ret_sts_success)
                 THEN
                    RAISE fnd_api.g_exc_error;
                 END IF;

               IF (x_party_history_tbl(i).old_party_source_table IS NULL AND
                   x_party_history_tbl(i).new_party_source_table IS NULL )
               THEN
                   x_party_history_tbl(i).old_party_source_table:=l_party_header_tbl(1).party_source_table;
                   x_party_history_tbl(i).new_party_source_table:=l_party_header_tbl(1).party_source_table;
               END IF;
               -- Added for bug 2179142
               IF (x_party_history_tbl(i).old_party_id IS NULL AND
                   x_party_history_tbl(i).new_party_id IS NULL )
               THEN
                   x_party_history_tbl(i).old_party_id:=l_party_header_tbl(1).party_id;
                   x_party_history_tbl(i).new_party_id:=l_party_header_tbl(1).party_id;
               END IF;

               IF (x_party_history_tbl(i).old_relationship_type_code IS NULL AND
                   x_party_history_tbl(i).new_relationship_type_code IS NULL)
               THEN
                   x_party_history_tbl(i).old_relationship_type_code := l_party_header_tbl(1).relationship_type_code;
                   x_party_history_tbl(i).new_relationship_type_code := l_party_header_tbl(1).relationship_type_code;
               END IF;

               IF (x_party_history_tbl(i).old_contact_flag IS NULL AND
                   x_party_history_tbl(i).new_contact_flag IS NULL )
               THEN
                   x_party_history_tbl(i).old_contact_flag:=l_party_header_tbl(1).contact_flag;
                   x_party_history_tbl(i).new_contact_flag:=l_party_header_tbl(1).contact_flag;
               END IF;
               -- End addition for bug 2179142
             END IF;
-- End addition for bug 2781480


--start of the code for  resolve_id_columns for old tbl(i)ords

       l_old_contact_party_id := x_party_history_tbl(i).old_party_id;
       l_old_contact_flag     := x_party_history_tbl(i).old_contact_flag;
       l_old_party_source_tbl := x_party_history_tbl(i).old_party_source_table;

    IF ((l_old_contact_party_id IS NOT NULL )
       AND ( l_old_party_source_tbl IS NOT NULL )
       AND ( l_old_contact_flag = 'Y')   -- Added for bug 2179142
       )
    THEN
          csi_party_relationships_pvt.get_contact_details
          (
           p_api_version              =>  p_api_version
          ,p_commit                   =>  p_commit
          ,p_init_msg_list            =>  p_init_msg_list
          ,p_validation_level         =>  p_validation_level
          ,p_contact_party_id         =>  l_old_contact_party_id
          ,p_contact_flag             =>  l_old_contact_flag
          ,p_party_tbl                =>  l_old_party_source_tbl
          ,x_contact_details          =>  l_contact_details
          ,x_return_status            =>  x_return_status
          ,x_msg_count                =>  x_msg_count
          ,x_msg_data                 =>  x_msg_data
          );


          IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
              FOR i in 1..x_msg_Count LOOP
                   FND_MSG_PUB.Get(p_msg_index     => i,
                                   p_encoded       => 'F',
                                   p_data          => x_msg_data,
                                   p_msg_index_out => x_msg_index_out );
                   csi_gen_utility_pvt.put_line( 'message data = '||x_msg_data);
              End LOOP;
              RAISE FND_API.G_EXC_ERROR;
          END IF;

           x_party_history_tbl(i).old_contact_party_name        :=  l_contact_details.party_name;
           -- Added for bug 2179142
            IF x_party_history_tbl(i).old_party_source_table = 'EMPLOYEE' THEN
              BEGIN
                SELECT employee_number,
                       'EMPLYOEE'
                INTO   x_party_history_tbl(i).old_contact_party_number,
                       x_party_history_tbl(i).old_contact_party_type
                FROM   per_all_people_f
                WHERE  person_id = l_old_contact_party_id
                AND    rownum < 2;  -- Bug # 2183107 srramakr
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;
            ELSIF x_party_history_tbl(i).old_party_source_table = 'HZ_PARTIES' THEN
              BEGIN
                SELECT party_number,
                       'PARTY'
                INTO   x_party_history_tbl(i).old_contact_party_number,
                       x_party_history_tbl(i).old_contact_party_type
                FROM   hz_parties
                WHERE  party_id = l_old_contact_party_id;
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;
            ELSIF x_party_history_tbl(i).old_party_source_table = 'PO_VENDORS' THEN
              BEGIN
                SELECT segment1,
                       'VENDOR'
                INTO   x_party_history_tbl(i).old_contact_party_number,
                       x_party_history_tbl(i).old_contact_party_type
                FROM   po_vendors
                WHERE  vendor_id = l_old_contact_party_id;
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;
            ELSIF x_party_history_tbl(i).old_party_source_table = 'GROUP' THEN
              BEGIN
                SELECT group_number,
                       'GROUP'
                INTO   x_party_history_tbl(i).old_contact_party_number,
                       x_party_history_tbl(i).old_contact_party_type
               FROM    jtf_rs_groups_vl
               WHERE   group_id = l_old_contact_party_id;
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;
            ELSIF x_party_history_tbl(i).old_party_source_table = 'TEAM' THEN
              BEGIN
                SELECT team_number,
                       'TEAM'
                INTO   x_party_history_tbl(i).old_contact_party_number,
                       x_party_history_tbl(i).old_contact_party_type
                FROM   jtf_rs_teams_vl
                WHERE  team_id = l_old_contact_party_id;
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;

            END IF;
           -- End addition for bug 2179142
         IF NVL(l_old_contact_party_id,fnd_api.g_miss_num) <> NVL(l_new_contact_party_id,fnd_api.g_miss_num)
         THEN
           x_party_history_tbl(i).old_contact_work_phone_num    :=  l_contact_details.officephone;
           x_party_history_tbl(i).old_contact_address1          :=  l_contact_details.address1;
           x_party_history_tbl(i).old_contact_address2          :=  l_contact_details.address2;
           x_party_history_tbl(i).old_contact_address3          :=  l_contact_details.address3;
           x_party_history_tbl(i).old_contact_address4          :=  l_contact_details.address4;
           x_party_history_tbl(i).old_contact_city              :=  l_contact_details.city;
           x_party_history_tbl(i).old_contact_postal_code       :=  l_contact_details.postal_code;
           x_party_history_tbl(i).old_contact_state             :=  l_contact_details.state;
           x_party_history_tbl(i).old_contact_country           :=  l_contact_details.country;
           x_party_history_tbl(i).old_contact_email_address     :=  l_contact_details.email;
         END IF;
       END IF;

            IF x_party_history_tbl(i).old_party_source_table = 'EMPLOYEE' THEN
              BEGIN
                SELECT employee_number,
                       'EMPLYOEE',
                       full_name
                INTO   x_party_history_tbl(i).old_party_number,
                       x_party_history_tbl(i).old_party_type,
                        x_party_history_tbl(i).old_party_name
                FROM   per_all_people_f
                WHERE  person_id = x_party_history_tbl(i).old_party_id
                AND    rownum < 2;  -- Bug # 2183107 srramakr
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;
            ELSIF x_party_history_tbl(i).old_party_source_table = 'HZ_PARTIES' THEN
              BEGIN
                SELECT party_number,
                       'PARTY',
                       party_name
                INTO   x_party_history_tbl(i).old_party_number,
                       x_party_history_tbl(i).old_party_type,
                       x_party_history_tbl(i).old_party_name
                FROM   hz_parties
                WHERE  party_id = x_party_history_tbl(i).old_party_id;
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;
            ELSIF x_party_history_tbl(i).old_party_source_table = 'PO_VENDORS' THEN
              BEGIN
                SELECT segment1,
                       'VENDOR',
                       vendor_name
                INTO   x_party_history_tbl(i).old_party_number,
                       x_party_history_tbl(i).old_party_type,
                       x_party_history_tbl(i).old_party_name
                FROM   po_vendors
                WHERE  vendor_id = x_party_history_tbl(i).old_party_id;
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;
            ELSIF x_party_history_tbl(i).old_party_source_table = 'GROUP' THEN
              BEGIN
                SELECT group_number,
                       'GROUP',
                       group_name
                INTO   x_party_history_tbl(i).old_party_number,
                       x_party_history_tbl(i).old_party_type,
                       x_party_history_tbl(i).old_party_name
               FROM    jtf_rs_groups_vl
               WHERE   group_id = x_party_history_tbl(i).old_party_id;
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;
            ELSIF x_party_history_tbl(i).old_party_source_table = 'TEAM' THEN
              BEGIN
                SELECT team_number,
                       'TEAM',
                       team_name
                INTO   x_party_history_tbl(i).old_party_number,
                       x_party_history_tbl(i).old_party_type,
                       x_party_history_tbl(i).old_party_name
                FROM   jtf_rs_teams_vl
                WHERE  team_id = x_party_history_tbl(i).old_party_id;
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;

            END IF;

   --start of the code for resolve_id_columns for new records
       l_new_contact_party_id := x_party_history_tbl(i).new_party_id;
       l_new_contact_flag      := x_party_history_tbl(i).new_contact_flag;
       l_new_party_source_tbl := x_party_history_tbl(i).new_party_source_table;

      IF ((l_new_contact_party_id IS NOT NULL )
            AND ( l_new_party_source_tbl IS NOT NULL )
            AND ( l_new_contact_flag = 'Y')  -- Added for bug 2179142
          )
      THEN
           csi_party_relationships_pvt.get_contact_details
          (
           p_api_version              =>  p_api_version
          ,p_commit                   =>  p_commit
          ,p_init_msg_list            =>  p_init_msg_list
          ,p_validation_level         =>  p_validation_level
          ,p_contact_party_id         =>  l_new_contact_party_id
          ,p_contact_flag             =>  l_new_contact_flag
          ,p_party_tbl                =>  l_new_party_source_tbl
          ,x_contact_details          =>  l_contact_details
          ,x_return_status            =>  x_return_status
          ,x_msg_count                =>  x_msg_count
          ,x_msg_data                 =>  x_msg_data
          );


         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
              FOR i in 1..x_msg_Count LOOP
                   FND_MSG_PUB.Get(p_msg_index     => i,
                                   p_encoded       => 'F',
                                   p_data          => x_msg_data,
                                   p_msg_index_out => x_msg_index_out );
                   csi_gen_utility_pvt.put_line( 'message data = '||x_msg_data);
              End LOOP;
              RAISE FND_API.G_EXC_ERROR;
         END IF;

           x_party_history_tbl(i).new_contact_party_name        :=  l_contact_details.party_name;
           -- Added for bug 2179142
            IF x_party_history_tbl(i).new_party_source_table = 'EMPLOYEE' THEN
              BEGIN
                SELECT employee_number,
                       'EMPLYOEE'
                INTO   x_party_history_tbl(i).new_contact_party_number,
                       x_party_history_tbl(i).new_contact_party_type
                FROM   per_all_people_f
                WHERE  person_id = l_new_contact_party_id
                AND    rownum < 2;  -- Bug # 2183107 srramakr
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;
            ELSIF x_party_history_tbl(i).new_party_source_table = 'HZ_PARTIES' THEN
              BEGIN
                SELECT party_number,
                       'PARTY'
                INTO   x_party_history_tbl(i).new_contact_party_number,
                       x_party_history_tbl(i).new_contact_party_type
                FROM   hz_parties
                WHERE  party_id = l_new_contact_party_id;
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;
            ELSIF x_party_history_tbl(i).new_party_source_table = 'PO_VENDORS' THEN
              BEGIN
                SELECT segment1,
                       'VENDOR'
                INTO   x_party_history_tbl(i).new_contact_party_number,
                       x_party_history_tbl(i).new_contact_party_type
                FROM   po_vendors
                WHERE  vendor_id = l_new_contact_party_id;
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;
            ELSIF x_party_history_tbl(i).new_party_source_table = 'GROUP' THEN
              BEGIN
                SELECT group_number,
                       'GROUP'
                INTO   x_party_history_tbl(i).new_contact_party_number,
                       x_party_history_tbl(i).new_contact_party_type
               FROM    jtf_rs_groups_vl
               WHERE   group_id = l_new_contact_party_id;
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;
            ELSIF x_party_history_tbl(i).new_party_source_table = 'TEAM' THEN
              BEGIN
                SELECT team_number,
                       'TEAM'
                INTO   x_party_history_tbl(i).new_contact_party_number,
                       x_party_history_tbl(i).new_contact_party_type
                FROM   jtf_rs_teams_vl
                WHERE  team_id = x_party_history_tbl(i).new_party_id;
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;

            END IF;
           -- End addition for bug 2179142
         IF NVL(l_old_contact_party_id,fnd_api.g_miss_num) <> NVL(l_new_contact_party_id,fnd_api.g_miss_num)
         THEN
           x_party_history_tbl(i).new_contact_work_phone_num    :=  l_contact_details.officephone;
           x_party_history_tbl(i).new_contact_address1          :=  l_contact_details.address1;
           x_party_history_tbl(i).new_contact_address2          :=  l_contact_details.address2;
           x_party_history_tbl(i).new_contact_address3          :=  l_contact_details.address3;
           x_party_history_tbl(i).new_contact_address4          :=  l_contact_details.address4;
           x_party_history_tbl(i).new_contact_city              :=  l_contact_details.city;
           x_party_history_tbl(i).new_contact_postal_code       :=  l_contact_details.postal_code;
           x_party_history_tbl(i).new_contact_state             :=  l_contact_details.state;
           x_party_history_tbl(i).new_contact_country           :=  l_contact_details.country;
           x_party_history_tbl(i).new_contact_email_address     :=  l_contact_details.email;
         END IF;

       END IF;

           IF x_party_history_tbl(i).new_party_source_table = 'EMPLOYEE' THEN
              BEGIN
                SELECT employee_number,
                       'EMPLYOEE',
                       full_name
                INTO   x_party_history_tbl(i).new_party_number,
                       x_party_history_tbl(i).new_party_type,
                        x_party_history_tbl(i).new_party_name
                FROM   per_all_people_f
                WHERE  person_id = x_party_history_tbl(i).new_party_id
                AND    rownum < 2;  -- Bug # 2183107 srramakr
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;
            ELSIF x_party_history_tbl(i).new_party_source_table = 'HZ_PARTIES' THEN
              BEGIN
                SELECT party_number,
                       'PARTY',
                       party_name
                INTO   x_party_history_tbl(i).new_party_number,
                       x_party_history_tbl(i).new_party_type,
                        x_party_history_tbl(i).new_party_name
                FROM   hz_parties
                WHERE  party_id = x_party_history_tbl(i).new_party_id;
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;
            ELSIF x_party_history_tbl(i).new_party_source_table = 'PO_VENDORS' THEN
              BEGIN
                SELECT segment1,
                       'VENDOR',
                       vendor_name
                INTO   x_party_history_tbl(i).new_party_number,
                       x_party_history_tbl(i).new_party_type,
                       x_party_history_tbl(i).new_party_name
                FROM   po_vendors
                WHERE  vendor_id = x_party_history_tbl(i).new_party_id;
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;
            ELSIF x_party_history_tbl(i).new_party_source_table = 'GROUP' THEN
              BEGIN
                SELECT group_number,
                       'GROUP',
                       group_name
                INTO   x_party_history_tbl(i).new_party_number,
                       x_party_history_tbl(i).new_party_type,
                       x_party_history_tbl(i).new_party_name
               FROM    jtf_rs_groups_vl
               WHERE   group_id = x_party_history_tbl(i).new_party_id;
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;
            ELSIF x_party_history_tbl(i).new_party_source_table = 'TEAM' THEN
              BEGIN
                SELECT team_number,
                       'TEAM',
                       team_name
                INTO   x_party_history_tbl(i).new_party_number,
                       x_party_history_tbl(i).new_party_type,
                       x_party_history_tbl(i).new_party_name
                FROM   jtf_rs_teams_vl
                WHERE  team_id = x_party_history_tbl(i).new_party_id;
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;
            END IF;
         -- Added for bug 2781480
         /* Commented for bug 2179142
            IF  NVL(x_party_history_tbl(i).old_party_source_table,fnd_api.g_miss_char) = NVL(x_party_history_tbl(i).new_party_source_table,fnd_api.g_miss_char)
            THEN
               x_party_history_tbl(i).old_party_source_table:=NULL;
               x_party_history_tbl(i).new_party_source_table:=NULL;
            END IF;
          */
         -- End addition for bug 2781480

         -- Added for bug 2179142

               IF NVL(x_party_history_tbl(i).old_party_id,fnd_api.g_miss_num)=NVL(x_party_history_tbl(i).new_party_id,fnd_api.g_miss_num)
               THEN
                   x_party_history_tbl(i).old_party_id:=NULL;
                   x_party_history_tbl(i).new_party_id:=NULL;
               END IF;

         -- End addition for bug 2179142
            i := i + 1;
              --IF get_party_hist%NOTFOUND THEN
                --FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_TXN_ID');
                --FND_MSG_PUB.Add;
                --RAISE FND_API.G_EXC_ERROR;
     	      --END IF;
        END LOOP;

       -- End of API body

       -- Standard check of p_commit.
       /*
       IF FND_API.To_Boolean( p_commit ) THEN
             COMMIT WORK;
       END IF;
       */

       /***** srramakr commented for bug # 3304439
       -- Check for the profile option and disable the trace
       IF (l_flag = 'Y') THEN
            dbms_session.set_sql_trace(false);
       END IF;
       -- End disable trace
       ****/

       -- Standard call to get message count and if count is  get message info.
       FND_MSG_PUB.Count_And_Get
                (p_count        =>      x_msg_count ,
                 p_data         =>      x_msg_data   );
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
              --  ROLLBACK TO get_inst_party_rel_hist;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (   p_count   =>      x_msg_count,
                    p_data    =>      x_msg_data );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              --  ROLLBACK TO get_inst_party_rel_hist;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (   p_count   =>      x_msg_count,
                    p_data    =>      x_msg_data  );
        WHEN OTHERS THEN
              --  ROLLBACK TO get_inst_party_rel_hist;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF      FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       g_pkg_name          ,
                        l_api_name           );
                END IF;
                FND_MSG_PUB.Count_And_Get
                ( p_count     =>      x_msg_count,
                  p_data      =>      x_msg_data  );

END get_inst_party_rel_hist;



/*------------------------------------------------------------*/
/* Procedure name:  get_inst_party_rel_hist                   */
/* Description :   Procedure used to  get party relationships */
/*                  from history given a transaction_id       */
/*------------------------------------------------------------*/

PROCEDURE get_inst_party_account_hist
 (    p_api_version             IN  NUMBER
     ,p_commit                  IN  VARCHAR2
     ,p_init_msg_list           IN  VARCHAR2
     ,p_validation_level        IN  NUMBER
     ,p_transaction_id          IN  NUMBER
     ,x_account_history_tbl     OUT NOCOPY  csi_datastructures_pub.account_history_tbl
     ,x_return_status           OUT NOCOPY  VARCHAR2
     ,x_msg_count               OUT NOCOPY  NUMBER
     ,x_msg_data                OUT NOCOPY  VARCHAR2
    )IS

     l_api_name        CONSTANT VARCHAR2(30)   := 'get_inst_party_account_hist' ;
     l_api_version     CONSTANT NUMBER         := 1.0                           ;
     l_csi_debug_level          NUMBER                                          ;
     x_msg_index_out            NUMBER                                          ;
     l_count                    NUMBER         := 0                             ;
     l_flag                     VARCHAR2(1)    :='N'                            ;
      i                         NUMBER         :=1                              ;
     l_account_header_tbl       csi_datastructures_pub.party_account_header_tbl ;
     l_time_stamp               DATE;
     l_party_account_query_rec  csi_datastructures_pub.party_account_query_rec;
     CURSOR get_account_hist(i_transaction_id NUMBER)
     IS
     SELECT      cah.IP_ACCOUNT_HISTORY_ID ,
                 cah.IP_ACCOUNT_ID ,
                 cah.TRANSACTION_ID ,
                 cah.OLD_PARTY_ACCOUNT_ID ,
                 cah.NEW_PARTY_ACCOUNT_ID ,
                 cah.OLD_RELATIONSHIP_TYPE_CODE ,
                 cah.NEW_RELATIONSHIP_TYPE_CODE ,
                 cah.OLD_ACTIVE_START_DATE ,
                 cah.NEW_ACTIVE_START_DATE ,
                 cah.OLD_ACTIVE_END_DATE ,
                 cah.NEW_ACTIVE_END_DATE ,
                 cah.OLD_CONTEXT ,
                 cah.NEW_CONTEXT ,
                 cah.OLD_ATTRIBUTE1 ,
                 cah.NEW_ATTRIBUTE1 ,
                 cah.OLD_ATTRIBUTE2 ,
                 cah.NEW_ATTRIBUTE2 ,
                 cah.OLD_ATTRIBUTE3 ,
                 cah.NEW_ATTRIBUTE3 ,
                 cah.OLD_ATTRIBUTE4 ,
                 cah.NEW_ATTRIBUTE4 ,
                 cah.OLD_ATTRIBUTE5 ,
                 cah.NEW_ATTRIBUTE5 ,
                 cah.OLD_ATTRIBUTE6 ,
                 cah.NEW_ATTRIBUTE6 ,
                 cah.OLD_ATTRIBUTE7 ,
                 cah.NEW_ATTRIBUTE7 ,
                 cah.OLD_ATTRIBUTE8 ,
                 cah.NEW_ATTRIBUTE8 ,
                 cah.OLD_ATTRIBUTE9 ,
                 cah.NEW_ATTRIBUTE9 ,
                 cah.OLD_ATTRIBUTE10 ,
                 cah.NEW_ATTRIBUTE10 ,
                 cah.OLD_ATTRIBUTE11 ,
                 cah.NEW_ATTRIBUTE11 ,
                 cah.OLD_ATTRIBUTE12 ,
                 cah.NEW_ATTRIBUTE12 ,
                 cah.OLD_ATTRIBUTE13 ,
                 cah.NEW_ATTRIBUTE13 ,
                 cah.OLD_ATTRIBUTE14 ,
                 cah.NEW_ATTRIBUTE14 ,
                 cah.OLD_ATTRIBUTE15 ,
                 cah.NEW_ATTRIBUTE15 ,
                 cah.FULL_DUMP_FLAG  ,
                 cah.OBJECT_VERSION_NUMBER ,
                 cah.OLD_BILL_TO_ADDRESS ,
                 cah.NEW_BILL_TO_ADDRESS ,
                 cah.OLD_SHIP_TO_ADDRESS ,
                 cah.NEW_SHIP_TO_ADDRESS ,
                 cip.INSTANCE_ID,
                 cah.OLD_INSTANCE_PARTY_ID ,
                 cah.NEW_INSTANCE_PARTY_ID,
                 cah.creation_date
     FROM     csi_ip_accounts_h cah,
              csi_ip_accounts   ca,
              csi_i_parties     cip
     WHERE    cah.transaction_id   = i_transaction_id
     AND      cah.ip_account_id    = ca.ip_account_id
     AND      ca.instance_party_id = cip.instance_party_id;    -- Added by sguthiva on 9-APR for bug 2304649

BEGIN
        -- Standard Start of API savepoint
      --  SAVEPOINT   get_inst_party_account_hist;


        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (    l_api_version           ,
                                                p_api_version           ,
                                                l_api_name              ,
                                                g_pkg_name              )
        THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Check the profile option CSI_DEBUG_LEVEL for debug message reporting
        l_csi_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

        -- If CSI_DEBUG_LEVEL = 1 then dump the procedure name
        IF (l_csi_debug_level > 0) THEN
            csi_gen_utility_pvt.put_line( 'get_inst_party_account_hist');
        END IF;

        -- If the debug level = 2 then dump all the parameters values.
        IF (l_csi_debug_level > 1) THEN
            csi_gen_utility_pvt.put_line(  'get_inst_party_account_hist'   ||
                                                 p_api_version           ||'-'||
                                                 p_commit                ||'-'||
                                                 p_init_msg_list         ||'-'||
                                                 p_validation_level      ||'-'||
                                                 p_transaction_id               );
             -- dump the in parameter in the log file

        END IF;

        /***** srramakr commented for bug # 3304439
        -- Check for the profile option and enable trace
        l_flag:=csi_gen_utility_pvt.enable_trace(l_trace_flag => l_flag);
        -- End enable trace
        ****/

        -- Start API body

       FOR l_acct_hist_csr IN get_account_hist(p_transaction_id)
       LOOP
          x_account_history_tbl(i).ip_account_id := l_acct_hist_csr.ip_account_id;
          x_account_history_tbl(i).ip_account_history_id := l_acct_hist_csr.ip_account_history_id;
          x_account_history_tbl(i).transaction_id := l_acct_hist_csr.transaction_id;

          IF NVL(l_acct_hist_csr.old_party_account_id,fnd_api.g_miss_num) = NVL(l_acct_hist_csr.new_party_account_id,fnd_api.g_miss_num)
          THEN
            x_account_history_tbl(i).old_party_account_id := NULL;
            x_account_history_tbl(i).new_party_account_id := NULL;
          ELSE
            x_account_history_tbl(i).old_party_account_id := l_acct_hist_csr.old_party_account_id;
            x_account_history_tbl(i).new_party_account_id := l_acct_hist_csr.new_party_account_id;
          END IF;

          IF NVL(l_acct_hist_csr.old_relationship_type_code,fnd_api.g_miss_char) =
                                    NVL(l_acct_hist_csr.new_relationship_type_code,fnd_api.g_miss_num)
          THEN
            x_account_history_tbl(i).old_relationship_type_code := NULL;
            x_account_history_tbl(i).new_relationship_type_code := NULL;
          ELSE
            x_account_history_tbl(i).old_relationship_type_code := l_acct_hist_csr.old_relationship_type_code;
            x_account_history_tbl(i).new_relationship_type_code := l_acct_hist_csr.new_relationship_type_code;
          END IF;

          IF NVL(l_acct_hist_csr.old_active_start_date,fnd_api.g_miss_date) = NVL(l_acct_hist_csr.new_active_start_date,fnd_api.g_miss_date)
          THEN
            x_account_history_tbl(i).old_active_start_date := NULL;
            x_account_history_tbl(i).new_active_start_date := NULL;
          ELSE
            x_account_history_tbl(i).old_active_start_date := l_acct_hist_csr.old_active_start_date;
            x_account_history_tbl(i).new_active_start_date := l_acct_hist_csr.new_active_start_date;
          END IF;

          IF NVL(l_acct_hist_csr.old_active_end_date,fnd_api.g_miss_date) = NVL(l_acct_hist_csr.new_active_end_date,fnd_api.g_miss_date)
          THEN
            x_account_history_tbl(i).old_active_end_date := NULL;
            x_account_history_tbl(i).new_active_end_date := NULL;
          ELSE
            x_account_history_tbl(i).old_active_end_date := l_acct_hist_csr.old_active_end_date;
            x_account_history_tbl(i).new_active_end_date := l_acct_hist_csr.new_active_end_date;
          END IF;

          IF NVL(l_acct_hist_csr.old_context,fnd_api.g_miss_char) = NVL(l_acct_hist_csr.new_context,fnd_api.g_miss_char)
          THEN
            x_account_history_tbl(i).old_context := NULL;
            x_account_history_tbl(i).new_context := NULL;
          ELSE
            x_account_history_tbl(i).old_context := l_acct_hist_csr.old_context;
            x_account_history_tbl(i).new_context := l_acct_hist_csr.new_context;
          END IF;

          IF NVL(l_acct_hist_csr.old_attribute1,fnd_api.g_miss_char) = NVL(l_acct_hist_csr.new_attribute1,fnd_api.g_miss_char)
          THEN
            x_account_history_tbl(i).old_attribute1 := NULL;
            x_account_history_tbl(i).new_attribute1 := NULL;
          ELSE
            x_account_history_tbl(i).old_attribute1 := l_acct_hist_csr.old_attribute1;
            x_account_history_tbl(i).new_attribute1 := l_acct_hist_csr.new_attribute1;
          END IF;

          IF NVL(l_acct_hist_csr.old_attribute2,fnd_api.g_miss_char) = NVL(l_acct_hist_csr.new_attribute2,fnd_api.g_miss_char)
          THEN
            x_account_history_tbl(i).old_attribute2 := NULL;
            x_account_history_tbl(i).new_attribute2 := NULL;
          ELSE
            x_account_history_tbl(i).old_attribute2 := l_acct_hist_csr.old_attribute2;
            x_account_history_tbl(i).new_attribute2 := l_acct_hist_csr.new_attribute2;
          END IF;

          IF NVL(l_acct_hist_csr.old_attribute3,fnd_api.g_miss_char) = NVL(l_acct_hist_csr.new_attribute3,fnd_api.g_miss_char)
          THEN
            x_account_history_tbl(i).old_attribute3 := NULL;
            x_account_history_tbl(i).new_attribute3 := NULL;
          ELSE
            x_account_history_tbl(i).old_attribute3 := l_acct_hist_csr.old_attribute3;
            x_account_history_tbl(i).new_attribute3 := l_acct_hist_csr.new_attribute3;
          END IF;


          IF NVL(l_acct_hist_csr.old_attribute4,fnd_api.g_miss_char) = NVL(l_acct_hist_csr.new_attribute4,fnd_api.g_miss_char)
          THEN
            x_account_history_tbl(i).old_attribute4 := NULL;
            x_account_history_tbl(i).new_attribute4 := NULL;
          ELSE
            x_account_history_tbl(i).old_attribute4 := l_acct_hist_csr.old_attribute4;
            x_account_history_tbl(i).new_attribute4 := l_acct_hist_csr.new_attribute4;
          END IF;

          IF NVL(l_acct_hist_csr.old_attribute5,fnd_api.g_miss_char) = NVL(l_acct_hist_csr.new_attribute5,fnd_api.g_miss_char)
          THEN
            x_account_history_tbl(i).old_attribute5 := NULL;
            x_account_history_tbl(i).new_attribute5 := NULL;
          ELSE
            x_account_history_tbl(i).old_attribute5 := l_acct_hist_csr.old_attribute5;
            x_account_history_tbl(i).new_attribute5 := l_acct_hist_csr.new_attribute5;
          END IF;

          IF NVL(l_acct_hist_csr.old_attribute6,fnd_api.g_miss_char) = NVL(l_acct_hist_csr.new_attribute6,fnd_api.g_miss_char)
          THEN
            x_account_history_tbl(i).old_attribute6 := NULL;
            x_account_history_tbl(i).new_attribute6 := NULL;
          ELSE
            x_account_history_tbl(i).old_attribute6 := l_acct_hist_csr.old_attribute6;
            x_account_history_tbl(i).new_attribute6 := l_acct_hist_csr.new_attribute6;
          END IF;

          IF NVL(l_acct_hist_csr.old_attribute7,fnd_api.g_miss_char) = NVL(l_acct_hist_csr.new_attribute7,fnd_api.g_miss_char)
          THEN
            x_account_history_tbl(i).old_attribute7 := NULL;
            x_account_history_tbl(i).new_attribute7 := NULL;
          ELSE
            x_account_history_tbl(i).old_attribute7 := l_acct_hist_csr.old_attribute7;
            x_account_history_tbl(i).new_attribute7 := l_acct_hist_csr.new_attribute7;
          END IF;

          IF NVL(l_acct_hist_csr.old_attribute8,fnd_api.g_miss_char) = NVL(l_acct_hist_csr.new_attribute8,fnd_api.g_miss_char)
          THEN
            x_account_history_tbl(i).old_attribute8 := NULL;
            x_account_history_tbl(i).new_attribute8 := NULL;
          ELSE
            x_account_history_tbl(i).old_attribute8 := l_acct_hist_csr.old_attribute8;
            x_account_history_tbl(i).new_attribute8 := l_acct_hist_csr.new_attribute8;
          END IF;

          IF NVL(l_acct_hist_csr.old_attribute9,fnd_api.g_miss_char) = NVL(l_acct_hist_csr.new_attribute9,fnd_api.g_miss_char)
          THEN
            x_account_history_tbl(i).old_attribute9 := NULL;
            x_account_history_tbl(i).new_attribute9 := NULL;
          ELSE
            x_account_history_tbl(i).old_attribute9 := l_acct_hist_csr.old_attribute9;
            x_account_history_tbl(i).new_attribute9 := l_acct_hist_csr.new_attribute9;
          END IF;

          IF NVL(l_acct_hist_csr.old_attribute10,fnd_api.g_miss_char) = NVL(l_acct_hist_csr.new_attribute10,fnd_api.g_miss_char)
          THEN
            x_account_history_tbl(i).old_attribute10 := NULL;
            x_account_history_tbl(i).new_attribute10 := NULL;
          ELSE
            x_account_history_tbl(i).old_attribute10 := l_acct_hist_csr.old_attribute10;
            x_account_history_tbl(i).new_attribute10 := l_acct_hist_csr.new_attribute10;
          END IF;

          IF NVL(l_acct_hist_csr.old_attribute11,fnd_api.g_miss_char) = NVL(l_acct_hist_csr.new_attribute11,fnd_api.g_miss_char)
          THEN
            x_account_history_tbl(i).old_attribute11 := NULL;
            x_account_history_tbl(i).new_attribute11 := NULL;
          ELSE
            x_account_history_tbl(i).old_attribute11 := l_acct_hist_csr.old_attribute11;
            x_account_history_tbl(i).new_attribute11 := l_acct_hist_csr.new_attribute11;
          END IF;

          IF NVL(l_acct_hist_csr.old_attribute12,fnd_api.g_miss_char) = NVL(l_acct_hist_csr.new_attribute12,fnd_api.g_miss_char)
          THEN
            x_account_history_tbl(i).old_attribute12 := NULL;
            x_account_history_tbl(i).new_attribute12 := NULL;
          ELSE
            x_account_history_tbl(i).old_attribute12 := l_acct_hist_csr.old_attribute12;
            x_account_history_tbl(i).new_attribute12 := l_acct_hist_csr.new_attribute12;
          END IF;

          IF NVL(l_acct_hist_csr.old_attribute13,fnd_api.g_miss_char) = NVL(l_acct_hist_csr.new_attribute13,fnd_api.g_miss_char)
          THEN
            x_account_history_tbl(i).old_attribute13 := NULL;
            x_account_history_tbl(i).new_attribute13 := NULL;
          ELSE
            x_account_history_tbl(i).old_attribute13 := l_acct_hist_csr.old_attribute13;
            x_account_history_tbl(i).new_attribute13 := l_acct_hist_csr.new_attribute13;
          END IF;

          IF NVL(l_acct_hist_csr.old_attribute14,fnd_api.g_miss_char) = NVL(l_acct_hist_csr.new_attribute14,fnd_api.g_miss_char)
          THEN
            x_account_history_tbl(i).old_attribute14 := NULL;
            x_account_history_tbl(i).new_attribute14 := NULL;
          ELSE
            x_account_history_tbl(i).old_attribute14 := l_acct_hist_csr.old_attribute14;
            x_account_history_tbl(i).new_attribute14 := l_acct_hist_csr.new_attribute14;
          END IF;

          IF NVL(l_acct_hist_csr.old_attribute15,fnd_api.g_miss_char) = NVL(l_acct_hist_csr.new_attribute15,fnd_api.g_miss_char)
          THEN
            x_account_history_tbl(i).old_attribute15 := NULL;
            x_account_history_tbl(i).new_attribute15 := NULL;
          ELSE
            x_account_history_tbl(i).old_attribute15 := l_acct_hist_csr.old_attribute15;
            x_account_history_tbl(i).new_attribute15 := l_acct_hist_csr.new_attribute15;
          END IF;

          IF NVL(l_acct_hist_csr.old_bill_to_address,fnd_api.g_miss_num) = NVL(l_acct_hist_csr.new_bill_to_address,fnd_api.g_miss_num)
          THEN
            x_account_history_tbl(i).old_bill_to_address := NULL;
            x_account_history_tbl(i).new_bill_to_address := NULL;
          ELSE
            x_account_history_tbl(i).old_bill_to_address := l_acct_hist_csr.old_bill_to_address;
            x_account_history_tbl(i).new_bill_to_address := l_acct_hist_csr.new_bill_to_address;
          END IF;

          IF NVL(l_acct_hist_csr.old_ship_to_address,fnd_api.g_miss_num) = NVL(l_acct_hist_csr.new_ship_to_address,fnd_api.g_miss_num)
          THEN
            x_account_history_tbl(i).old_ship_to_address := NULL;
            x_account_history_tbl(i).new_ship_to_address := NULL;
          ELSE
            x_account_history_tbl(i).old_ship_to_address := l_acct_hist_csr.old_ship_to_address;
            x_account_history_tbl(i).new_ship_to_address := l_acct_hist_csr.new_ship_to_address;
          END IF;

          IF NVL(l_acct_hist_csr.old_instance_party_id,fnd_api.g_miss_num) = NVL(l_acct_hist_csr.new_instance_party_id,fnd_api.g_miss_num)
          THEN
            x_account_history_tbl(i).old_instance_party_id := NULL;
            x_account_history_tbl(i).new_instance_party_id := NULL;
          ELSE
            x_account_history_tbl(i).old_instance_party_id := l_acct_hist_csr.old_instance_party_id;
            x_account_history_tbl(i).new_instance_party_id := l_acct_hist_csr.new_instance_party_id;
          END IF;

            x_account_history_tbl(i).object_version_number := l_acct_hist_csr.object_version_number;
            x_account_history_tbl(i).instance_id           := l_acct_hist_csr.instance_id; -- added by sguthiva on 9-apr for bug 2304649
            x_account_history_tbl(i).full_dump_flag        := l_acct_hist_csr.full_dump_flag;

            IF (x_account_history_tbl(i).old_relationship_type_code IS NULL AND
                x_account_history_tbl(i).new_relationship_type_code IS NULL ) OR
               (x_account_history_tbl(i).old_party_account_id IS NULL AND
                x_account_history_tbl(i).new_party_account_id IS NULL)
            THEN
                 l_party_account_query_rec.ip_account_id := x_account_history_tbl(i).ip_account_id;
                 l_time_stamp:=l_acct_hist_csr.creation_date;
                      csi_party_relationships_pub.get_inst_party_accounts
                          ( p_api_version                 => p_api_version
                           ,p_commit                      => p_commit
                           ,p_init_msg_list               => p_init_msg_list
                           ,p_validation_level            => p_validation_level
                           ,p_account_query_rec           => l_party_account_query_rec
                           ,p_resolve_id_columns          => fnd_api.g_false
                           ,p_time_stamp                  => l_time_stamp
                           ,x_account_header_tbl          => l_account_header_tbl
                           ,x_return_status               => x_return_status
                           ,x_msg_count                   => x_msg_count
                           ,x_msg_data                    => x_msg_data);

              IF (x_account_history_tbl(i).old_relationship_type_code IS NULL AND
                  x_account_history_tbl(i).new_relationship_type_code IS NULL )
              THEN
                  x_account_history_tbl(i).old_relationship_type_code := l_account_header_tbl(1).relationship_type_code;
                  x_account_history_tbl(i).new_relationship_type_code := l_account_header_tbl(1).relationship_type_code;
              END IF;

              IF (x_account_history_tbl(i).old_party_account_id IS NULL AND
                  x_account_history_tbl(i).new_party_account_id IS NULL)
              THEN
                  x_account_history_tbl(i).old_party_account_id := l_account_header_tbl(1).party_account_id;
                  x_account_history_tbl(i).new_party_account_id := l_account_header_tbl(1).party_account_id;
              END IF;

            END IF;

              -- Resolve old history columns;
              l_account_header_tbl(1).party_account_id     := x_account_history_tbl(i).OLD_PARTY_ACCOUNT_ID;
              l_account_header_tbl(1).bill_to_address      := x_account_history_tbl(i).OLD_BILL_TO_ADDRESS;
              l_account_header_tbl(1).ship_to_address      := x_account_history_tbl(i).OLD_SHIP_TO_ADDRESS;
              l_account_header_tbl(1).party_account_number := NULL;
              l_account_header_tbl(1).party_account_name   := NULL;
              l_account_header_tbl(1).bill_to_location     := NULL;
              l_account_header_tbl(1).ship_to_location     := NULL;
              -- Following columns were added for bug 2670371
              l_account_header_tbl(1).bill_to_address1     := NULL;
              l_account_header_tbl(1).bill_to_address2     := NULL;
              l_account_header_tbl(1).bill_to_address3     := NULL;
              l_account_header_tbl(1).bill_to_address4     := NULL;
              l_account_header_tbl(1).bill_to_city         := NULL;
              l_account_header_tbl(1).bill_to_state        := NULL;
              l_account_header_tbl(1).bill_to_postal_code  := NULL;
              l_account_header_tbl(1).bill_to_country      := NULL;
              l_account_header_tbl(1).ship_to_address1     := NULL;
              l_account_header_tbl(1).ship_to_address2     := NULL;
              l_account_header_tbl(1).ship_to_address3     := NULL;
              l_account_header_tbl(1).ship_to_address4     := NULL;
              l_account_header_tbl(1).ship_to_city         := NULL;
              l_account_header_tbl(1).ship_to_state        := NULL;
              l_account_header_tbl(1).ship_to_postal_code  := NULL;
              l_account_header_tbl(1).ship_to_country      := NULL;


              csi_party_relationships_pvt.Resolve_id_columns(l_account_header_tbl);

              x_account_history_tbl(i).old_party_account_number  :=  l_account_header_tbl(1).party_account_number;
              x_account_history_tbl(i).old_party_account_name    :=  l_account_header_tbl(1).party_account_name;
              x_account_history_tbl(i).old_bill_to_location      :=  l_account_header_tbl(1).bill_to_location;
              x_account_history_tbl(i).old_ship_to_location      :=  l_account_header_tbl(1).ship_to_location;

              -- Following columns were added for bug 2670371
              x_account_history_tbl(i).old_bill_to_address1      :=  l_account_header_tbl(1).bill_to_address1;
              x_account_history_tbl(i).old_bill_to_address2      :=  l_account_header_tbl(1).bill_to_address2;
              x_account_history_tbl(i).old_bill_to_address3      :=  l_account_header_tbl(1).bill_to_address3;
              x_account_history_tbl(i).old_bill_to_address4      :=  l_account_header_tbl(1).bill_to_address4;
              x_account_history_tbl(i).old_bill_to_city          :=  l_account_header_tbl(1).bill_to_city;
              x_account_history_tbl(i).old_bill_to_state         :=  l_account_header_tbl(1).bill_to_state;
              x_account_history_tbl(i).old_bill_to_postal_code   :=  l_account_header_tbl(1).bill_to_postal_code;
              x_account_history_tbl(i).old_bill_to_country       :=  l_account_header_tbl(1).bill_to_country;
              x_account_history_tbl(i).old_ship_to_address1      :=  l_account_header_tbl(1).ship_to_address1;
              x_account_history_tbl(i).old_ship_to_address2      :=  l_account_header_tbl(1).ship_to_address2;
              x_account_history_tbl(i).old_ship_to_address3      :=  l_account_header_tbl(1).ship_to_address3;
              x_account_history_tbl(i).old_ship_to_address4      :=  l_account_header_tbl(1).ship_to_address4;
              x_account_history_tbl(i).old_ship_to_city          :=  l_account_header_tbl(1).ship_to_city;
              x_account_history_tbl(i).old_ship_to_state         :=  l_account_header_tbl(1).ship_to_state;
              x_account_history_tbl(i).old_ship_to_postal_code   :=  l_account_header_tbl(1).ship_to_postal_code;
              x_account_history_tbl(i).old_ship_to_country       :=  l_account_header_tbl(1).ship_to_country;
              -- Resolve new history columns;
              l_account_header_tbl(1).party_account_id     := x_account_history_tbl(i).NEW_PARTY_ACCOUNT_ID;
              l_account_header_tbl(1).bill_to_address      := x_account_history_tbl(i).NEW_BILL_TO_ADDRESS;
              l_account_header_tbl(1).ship_to_address      := x_account_history_tbl(i).NEW_SHIP_TO_ADDRESS;
              l_account_header_tbl(1).party_account_number := NULL;
              l_account_header_tbl(1).party_account_name   := NULL;
              l_account_header_tbl(1).bill_to_location     := NULL;
              l_account_header_tbl(1).ship_to_location     := NULL;

              -- Following columns were added for bug 2670371
              l_account_header_tbl(1).bill_to_address1     := NULL;
              l_account_header_tbl(1).bill_to_address2     := NULL;
              l_account_header_tbl(1).bill_to_address3     := NULL;
              l_account_header_tbl(1).bill_to_address4     := NULL;
              l_account_header_tbl(1).bill_to_city         := NULL;
              l_account_header_tbl(1).bill_to_state        := NULL;
              l_account_header_tbl(1).bill_to_postal_code  := NULL;
              l_account_header_tbl(1).bill_to_country      := NULL;
              l_account_header_tbl(1).ship_to_address1     := NULL;
              l_account_header_tbl(1).ship_to_address2     := NULL;
              l_account_header_tbl(1).ship_to_address3     := NULL;
              l_account_header_tbl(1).ship_to_address4     := NULL;
              l_account_header_tbl(1).ship_to_city         := NULL;
              l_account_header_tbl(1).ship_to_state        := NULL;
              l_account_header_tbl(1).ship_to_postal_code  := NULL;
              l_account_header_tbl(1).ship_to_country      := NULL;

              csi_party_relationships_pvt.Resolve_id_columns(l_account_header_tbl);

              x_account_history_tbl(i).new_party_account_number  :=  l_account_header_tbl(1).party_account_number;
              x_account_history_tbl(i).new_party_account_name    :=  l_account_header_tbl(1).party_account_name;
              x_account_history_tbl(i).new_bill_to_location      :=  l_account_header_tbl(1).bill_to_location;
              x_account_history_tbl(i).new_ship_to_location      :=  l_account_header_tbl(1).ship_to_location;

              -- Following columns were added for bug 2670371

              x_account_history_tbl(i).new_bill_to_address1      :=  l_account_header_tbl(1).bill_to_address1;
              x_account_history_tbl(i).new_bill_to_address2      :=  l_account_header_tbl(1).bill_to_address2;
              x_account_history_tbl(i).new_bill_to_address3      :=  l_account_header_tbl(1).bill_to_address3;
              x_account_history_tbl(i).new_bill_to_address4      :=  l_account_header_tbl(1).bill_to_address4;
              x_account_history_tbl(i).new_bill_to_city          :=  l_account_header_tbl(1).bill_to_city;
              x_account_history_tbl(i).new_bill_to_state         :=  l_account_header_tbl(1).bill_to_state;
              x_account_history_tbl(i).new_bill_to_postal_code   :=  l_account_header_tbl(1).bill_to_postal_code;
              x_account_history_tbl(i).new_bill_to_country       :=  l_account_header_tbl(1).bill_to_country;
              x_account_history_tbl(i).new_ship_to_address1      :=  l_account_header_tbl(1).ship_to_address1;
              x_account_history_tbl(i).new_ship_to_address2      :=  l_account_header_tbl(1).ship_to_address2;
              x_account_history_tbl(i).new_ship_to_address3      :=  l_account_header_tbl(1).ship_to_address3;
              x_account_history_tbl(i).new_ship_to_address4      :=  l_account_header_tbl(1).ship_to_address4;
              x_account_history_tbl(i).new_ship_to_city          :=  l_account_header_tbl(1).ship_to_city;
              x_account_history_tbl(i).new_ship_to_state         :=  l_account_header_tbl(1).ship_to_state;
              x_account_history_tbl(i).new_ship_to_postal_code   :=  l_account_header_tbl(1).ship_to_postal_code;
              x_account_history_tbl(i).new_ship_to_country       :=  l_account_header_tbl(1).ship_to_country;

              IF NVL(x_account_history_tbl(i).old_party_account_id,fnd_api.g_miss_num)=
                 NVL(x_account_history_tbl(i).new_party_account_id,fnd_api.g_miss_num)
              THEN
                  x_account_history_tbl(i).old_party_account_id := NULL;
                  x_account_history_tbl(i).new_party_account_id := NULL;
              END IF;


              i := i + 1;

       END LOOP;

       -- End of API body

       -- Standard check of p_commit.
       /*
       IF FND_API.To_Boolean( p_commit ) THEN
             COMMIT WORK;
       END IF;
       */

       /***** srramakr commented for bug # 3304439
       -- Check for the profile option and disable the trace
       IF (l_flag = 'Y') THEN
            dbms_session.set_sql_trace(false);
       END IF;
       -- End disable trace
       ****/

       -- Standard call to get message count and if count is  get message info.
       FND_MSG_PUB.Count_And_Get
                (p_count        =>      x_msg_count ,
                 p_data         =>      x_msg_data   );
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
               -- ROLLBACK TO get_inst_party_account_hist;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (   p_count   =>      x_msg_count,
                    p_data    =>      x_msg_data );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
               -- ROLLBACK TO get_inst_party_account_hist;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (   p_count   =>      x_msg_count,
                    p_data    =>      x_msg_data  );
        WHEN OTHERS THEN
               -- ROLLBACK TO get_inst_party_account_hist;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF      FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       g_pkg_name          ,
                        l_api_name           );
                END IF;
                FND_MSG_PUB.Count_And_Get
                ( p_count     =>      x_msg_count,
                  p_data      =>      x_msg_data  );

END get_inst_party_account_hist;

END  csi_party_relationships_pvt ;

/
