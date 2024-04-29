--------------------------------------------------------
--  DDL for Package Body HZ_ACCT_CREATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_ACCT_CREATE_PKG" as
/* $Header: ARHACTFB.pls 120.4 2005/06/16 21:08:12 jhuang ship $ */

  FUNCTION INIT_SWITCH
  ( p_date   IN DATE,
    p_switch IN VARCHAR2 DEFAULT 'NULL_GMISS')
  RETURN DATE
  IS
   res_date date;
  BEGIN
   IF    p_switch = 'NULL_GMISS' THEN
     IF p_date IS NULL THEN
       res_date := FND_API.G_MISS_DATE;
     ELSE
       res_date := p_date;
     END IF;
   ELSIF p_switch = 'GMISS_NULL' THEN
     IF p_date = FND_API.G_MISS_DATE THEN
       res_date := NULL;
     ELSE
       res_date := p_date;
     END IF;
   ELSE
     res_date := TO_DATE('31/12/1800','DD/MM/RRRR');
   END IF;
   RETURN res_date;
  END;

  FUNCTION INIT_SWITCH
  ( p_char   IN VARCHAR2,
    p_switch IN VARCHAR2 DEFAULT 'NULL_GMISS')
  RETURN VARCHAR2
  IS
   res_char varchar2(2000);
  BEGIN
   IF    p_switch = 'NULL_GMISS' THEN
     IF p_char IS NULL THEN
       return FND_API.G_MISS_CHAR;
     ELSE
       return p_char;
     END IF;
   ELSIF p_switch = 'GMISS_NULL' THEN
     IF p_char = FND_API.G_MISS_CHAR THEN
       return NULL;
     ELSE
       return p_char;
     END IF;
   ELSE
     return ('INCORRECT_P_SWITCH');
   END IF;
  END;

  FUNCTION INIT_SWITCH
  ( p_num   IN NUMBER,
    p_switch IN VARCHAR2 DEFAULT 'NULL_GMISS')
  RETURN NUMBER
  IS
  BEGIN
   IF    p_switch = 'NULL_GMISS' THEN
     IF p_num IS NULL THEN
       return FND_API.G_MISS_NUM;
     ELSE
       return p_num;
     END IF;
   ELSIF p_switch = 'GMISS_NULL' THEN
     IF p_num = FND_API.G_MISS_NUM THEN
       return NULL;
     ELSE
       return p_num;
     END IF;
   ELSE
     return ('9999999999');
   END IF;
  END;

  PROCEDURE object_version_select
  (p_table_name                  IN VARCHAR2,
   p_col_id                      IN VARCHAR2,
   x_rowid                       IN OUT NOCOPY ROWID,
   x_object_version_number       IN OUT NOCOPY NUMBER,
   x_last_update_date            IN OUT NOCOPY DATE,
   x_id_value                    IN OUT NOCOPY NUMBER,
   x_return_status               IN OUT NOCOPY VARCHAR2,
   x_msg_count                   IN OUT NOCOPY NUMBER,
   x_msg_data                    IN OUT NOCOPY VARCHAR2 )
  IS
     CURSOR cu_cust_acct_version IS
     SELECT ROWID,
            OBJECT_VERSION_NUMBER,
            LAST_UPDATE_DATE,
            NULL
       FROM HZ_CUST_ACCOUNTS
      WHERE CUST_ACCOUNT_ID = p_col_id;

     CURSOR cu_cust_prof_version IS
     SELECT ROWID,
            OBJECT_VERSION_NUMBER,
            LAST_UPDATE_DATE,
            CUST_ACCOUNT_ID
       FROM HZ_CUSTOMER_PROFILES
      WHERE CUST_ACCOUNT_PROFILE_ID = p_col_id;

     CURSOR cu_org IS
     SELECT ROWID,
            OBJECT_VERSION_NUMBER,
            LAST_UPDATE_DATE,
            NULL
       FROM HZ_PARTIES
      WHERE PARTY_ID  = p_col_id;

    l_last_update_date   DATE;
  BEGIN
    IF p_table_name = 'HZ_CUST_ACCOUNTS' THEN
         OPEN cu_cust_acct_version;
         FETCH cu_cust_acct_version INTO
           x_rowid                ,
           x_object_version_number,
           l_last_update_date     ,
           x_id_value;
         CLOSE cu_cust_acct_version;
    ELSIF p_table_name = 'HZ_CUSTOMER_PROFILES' THEN
         OPEN cu_cust_prof_version;
         FETCH cu_cust_prof_version INTO
           x_rowid                ,
           x_object_version_number,
           l_last_update_date     ,
           x_id_value;
         CLOSE cu_cust_prof_version;
    ELSIF p_table_name = 'HZ_ORG_PERS' THEN
         OPEN cu_org;
         FETCH cu_org INTO
           x_rowid                ,
           x_object_version_number,
           l_last_update_date     ,
           x_id_value;
         CLOSE cu_org;
    END IF;
    IF x_rowid IS NULL THEN
        FND_MESSAGE.SET_NAME('AR','HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD',p_table_name);
        FND_MESSAGE.SET_TOKEN('ID',p_col_id);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    ELSE
     IF TO_CHAR(x_last_update_date,'DD-MON-YYYY HH:MI:SS') <>
        TO_CHAR(l_last_update_date,'DD-MON-YYYY HH:MI:SS')
     THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
        FND_MESSAGE.SET_TOKEN('TABLE', p_table_name);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   END IF;
  END;

 PROCEDURE update_flag
  ( p_party_id      IN NUMBER,
    p_flag_name     IN VARCHAR2,
    p_flag_value    IN VARCHAR2,
    x_return_status IN OUT NOCOPY VARCHAR2,
    x_msg_data      IN OUT NOCOPY VARCHAR2)
 IS
   CURSOR cu_party_update
   IS
   SELECT party_id
     FROM hz_parties
    WHERE party_id =  p_party_id
      FOR UPDATE OF party_id NOWAIT;
   l_lock NUMBER;
 BEGIN
   OPEN cu_party_update;
   FETCH cu_party_update INTO l_lock;
   IF cu_party_update%FOUND THEN
     IF    p_flag_name = 'REFERENCE_FOR' THEN
       UPDATE hz_parties
          SET REFERENCE_USE_FLAG = p_flag_value
        WHERE party_id = p_party_id;
      ELSIF p_flag_name = 'PARTNER_OF' THEN
       UPDATE hz_parties
          SET THIRD_PARTY_FLAG = p_flag_value
        WHERE party_id = p_party_id;
      ELSIF p_flag_name = 'COMPETITOR_OF' THEN
        UPDATE hz_parties
           SET COMPETITOR_FLAG = p_flag_value
         WHERE party_id = p_party_id;
      END IF;
   ELSE
        FND_MESSAGE.SET_NAME('AR','HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD','HZ_PARTIES');
        FND_MESSAGE.SET_TOKEN('ID',p_party_id);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;
   CLOSE cu_party_update;
  EXCEPTION
   WHEN OTHERS THEN
        IF cu_party_update%ISOPEN THEN
           CLOSE cu_party_update;
        END IF;
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 END;

 PROCEDURE SetFlagRelationship
   (p_rel_code                    IN VARCHAR2,
    c_flag                        IN VARCHAR2,
    c_party_id                    IN VARCHAR2,
    c_party_type                  IN VARCHAR2,
    i_internal_party_id           IN NUMBER,
    i_internal_party_type         IN VARCHAR2,
    x_return_status               IN OUT NOCOPY VARCHAR2,
    x_msg_count                   IN OUT NOCOPY NUMBER,
    x_msg_data                    IN OUT NOCOPY VARCHAR2,
    x_end_date                    IN DATE DEFAULT SYSDATE)
  IS
    cursor C_REFERENCE_FOR is
     select relationship_id ,
            end_date
       from hz_relationships
      where subject_id         = c_party_id
        and relationship_code  = 'REFERENCE_FOR'
        and subject_table_name = 'HZ_PARTIES'
        and object_table_name  = 'HZ_PARTIES'
        and directional_flag   = 'F';

    cursor C_PARTNER_OF is
       select relationship_id ,
              end_date
         from hz_relationships
        where subject_id = c_party_id
          and relationship_code = 'PARTNER_OF'
          and subject_table_name = 'HZ_PARTIES'
          and object_table_name = 'HZ_PARTIES'
          and directional_flag = 'F';

     cursor C_COMPETITOR_OF is
        select relationship_id,
               end_date
          from hz_relationships
         where subject_id = c_party_id
           and relationship_code = 'COMPETITOR_OF'
           and subject_table_name = 'HZ_PARTIES'
           and object_table_name = 'HZ_PARTIES'
           and directional_flag = 'F';

     l_party_rel_object_version    NUMBER;
     l_party_object_version        NUMBER;
     x_party_rel_last_update_date  DATE;
     x_party_last_update_date      DATE;
     prel_rec                      hz_relationship_v2pub.relationship_rec_type;
     i_pr_party_relationship_id    NUMBER;
     i_pr_party_id                 NUMBER;
     i_pr_party_number             VARCHAR2(100);
     x_party_rel_id                NUMBER;
     l_end_date                    DATE;

     CURSOR cu_rel_type IS
     SELECT relationship_type,
            create_party_flag
       FROM hz_relationship_types
      WHERE forward_rel_code = p_rel_code
        AND subject_type     = c_party_type
        AND object_type      = i_internal_party_type
        AND status           = 'A'
        AND rownum           = 1;

     l_rel_type                   VARCHAR2(30);
     l_create_party               VARCHAR2(1);

  BEGIN

      IF    p_rel_code = 'REFERENCE_FOR' THEN
        OPEN  C_REFERENCE_FOR;
        FETCH C_REFERENCE_FOR INTO x_party_rel_id, l_end_date;
        CLOSE C_REFERENCE_FOR;
      ELSIF p_rel_code = 'PARTNER_OF' THEN
        OPEN  C_PARTNER_OF;
        FETCH C_PARTNER_OF INTO x_party_rel_id, l_end_date;
        CLOSE C_PARTNER_OF;
      ELSIF p_rel_code = 'COMPETITOR_OF' THEN
        OPEN  C_COMPETITOR_OF;
        FETCH C_COMPETITOR_OF INTO x_party_rel_id, l_end_date;
        CLOSE C_COMPETITOR_OF;
      END IF;

      IF     x_party_rel_id IS NULL AND C_Flag = 'Y' THEN

              OPEN cu_rel_type;
              FETCH cu_rel_type INTO l_rel_type,  l_create_party;
              CLOSE cu_rel_type;

              prel_rec.subject_id        := c_party_id;
              prel_rec.subject_table_name:= 'HZ_PARTIES';
              prel_rec.subject_type      := c_party_type;
              prel_rec.object_id         := i_internal_party_id;
              prel_rec.object_table_name := 'HZ_PARTIES';
              prel_rec.object_type       := i_internal_party_type;
              prel_rec.start_date        := SYSDATE;
              prel_rec.end_date          := NULL;
              prel_rec.relationship_type := l_rel_type;
              prel_rec.relationship_code := p_rel_code;
              prel_rec.status            := 'A';
              prel_rec.created_by_module := 'TCA_FORM_WRAPPER';

               -- call V2 API.
               HZ_RELATIONSHIP_V2PUB.create_relationship (
                 p_relationship_rec            => prel_rec,
                 x_relationship_id             => i_pr_party_relationship_id,
                 x_party_id                    => i_pr_party_id,
                 x_party_number                => i_pr_party_number,
                 x_return_status               => x_return_status,
                 x_msg_count                   => x_msg_count,
                 x_msg_data                    => x_msg_data );

       ELSIF x_party_rel_id IS NOT NULL AND C_Flag = 'Y' THEN

          IF TRUNC(l_end_date) <= TRUNC(SYSDATE) THEN

             SELECT last_update_date ,
                    object_version_number
               INTO x_party_rel_last_update_date ,
                    l_party_rel_object_version
               FROM hz_relationships
              WHERE relationship_id = x_party_rel_id
                AND subject_table_name = 'HZ_PARTIES'
                AND object_table_name  = 'HZ_PARTIES'
                AND directional_flag   = 'F';

             SELECT last_update_date,
                    object_version_number
               INTO x_party_last_update_date,
                    l_party_object_version
               FROM hz_parties
              WHERE party_id = c_party_id;

              prel_rec.relationship_id   := x_party_rel_id;
              prel_rec.subject_id        := c_party_id;
              prel_rec.subject_table_name:= 'HZ_PARTIES';
              prel_rec.subject_type      := c_party_type;
              prel_rec.object_id         := i_internal_party_id;
              prel_rec.object_table_name := 'HZ_PARTIES';
              prel_rec.object_type       := i_internal_party_type;
              prel_rec.end_date          := TO_DATE('31124712','DDMMYYYY');
              prel_rec.relationship_type := l_rel_type;
              prel_rec.relationship_code := p_rel_code;
              prel_rec.status            := 'A';
--              prel_rec.created_by_module := 'TCA_FORM_WRAPPER';

              x_party_last_update_date  := NULL;

              HZ_RELATIONSHIP_V2PUB.update_relationship (
                  p_relationship_rec            => prel_rec,
                  p_object_version_number       => l_party_rel_object_version,
                  p_party_object_version_number => l_party_object_version,
                  x_return_status               => x_return_status,
                  x_msg_count                   => x_msg_count,
                  x_msg_data                    => x_msg_data );

              IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                update_flag(
                   p_party_id      => c_party_id,
                   p_flag_name     => p_rel_code,
                   p_flag_value    => C_flag,
                   x_return_status => x_return_status,
                   x_msg_data      => x_msg_data);
              END IF;

           END IF;

       ELSIF x_party_rel_id IS NOT NULL AND C_Flag = 'N' THEN

          IF TRUNC(l_end_date) > TRUNC(SYSDATE) THEN

             SELECT last_update_date ,
                    object_version_number
               INTO x_party_rel_last_update_date ,
                    l_party_rel_object_version
               FROM hz_relationships
              WHERE relationship_id = x_party_rel_id
                AND subject_table_name = 'HZ_PARTIES'
                AND object_table_name  = 'HZ_PARTIES'
                AND directional_flag   = 'F';

             SELECT last_update_date,
                    object_version_number
               INTO x_party_last_update_date,
                    l_party_object_version
               FROM hz_parties
              WHERE party_id = c_party_id;

              prel_rec.relationship_id   := x_party_rel_id;
              prel_rec.subject_id        := c_party_id;
              prel_rec.subject_table_name:= 'HZ_PARTIES';
              prel_rec.subject_type      := c_party_type;
              prel_rec.object_id         := i_internal_party_id;
              prel_rec.object_table_name := 'HZ_PARTIES';
              prel_rec.object_type       := i_internal_party_type;
              prel_rec.end_date          := SYSDATE;
              prel_rec.relationship_type := l_rel_type;
              prel_rec.relationship_code := p_rel_code;
              prel_rec.status            := 'A';
--              prel_rec.created_by_module := 'TCA_FORM_WRAPPER';


              x_party_last_update_date := NULL;

              HZ_RELATIONSHIP_V2PUB.update_relationship (
                  p_relationship_rec            => prel_rec,
                  p_object_version_number       => l_party_rel_object_version,
                  p_party_object_version_number => l_party_object_version,
                  x_return_status               => x_return_status,
                  x_msg_count                   => x_msg_count,
                  x_msg_data                    => x_msg_data );

         -- Need to be commented on once HZ_RELATIONSHIP_V2PUB.update_relationship is fixed.
              IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                update_flag(
                   p_party_id      => c_party_id,
                   p_flag_name     => p_rel_code,
                   p_flag_value    => C_flag,
                   x_return_status => x_return_status,
                   x_msg_data      => x_msg_data);
              END IF;

         END IF;

      END IF;
 END SetFlagRelationship;


 PROCEDURE Ref_Part_Comp
  (c_party_id                    IN VARCHAR2,
   c_party_type                  IN VARCHAR2,
   i_internal_party_id           IN NUMBER,
   C_Reference_Use_Flag          IN VARCHAR2,
   C_Third_Party_Flag            IN VARCHAR2,
   C_competitor_flag             IN VARCHAr2,
   x_return_status               IN OUT NOCOPY VARCHAR2,
   x_msg_count                   IN OUT NOCOPY NUMBER,
   x_msg_data                    IN OUT NOCOPY VARCHAR2,
   x_end_date                    IN DATE DEFAULT SYSDATE)
 IS

  CURSOR cu_internal_type IS
  SELECT party_type
    FROM hz_parties
   WHERE party_id = i_internal_party_id;
  l_internal_party_type  VARCHAR2(30);

 BEGIN
   IF    C_Reference_Use_Flag IS NOT NULL
      OR C_Third_Party_Flag   IS NOT NULL
      OR c_competitor_flag    IS NOT NULL
  THEN
       OPEN cu_internal_type;
       FETCH cu_internal_type INTO l_internal_party_type;
       CLOSE cu_internal_type;

       IF C_Reference_Use_Flag IS NOT NULL then
           SetFlagRelationship
             ( p_rel_code            => 'REFERENCE_FOR',
               c_flag                => C_Reference_Use_Flag,
               c_party_id            => c_party_id,
               c_party_type          => c_party_type,
               i_internal_party_id   => i_internal_party_id,
               i_internal_party_type => l_internal_party_type,
               x_return_status       => x_return_status,
               x_msg_count           => x_msg_count,
               x_msg_data            => x_msg_data ,
               x_end_date            => x_end_date);

       END IF;

       IF C_Third_Party_Flag IS NOT NULL THEN
           SetFlagRelationship
             ( p_rel_code            => 'PARTNER_OF',
               c_flag                => C_Third_Party_Flag ,
               c_party_id            => c_party_id,
               c_party_type          => c_party_type,
               i_internal_party_id   => i_internal_party_id,
               i_internal_party_type => l_internal_party_type,
               x_return_status       => x_return_status,
               x_msg_count           => x_msg_count,
               x_msg_data            => x_msg_data ,
               x_end_date            => x_end_date);
       END IF;

       IF c_competitor_flag IS NOT NULL THEN
           SetFlagRelationship
             ( p_rel_code            => 'COMPETITOR_OF',
               c_flag                => c_competitor_flag,
               c_party_id            => c_party_id,
               c_party_type          => c_party_type,
               i_internal_party_id   => i_internal_party_id,
               i_internal_party_type => l_internal_party_type,
               x_return_status       => x_return_status,
               x_msg_count           => x_msg_count,
               x_msg_data            => x_msg_data ,
               x_end_date            => x_end_date);
       END IF;
   END IF;
 END Ref_Part_Comp;

 PROCEDURE insert_row(
                       c_cust_account_id                IN OUT NOCOPY NUMBER ,
                       c_party_id                       IN OUT NOCOPY NUMBER,
                       c_account_number                  IN OUT NOCOPY VARCHAR2,
                       c_Attribute_Category              IN VARCHAR2,
                       c_Attribute1                      IN VARCHAR2,
                       c_Attribute2                      IN VARCHAR2,
                       c_Attribute3                      IN VARCHAR2,
                       c_Attribute4                      IN VARCHAR2,
                       c_Attribute5                      IN VARCHAR2,
                       c_Attribute6                      IN VARCHAR2,
                       c_Attribute7                      IN VARCHAR2,
                       c_Attribute8                      IN VARCHAR2,
                       c_Attribute9                      IN VARCHAR2,
                       c_Attribute10                     IN VARCHAR2,
                       c_Attribute11                     IN VARCHAR2,
                       c_Attribute12                     IN VARCHAR2,
                       c_Attribute13                     IN VARCHAR2,
                       c_Attribute14                     IN VARCHAR2,
                       c_Attribute15                     IN VARCHAR2,
                       c_Attribute16                     IN VARCHAR2,
                       c_Attribute17                     IN VARCHAR2,
                       c_Attribute18                     IN VARCHAR2,
                       c_Attribute19                     IN VARCHAR2,
                       c_Attribute20                     IN VARCHAR2,
                       c_global_attribute_category         IN VARCHAR2,
                       c_global_attribute1                 IN VARCHAR2,
                       c_global_attribute2                 IN VARCHAR2,
                       c_global_attribute3                 IN VARCHAR2,
                       c_global_attribute4                 IN VARCHAR2,
                       c_global_attribute5                 IN VARCHAR2,
                       c_global_attribute6                 IN VARCHAR2,
                       c_global_attribute7                 IN VARCHAR2,
                       c_global_attribute8                 IN VARCHAR2,
                       c_global_attribute9                 IN VARCHAR2,
                       c_global_attribute10                IN VARCHAR2,
                       c_global_attribute11                IN VARCHAR2,
                       c_global_attribute12                IN VARCHAR2,
                       c_global_attribute13                IN VARCHAR2,
                       c_global_attribute14                IN VARCHAR2,
                       c_global_attribute15                IN VARCHAR2,
                       c_global_attribute16                IN VARCHAR2,
                       c_global_attribute17                IN VARCHAR2,
                       c_global_attribute18                IN VARCHAR2,
                       c_global_attribute19                IN VARCHAR2,
                       c_global_attribute20                IN VARCHAR2,
                       c_orig_system_reference             IN VARCHAR2,
                       c_status                            IN VARCHAR2,
                       c_customer_type                     IN VARCHAR2,
                       c_customer_class_code               IN VARCHAR2,
                       c_primary_salesrep_id               IN NUMBER ,
                       c_sales_channel_code                IN VARCHAR2,
                       c_order_type_id                     IN NUMBER,
                       c_price_list_id                     IN NUMBER ,
                       c_category_code                     IN VARCHAR2,
                       c_reference_use_flag                IN VARCHAR2,
                       c_tax_code                          IN VARCHAR2,
                       c_third_party_flag                  IN VARCHAR2,
                       c_competitor_flag                   IN VARCHAR2,
                       c_fob_point                         IN VARCHAR2,
                       c_tax_header_level_flag             IN VARCHAR2,
                       c_tax_rounding_rule                 IN VARCHAR2,
                       c_account_name                      IN VARCHAR2,
                       c_freight_term                      IN VARCHAR2,
                       c_ship_partial                      IN VARCHAR2,
                       c_ship_via                          IN VARCHAR2,
                       c_warehouse_id                      IN NUMBER,
                       c_payment_term_id                   IN NUMBER ,
                       c_DATES_NEGATIVE_TOLERANCE          IN NUMBER,
                       c_DATES_POSITIVE_TOLERANCE          IN NUMBER,
                       c_DATE_TYPE_PREFERENCE              IN VARCHAR2,
                       c_OVER_SHIPMENT_TOLERANCE           IN NUMBER,
                       c_UNDER_SHIPMENT_TOLERANCE          IN NUMBER,
                       c_ITEM_CROSS_REF_PREF               IN VARCHAR2,
                       c_OVER_RETURN_TOLERANCE             IN NUMBER,
                       c_UNDER_RETURN_TOLERANCE            IN NUMBER,
                       c_SHIP_SETS_INCLUDE_LINES_FLAG      IN VARCHAR2,
                       c_ARRIVALSETS_INCL_LINES_FLAG       IN VARCHAR2,
                       c_SCHED_DATE_PUSH_FLAG              IN VARCHAR2,
                       c_INVOICE_QUANTITY_RULE             IN VARCHAR2,
                       t_party_id                          IN NUMBER ,
                       t_party_number                  IN OUT NOCOPY VARCHAR2,
                       t_customer_key                      IN VARCHAR2,
                       t_Attribute_Category                IN VARCHAR2,
                       t_Attribute1                        IN VARCHAR2,
                       t_Attribute2                        IN VARCHAR2,
                       t_Attribute3                        IN VARCHAR2,
                       t_Attribute4                        IN VARCHAR2,
                       t_Attribute5                        IN VARCHAR2,
                       t_Attribute6                        IN VARCHAR2,
                       t_Attribute7                        IN VARCHAR2,
                       t_Attribute8                        IN VARCHAR2,
                       t_Attribute9                        IN VARCHAR2,
                       t_Attribute10                       IN VARCHAR2,
                       t_Attribute11                       IN VARCHAR2,
                       t_Attribute12                       IN VARCHAR2,
                       t_Attribute13                       IN VARCHAR2,
                       t_Attribute14                       IN VARCHAR2,
                       t_Attribute15                       IN VARCHAR2,
                       t_Attribute16                       IN VARCHAR2,
                       t_Attribute17                       IN VARCHAR2,
                       t_Attribute18                       IN VARCHAR2,
                       t_Attribute19                       IN VARCHAR2,
                       t_Attribute20                       IN VARCHAR2,
                       t_global_attribute_category         IN VARCHAR2,
                       t_global_attribute1                 IN VARCHAR2,
                       t_global_attribute2                 IN VARCHAR2,
                       t_global_attribute3                 IN VARCHAR2,
                       t_global_attribute4                 IN VARCHAR2,
                       t_global_attribute5                 IN VARCHAR2,
                       t_global_attribute6                 IN VARCHAR2,
                       t_global_attribute7                 IN VARCHAR2,
                       t_global_attribute8                 IN VARCHAR2,
                       t_global_attribute9                 IN VARCHAR2,
                       t_global_attribute10                IN VARCHAR2,
                       t_global_attribute11                IN VARCHAR2,
                       t_global_attribute12                IN VARCHAR2,
                       t_global_attribute13                IN VARCHAR2,
                       t_global_attribute14                IN VARCHAR2,
                       t_global_attribute15                IN VARCHAR2,
                       t_global_attribute16                IN VARCHAR2,
                       t_global_attribute17                IN VARCHAR2,
                       t_global_attribute18                IN VARCHAR2,
                       t_global_attribute19                IN VARCHAR2,
                       t_global_attribute20                IN VARCHAR2,
                       o_party_name                        IN VARCHAR2,
                       o_sic_code                          IN VARCHAR2,
                       o_sic_code_type                     IN VARCHAR2,
                       o_analysis_fy                       IN VARCHAR2,
                       o_fiscal_yearend_month              IN VARCHAR2,
                       o_num_of_employees                  IN NUMBER ,
                       o_curr_fy_potential_revenue         IN NUMBER ,
                       o_next_fy_potential_revenue         IN NUMBER ,
                       o_tax_reference                     IN VARCHAR2,
                       o_year_established                  IN NUMBER ,
                       o_gsa_indicator_flag                IN VARCHAR2,
                       o_mission_statement                 IN VARCHAR2,
                       o_duns_number                       IN NUMBER,
                       o_tax_name                          IN VARCHAR2,
                       o_organization_type                 IN VARCHAR2,
                       o_taxpayer_id                       IN VARCHAR2,
                       o_party_name_phonetic               IN VARCHAR2,
                       p_cust_account_profile_id           IN NUMBER ,
                       p_cust_account_id                   IN NUMBER ,
                       p_status                            IN VARCHAR2,
                       p_collector_id                      IN NUMBER ,
                       p_credit_analyst_id                 IN NUMBER ,
                       p_credit_checking                   IN VARCHAR2,
                       p_next_credit_review_date              DATE ,
                       p_tolerance                         IN NUMBER,
                       p_discount_terms                    IN VARCHAR2,
                       p_dunning_letters                   IN VARCHAR2,
                       p_interest_charges                  IN VARCHAR2,
                       p_send_statements                   IN VARCHAR2,
                       p_credit_balance_statements         IN VARCHAR2,
                       p_credit_hold                       IN VARCHAR2,
                       p_profile_class_id                  IN NUMBER ,
                       p_site_use_id                       IN NUMBER ,
                       p_credit_rating                     IN VARCHAR2,
                       p_risk_code                         IN VARCHAR2,
                       p_standard_terms                    IN NUMBER ,
                       p_override_terms                    IN VARCHAR2,
                       p_dunning_letter_set_id             IN NUMBER,
                       p_interest_period_days              IN NUMBER,
                       p_payment_grace_days                IN NUMBER,
                       p_discount_grace_days               IN NUMBER,
                       p_statement_cycle_id                IN NUMBER ,
                       p_account_status                    IN VARCHAR2,
                       p_percent_collectable               IN NUMBER ,
                       p_autocash_hierarchy_id             IN NUMBER,
                       p_Attribute_Category                IN VARCHAR2,
                       p_Attribute1                        IN VARCHAR2,
                       p_Attribute2                        IN VARCHAR2,
                       p_Attribute3                        IN VARCHAR2,
                       p_Attribute4                        IN VARCHAR2,
                       p_Attribute5                        IN VARCHAR2,
                       p_Attribute6                        IN VARCHAR2,
                       p_Attribute7                        IN VARCHAR2,
                       p_Attribute8                        IN VARCHAR2,
                       p_Attribute9                        IN VARCHAR2,
                       p_Attribute10                       IN VARCHAR2,
                       p_Attribute11                       IN VARCHAR2,
                       p_Attribute12                       IN VARCHAR2,
                       p_Attribute13                       IN VARCHAR2,
                       p_Attribute14                       IN VARCHAR2,
                       p_Attribute15                       IN VARCHAR2,
                       p_auto_rec_incl_disputed_flag       IN VARCHAR2,
                       p_tax_printing_option               IN VARCHAR2,
                       p_charge_on_fin_charge_flag         IN VARCHAR2,
                       p_grouping_rule_id                  IN NUMBER ,
                       p_clearing_days                     IN NUMBER,
                       p_jgzz_attribute_category           IN VARCHAR2,
                       p_jgzz_attribute1                   IN VARCHAR2,
                       p_jgzz_attribute2                   IN VARCHAR2,
                       p_jgzz_attribute3                   IN VARCHAR2,
                       p_jgzz_attribute4                   IN VARCHAR2,
                       p_jgzz_attribute5                   IN VARCHAR2,
                       p_jgzz_attribute6                   IN VARCHAR2,
                       p_jgzz_attribute7                   IN VARCHAR2,
                       p_jgzz_attribute8                   IN VARCHAR2,
                       p_jgzz_attribute9                   IN VARCHAR2,
                       p_jgzz_attribute10                  IN VARCHAR2,
                       p_jgzz_attribute11                  IN VARCHAR2,
                       p_jgzz_attribute12                  IN VARCHAR2,
                       p_jgzz_attribute13                  IN VARCHAR2,
                       p_jgzz_attribute14                  IN VARCHAR2,
                       p_jgzz_attribute15                  IN VARCHAR2,
                       p_global_attribute_category         IN VARCHAR2,
                       p_global_attribute1                 IN VARCHAR2,
                       p_global_attribute2                 IN VARCHAR2,
                       p_global_attribute3                 IN VARCHAR2,
                       p_global_attribute4                 IN VARCHAR2,
                       p_global_attribute5                 IN VARCHAR2,
                       p_global_attribute6                 IN VARCHAR2,
                       p_global_attribute7                 IN VARCHAR2,
                       p_global_attribute8                 IN VARCHAR2,
                       p_global_attribute9                 IN VARCHAR2,
                       p_global_attribute10                IN VARCHAR2,
                       p_global_attribute11                IN VARCHAR2,
                       p_global_attribute12                IN VARCHAR2,
                       p_global_attribute13                IN VARCHAR2,
                       p_global_attribute14                IN VARCHAR2,
                       p_global_attribute15                IN VARCHAR2,
                       p_global_attribute16                IN VARCHAR2,
                       p_global_attribute17                IN VARCHAR2,
                       p_global_attribute18                IN VARCHAR2,
                       p_global_attribute19                IN VARCHAR2,
                       p_global_attribute20                IN VARCHAR2,
                       p_cons_inv_flag                     IN VARCHAR2,
                       p_cons_inv_type                     IN VARCHAR2,
                       p_autocash_hier_id_for_adr          IN NUMBER ,
                       p_lockbox_matching_option           IN VARCHAR2,
--{2310474
                       p_party_id                          IN NUMBER    DEFAULT NULL,
                       p_review_cycle                      IN VARCHAR2  DEFAULT NULL,
                       p_credit_classification             IN VARCHAR2  DEFAULT NULL,
                       p_last_credit_review_date           IN DATE      DEFAULT NULL,
--}
                       o_organization_profile_id       IN OUT NOCOPY NUMBER,
                       x_msg_count                        OUT NOCOPY NUMBER,
                       x_msg_data                         OUT NOCOPY varchar2,
                       x_return_status                    OUT NOCOPY VARCHAR2,
                       o_duns_number_c                     IN VARCHAR2 DEFAULT FND_API.G_MISS_CHAR )

  IS

--  acct_rec  hz_customer_accounts_pub.account_rec_type;
--  party_rec hz_party_pub.party_rec_type;
--  org_rec   hz_party_pub.organization_rec_type;
--  prel_rec  hz_party_pub.party_rel_rec_type;
--  prof_rec  hz_customer_accounts_pub.cust_profile_rec_type;

    acct_rec  hz_cust_account_v2pub.cust_account_rec_type;
    party_rec hz_party_v2pub.party_rec_type;
    org_rec   hz_party_v2pub.organization_rec_type;
    prel_rec  hz_relationship_v2pub.relationship_rec_type;
    prof_rec  hz_customer_profile_v2pub.customer_profile_rec_type;

    /*Bug  3013045*/
    org_rec_update    hz_party_v2pub.organization_rec_type;
    l_flag BOOLEAN;
    l_party_rowid                 ROWID;
    l_party_last_update_date      DATE;
    l_dummy_id                    NUMBER;
    /*End bug 3013045*/
    tmp_var                    VARCHAR2(2000);
    i                          NUMBER;
    tmp_var1                   VARCHAR2(2000);
    x_customer_id              NUMBER;
    x_cust_account_number      VARCHAR2(100);
    x_party_id                 NUMBER;
    x_party_number             VARCHAR2(100);
    i_internal_party_id        NUMBER;
    i_pr_party_relationship_id NUMBER;
    i_pr_party_id              NUMBER;
    i_pr_party_number          VARCHAR2(100);
    -- create_internal_party   VARCHAR2(1) := 'Y';
    x_code_assignment_id       NUMBER;
    x_party_rel_id             NUMBER;
    l_party_rel_object_version NUMBER;
    l_party_object_version     NUMBER;

    x_party_last_update_date     date;
    X_PARTY_REL_LAST_UPDATE_DATE date;

  BEGIN

    x_return_status   := FND_API.G_RET_STS_SUCCESS;

    /*Bug  3013045*/
    IF c_party_id is not null
    THEN
       l_flag := TRUE;
    END IF;

    ---------------------------------
    -- For Organization            --
    ---------------------------------
    -- V2 REC TYPE Customer Account--
    ---------------------------------
    acct_rec.cust_account_id        := C_Cust_account_Id;
    -- acct_rec.party_id             	 := C_Party_Id;
    acct_rec.account_number         := C_account_Number;
    acct_rec.attribute_category     := C_Attribute_Category;
    acct_rec.attribute1             := C_Attribute1;
    acct_rec.attribute2             := C_Attribute2;
    acct_rec.attribute3             := C_Attribute3;
    acct_rec.attribute4             := C_Attribute4;
    acct_rec.attribute5             := C_Attribute5;
    acct_rec.attribute6             := C_Attribute6;
    acct_rec.attribute7             := C_Attribute7;
    acct_rec.attribute8             := C_Attribute8;
    acct_rec.attribute9             := C_Attribute9;
    acct_rec.attribute10            := C_Attribute10;
    acct_rec.attribute11            := C_Attribute11;
    acct_rec.attribute12            := C_Attribute12;
    acct_rec.attribute13            := C_Attribute13;
    acct_rec.attribute14            := C_Attribute14;
    acct_rec.attribute15            := C_Attribute15;
    acct_rec.attribute16            := C_Attribute16;
    acct_rec.attribute17            := C_Attribute17;
    acct_rec.attribute18            := C_Attribute18;
    acct_rec.attribute19            := C_Attribute19;
    acct_rec.attribute20            := C_Attribute20;
    acct_rec.global_attribute_category := C_Global_Attribute_Category;
    acct_rec.global_attribute1      := C_Global_Attribute1;
    acct_rec.global_attribute2      := C_Global_Attribute2;
    acct_rec.global_attribute3      := C_Global_Attribute3;
    acct_rec.global_attribute4      := C_Global_Attribute4;
    acct_rec.global_attribute5      := C_Global_Attribute5;
    acct_rec.global_attribute6      := C_Global_Attribute6;
    acct_rec.global_attribute7      := C_Global_Attribute7;
    acct_rec.global_attribute8      := C_Global_Attribute8;
    acct_rec.global_attribute9      := C_Global_Attribute9;
    acct_rec.global_attribute10     := C_Global_Attribute10;
    acct_rec.global_attribute11     := C_Global_Attribute11;
    acct_rec.global_attribute12     := C_Global_Attribute12;
    acct_rec.global_attribute13     := C_Global_Attribute13;
    acct_rec.global_attribute14     := C_Global_Attribute14;
    acct_rec.global_attribute15     := C_Global_Attribute15;
    acct_rec.global_attribute16     := C_Global_Attribute16;
    acct_rec.global_attribute17     := C_Global_Attribute17;
    acct_rec.global_attribute18     := C_Global_Attribute18;
    acct_rec.global_attribute19     := C_Global_Attribute19;
    acct_rec.global_attribute20     := C_Global_Attribute20;
    acct_rec.orig_system_reference  := C_Orig_System_Reference;
    acct_rec.status                 := C_Status;
    acct_rec.customer_type          := c_customer_type;
    acct_rec.customer_class_code    := C_Customer_Class_Code;
    acct_rec.primary_salesrep_id    := C_Primary_Salesrep_Id;
    acct_rec.sales_channel_code     := C_Sales_Channel_Code;
    acct_rec.order_type_id          := C_Order_Type_Id;
    acct_rec.price_list_id          := C_Price_List_Id;
    acct_rec.tax_code               := C_Tax_Code;
    acct_rec.fob_point              := C_Fob_Point;
    acct_rec.tax_header_level_flag  := C_Tax_Header_Level_Flag;
    acct_rec.tax_rounding_rule      := C_Tax_Rounding_Rule;
    acct_rec.primary_specialist_id  := NULL;
    acct_rec.secondary_specialist_id := NULL;
    -- acct_rec.geo_code                := NULL;
    acct_rec.account_name            := c_account_name;
    acct_rec.freight_term            := C_Freight_Term;
    acct_rec.ship_partial            := C_Ship_Partial;
    acct_rec.ship_via                := C_Ship_Via;
    acct_rec.warehouse_id            := C_Warehouse_Id;
    -- acct_rec.payment_term_id         := NULL;
    acct_rec.account_liable_flag     := NULL;
    acct_rec.DATES_NEGATIVE_TOLERANCE:= c_DATES_NEGATIVE_TOLERANCE;
    acct_rec.DATES_POSITIVE_TOLERANCE:= c_DATES_POSITIVE_TOLERANCE;
    acct_rec.DATE_TYPE_PREFERENCE    := c_DATE_TYPE_PREFERENCE;
    acct_rec.OVER_SHIPMENT_TOLERANCE := c_OVER_SHIPMENT_TOLERANCE;
    acct_rec.UNDER_SHIPMENT_TOLERANCE:= c_UNDER_SHIPMENT_TOLERANCE;
    acct_rec.ITEM_CROSS_REF_PREF     := c_ITEM_CROSS_REF_PREF;
    acct_rec.SHIP_SETS_INCLUDE_LINES_FLAG := c_SHIP_SETS_INCLUDE_LINES_FLAG;
    acct_rec.ARRIVALSETS_INCLUDE_LINES_FLAG := c_ARRIVALSETS_INCL_LINES_FLAG;
    acct_rec.SCHED_DATE_PUSH_FLAG    := c_SCHED_DATE_PUSH_FLAG;
    acct_rec.INVOICE_QUANTITY_RULE   := c_INVOICE_QUANTITY_RULE;
    acct_rec.OVER_RETURN_TOLERANCE   := c_OVER_RETURN_TOLERANCE;
    acct_rec.UNDER_RETURN_TOLERANCE  := c_UNDER_RETURN_TOLERANCE;
    acct_rec.created_by_module       := 'TCA_FORM_WRAPPER';


    -------------------------------
    -- V2 REC TYPE Organization
    -------------------------------
    org_rec.party_rec.party_id     := c_party_id;
    org_rec.organization_name      := o_party_name;
    org_rec.sic_code               := o_sic_code;
    org_rec.sic_code_type          := o_sic_code_type;
    org_rec.analysis_fy            := o_analysis_fy;
    org_rec.fiscal_yearend_month   := o_fiscal_yearend_month;
    org_rec.employees_total        := o_num_of_employees;
    org_rec.curr_fy_potential_revenue  := o_curr_fy_potential_revenue;
    org_rec.next_fy_potential_revenue  := o_next_fy_potential_revenue;
    org_rec.tax_reference          := o_Tax_Reference;
    org_rec.year_established       := o_Year_Established;
    org_rec.gsa_indicator_flag     := o_Gsa_Indicator_flag;
    org_rec.mission_statement      := o_mission_statement;
    -- org_rec.duns_number            := o_duns_number;
    org_rec.duns_number_c          := o_duns_number_c;
    -- org_rec.tax_name               := NULL;
    org_rec.organization_type      := c_customer_type;
    org_rec.jgzz_fiscal_code       := o_taxpayer_id;
    org_rec.business_scope         := NULL;
    org_rec.corporation_class      := NULL;
    org_rec.organization_name_phonetic  := o_party_name_phonetic;
    org_rec.created_by_module      := 'TCA_FORM_WRAPPER';
    --
    org_rec.party_rec.party_id               := t_party_id;
    org_rec.party_rec.party_number           := t_party_number;
    org_rec.party_rec.validated_flag         := NULL;
    org_rec.party_rec.orig_system_reference  := c_orig_system_reference;
    -- org_rec.party_rec.customer_key           := t_customer_key;
    org_rec.party_rec.attribute_category     := t_Attribute_Category;
    org_rec.party_rec.attribute1             := t_Attribute1;
    org_rec.party_rec.attribute2             := t_Attribute2;
    org_rec.party_rec.attribute3             := t_Attribute3;
    org_rec.party_rec.attribute4             := t_Attribute4;
    org_rec.party_rec.attribute5             := t_Attribute5;
    org_rec.party_rec.attribute6             := t_Attribute6;
    org_rec.party_rec.attribute7             := t_Attribute7;
    org_rec.party_rec.attribute8             := t_attribute8;
    org_rec.party_rec.attribute9             := t_Attribute9;
    org_rec.party_rec.attribute10            := t_Attribute10;
    org_rec.party_rec.attribute11            := t_Attribute11;
    org_rec.party_rec.attribute12            := t_Attribute12;
    org_rec.party_rec.attribute13            := t_Attribute13;
    org_rec.party_rec.attribute14            := t_Attribute14;
    org_rec.party_rec.attribute15            := t_Attribute15;
    org_rec.party_rec.attribute16            := t_Attribute16;
    org_rec.party_rec.attribute17            := t_Attribute17;
    org_rec.party_rec.attribute18            := t_Attribute18;
    org_rec.party_rec.attribute19            := t_Attribute19;
    org_rec.party_rec.attribute20            := t_Attribute20;
    org_rec.party_rec.status                 := null;
    org_rec.party_rec.category_code          := C_Category_Code;
    -- org_rec.party_rec.reference_use_flag     := C_Reference_Use_Flag;
    -- org_rec.party_rec.third_party_flag       := C_Third_Party_Flag;
    -- org_rec.party_rec.competitor_flag        := c_competitor_flag;

    -------------------------------
    -- V2 REC TYPE Customer Profile
    -------------------------------
    prof_rec.cust_account_profile_id       := p_cust_account_profile_id;
    prof_rec.cust_account_id               := p_cust_account_id;
    prof_rec.status                        := p_status;
    prof_rec.collector_id                  := p_collector_id;
    prof_rec.credit_analyst_id             := p_credit_analyst_id;
    prof_rec.credit_checking               := p_credit_checking;
    prof_rec.next_credit_review_date       := p_next_credit_review_date;
    prof_rec.tolerance                     := p_tolerance;
    prof_rec.discount_terms                := p_discount_terms;
    prof_rec.dunning_letters               := p_dunning_letters;
    prof_rec.interest_charges              := p_interest_charges;
    prof_rec.send_statements               := p_send_statements;
    prof_rec.credit_balance_statements     := p_credit_balance_statements;
    prof_rec.credit_hold                   := p_credit_hold;
    prof_rec.profile_class_id              := p_profile_class_id;
    prof_rec.site_use_id                   := NULL;
    prof_rec.credit_rating                 := p_credit_rating;
    prof_rec.risk_code                     := p_risk_code;
    prof_rec.standard_terms                := p_standard_terms;
    prof_rec.override_terms                := p_override_terms;
    prof_rec.dunning_letter_set_id         := p_dunning_letter_set_id;
    prof_rec.interest_period_days          := p_interest_period_days;
    prof_rec.payment_grace_days            := p_payment_grace_days;
    prof_rec.discount_grace_days           := p_discount_grace_days;
    prof_rec.statement_cycle_id            := p_statement_cycle_id;
    prof_rec.account_status                := p_account_status;
    prof_rec.percent_collectable           := p_percent_collectable;
    prof_rec.autocash_hierarchy_id         := p_autocash_hierarchy_id;
    prof_rec.attribute_category            := p_attribute_category;
    prof_rec.attribute1                    := p_attribute1;
    prof_rec.attribute2                    := p_attribute2;
    prof_rec.attribute3                    := p_attribute3;
    prof_rec.attribute4                    := p_attribute4;
    prof_rec.attribute5                    := p_attribute5;
    prof_rec.attribute6                    := p_attribute6;
    prof_rec.attribute7                    := p_attribute7;
    prof_rec.attribute8                    := p_attribute8;
    prof_rec.attribute9                    := p_attribute9;
    prof_rec.attribute10                   := p_attribute10;
    prof_rec.attribute11                   := p_attribute11;
    prof_rec.attribute12                   := p_attribute12;
    prof_rec.attribute13                   := p_attribute13;
    prof_rec.attribute14                   := p_attribute14;
    prof_rec.attribute15                   := p_attribute15;
    prof_rec.auto_rec_incl_disputed_flag   := p_auto_rec_incl_disputed_flag;
    prof_rec.tax_printing_option           := p_tax_printing_option;
    prof_rec.charge_on_finance_charge_flag := p_charge_on_fin_charge_flag;
    prof_rec.grouping_rule_id              := p_grouping_rule_id;
    prof_rec.clearing_days                 := p_clearing_days;
    prof_rec.jgzz_attribute_category       := p_jgzz_attribute_category;
    prof_rec.jgzz_attribute1               := p_jgzz_attribute1;
    prof_rec.jgzz_attribute2               := p_jgzz_attribute2;
    prof_rec.jgzz_attribute3               := p_jgzz_attribute3;
    prof_rec.jgzz_attribute4               := p_jgzz_attribute4;
    prof_rec.jgzz_attribute5               := p_jgzz_attribute5;
    prof_rec.jgzz_attribute6               := p_jgzz_attribute6;
    prof_rec.jgzz_attribute7               := p_jgzz_attribute7;
    prof_rec.jgzz_attribute8               := p_jgzz_attribute8;
    prof_rec.jgzz_attribute9               := p_jgzz_attribute9;
    prof_rec.jgzz_attribute10              := p_jgzz_attribute10;
    prof_rec.jgzz_attribute11              := p_jgzz_attribute11;
    prof_rec.jgzz_attribute12              := p_jgzz_attribute12;
    prof_rec.jgzz_attribute13              := p_jgzz_attribute13;
    prof_rec.jgzz_attribute14              := p_jgzz_attribute14;
    prof_rec.jgzz_attribute15              := p_jgzz_attribute15;
    prof_rec.global_attribute1             := p_global_attribute1;
    prof_rec.global_attribute2             := p_global_attribute2;
    prof_rec.global_attribute3             := p_global_attribute3;
    prof_rec.global_attribute4             := p_global_attribute4;
    prof_rec.global_attribute5             := p_global_attribute5;
    prof_rec.global_attribute6             := p_global_attribute6;
    prof_rec.global_attribute7             := p_global_attribute7;
    prof_rec.global_attribute8             := p_global_attribute8;
    prof_rec.global_attribute9             := p_global_attribute9;
    prof_rec.global_attribute10            := p_global_attribute10;
    prof_rec.global_attribute11            := p_global_attribute11;
    prof_rec.global_attribute12            := p_global_attribute12;
    prof_rec.global_attribute13            := p_global_attribute13;
    prof_rec.global_attribute14            := p_global_attribute14;
    prof_rec.global_attribute15            := p_global_attribute15;
    prof_rec.global_attribute16            := p_global_attribute16;
    prof_rec.global_attribute17            := p_global_attribute17;
    prof_rec.global_attribute18            := p_global_attribute18;
    prof_rec.global_attribute19            := p_global_attribute19;
    prof_rec.global_attribute20            := p_global_attribute20;
    prof_rec.global_attribute_category     := p_global_attribute_category;
    prof_rec.cons_inv_flag                 := p_cons_inv_flag;
    prof_rec.cons_inv_type                 := p_cons_inv_type;
    prof_rec.autocash_hierarchy_id_for_adr := p_autocash_hier_id_for_adr;
    prof_rec.lockbox_matching_option       := p_lockbox_matching_option ;
    prof_rec.created_by_module             := 'TCA_FORM_WRAPPER';
--{2310474
    prof_rec.party_id                      := p_party_id;
    prof_rec.review_cycle                  := p_review_cycle;
    prof_rec.credit_classification         := p_credit_classification;
    prof_rec.last_credit_review_date       := p_last_credit_review_date;
--}

 ---------------------------------------------
 -- Create Customer Account for Oragnization {
 ---------------------------------------------
   HZ_CUST_ACCOUNT_V2PUB.create_cust_account (
            p_cust_account_rec                  => acct_rec,
            p_organization_rec                  => org_rec,
            p_customer_profile_rec              => prof_rec,
            p_create_profile_amt                => FND_API.G_FALSE,
            x_cust_account_id                   => x_customer_id,
            x_account_number                    => x_cust_account_number,
            x_party_id                          => x_party_id,
            x_party_number                      => x_party_number,
            x_profile_id                        => o_organization_profile_id,
            x_return_status                     => x_return_status,
            x_msg_count                         => x_msg_count,
            x_msg_data                          => x_msg_data );


    IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
    END IF;

    c_cust_account_id := x_customer_id;
    c_party_id        := x_party_id;
    t_party_number    := x_party_number;
    c_account_number  := x_cust_account_number;


    /*Bug 3013045*/

    IF l_flag
    THEN
       object_version_select (
                   p_table_name             => 'HZ_ORG_PERS',
                   p_col_id                 => C_Party_Id,
                   x_rowid                  => l_party_rowid,
                   x_object_version_number  => l_party_object_version,
                   x_last_update_date       => l_party_last_update_date,
                   x_id_value               => l_dummy_id,
                   x_return_status          => x_return_status,
                   x_msg_count              => x_msg_count,
                   x_msg_data               => x_msg_data
            );
           IF x_msg_count > 1 THEN
              FOR i IN 1..x_msg_count  LOOP
                 tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                 tmp_var1 := tmp_var1 || ' '|| tmp_var;
              END LOOP;
              x_msg_data := tmp_var1;
           END IF;

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             return;
           END IF;

       org_rec_update.party_rec.category_code       := INIT_SWITCH(C_Category_Code);
       org_rec_update.party_rec.party_id            := INIT_SWITCH(C_Party_Id);
       org_rec_update.organization_name             := INIT_SWITCH(o_party_name);
       org_rec_update.sic_code                      := INIT_SWITCH(o_sic_code);
       org_rec_update.sic_code_type                 := INIT_SWITCH(o_sic_code_type);
       org_rec_update.analysis_fy                   := INIT_SWITCH(o_analysis_fy);
       org_rec_update.fiscal_yearend_month          := INIT_SWITCH(o_fiscal_yearend_month);
       org_rec_update.employees_total               := INIT_SWITCH(o_num_of_employees);
       org_rec_update.curr_fy_potential_revenue     := INIT_SWITCH(o_curr_fy_potential_revenue);
       org_rec_update.next_fy_potential_revenue     := INIT_SWITCH(o_next_fy_potential_revenue);
       org_rec_update.year_established              := INIT_SWITCH(o_year_established);
       org_rec_update.gsa_indicator_flag            := INIT_SWITCH(o_gsa_indicator_flag);
       org_rec_update.jgzz_fiscal_code              := INIT_SWITCH(o_taxpayer_id);
       org_rec_update.mission_statement             := INIT_SWITCH(o_mission_statement);
       org_rec_update.organization_name_phonetic    := INIT_SWITCH(o_party_name_phonetic);
       org_rec_update.duns_number_c                 := INIT_SWITCH(o_duns_number_c);
       org_rec_update.tax_reference                 := INIT_SWITCH(o_tax_reference);
       org_rec_update.content_source_type           := NVL(org_rec_update.content_source_type,'USER_ENTERED');

       HZ_PARTY_V2PUB.update_organization (
          p_organization_rec                  => org_rec_update,
          p_party_object_version_number       => l_party_object_version,
          x_profile_id                        => o_organization_profile_id,
          x_return_status                     => x_return_status,
          x_msg_count                         => x_msg_count,
          x_msg_data                          => x_msg_data
       );

       IF x_msg_count > 1 THEN
         FOR i IN 1..x_msg_count  LOOP
           tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
           tmp_var1 := tmp_var1 || ' '|| tmp_var;
         END LOOP;
         x_msg_data := tmp_var1;
       END IF;

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          return;
       END IF;

  END IF;

  /*End bugfix 3013045*/






  -------------------
  --  Internal Party
  -------------------
  i_internal_party_id := fnd_profile.value('HZ_INTERNAL_PARTY');

  IF i_internal_party_id IS NOT NULL THEN
    Ref_Part_Comp
      ( c_party_id           => c_party_id,
        c_party_type         => 'ORGANIZATION',
        i_internal_party_id  => i_internal_party_id,
        C_Reference_Use_Flag => C_Reference_Use_Flag,
        C_Third_Party_Flag   => C_Third_Party_Flag,
        C_competitor_flag    => C_competitor_flag,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data ,
        x_end_date           => SYSDATE);


    IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
    END IF;

  END IF;

END insert_row;


PROCEDURE insert_person_row(
                       c_cust_account_id                IN OUT NOCOPY NUMBER ,
                       c_party_id                       IN OUT NOCOPY NUMBER,
                       c_account_number                 IN OUT NOCOPY VARCHAR2,
                       c_Attribute_Category             IN VARCHAR2,
                       c_Attribute1                     IN VARCHAR2,
                       c_Attribute2                     IN VARCHAR2,
                       c_Attribute3                     IN VARCHAR2,
                       c_Attribute4                     IN VARCHAR2,
                       c_Attribute5                     IN VARCHAR2,
                       c_Attribute6                     IN VARCHAR2,
                       c_Attribute7                     IN VARCHAR2,
                       c_Attribute8                     IN VARCHAR2,
                       c_Attribute9                     IN VARCHAR2,
                       c_Attribute10                    IN VARCHAR2,
                       c_Attribute11                    IN VARCHAR2,
                       c_Attribute12                    IN VARCHAR2,
                       c_Attribute13                    IN VARCHAR2,
                       c_Attribute14                    IN VARCHAR2,
                       c_Attribute15                    IN VARCHAR2,
                       c_Attribute16                    IN VARCHAR2,
                       c_Attribute17                    IN VARCHAR2,
                       c_Attribute18                    IN VARCHAR2,
                       c_Attribute19                    IN VARCHAR2,
                       c_Attribute20                    IN VARCHAR2,
                       c_global_attribute_category      IN VARCHAR2,
                       c_global_attribute1              IN VARCHAR2,
                       c_global_attribute2              IN VARCHAR2,
                       c_global_attribute3              IN VARCHAR2,
                       c_global_attribute4              IN VARCHAR2,
                       c_global_attribute5              IN VARCHAR2,
                       c_global_attribute6              IN VARCHAR2,
                       c_global_attribute7              IN VARCHAR2,
                       c_global_attribute8              IN VARCHAR2,
                       c_global_attribute9              IN VARCHAR2,
                       c_global_attribute10             IN VARCHAR2,
                       c_global_attribute11             IN VARCHAR2,
                       c_global_attribute12             IN VARCHAR2,
                       c_global_attribute13             IN VARCHAR2,
                       c_global_attribute14             IN VARCHAR2,
                       c_global_attribute15             IN VARCHAR2,
                       c_global_attribute16             IN VARCHAR2,
                       c_global_attribute17             IN VARCHAR2,
                       c_global_attribute18             IN VARCHAR2,
                       c_global_attribute19             IN VARCHAR2,
                       c_global_attribute20             IN VARCHAR2,
                       c_orig_system_reference          IN VARCHAR2,
                       c_status                         IN VARCHAR2,
                       c_customer_type                  IN VARCHAR2,
                       c_customer_class_code            IN VARCHAR2,
                       c_primary_salesrep_id            IN NUMBER ,
                       c_sales_channel_code             IN VARCHAR2,
                       c_order_type_id                  IN NUMBER,
                       c_price_list_id                  IN NUMBER ,
                       c_category_code                  IN VARCHAR2,
                       c_reference_use_flag             IN VARCHAR2,
                       c_tax_code                       IN VARCHAR2,
                       c_third_party_flag               IN VARCHAR2,
                       c_competitor_flag                IN VARCHAR2,
                       c_fob_point                      IN VARCHAR2,
                       c_tax_header_level_flag          IN VARCHAR2,
                       c_tax_rounding_rule              IN VARCHAR2,
                       c_account_name                   IN VARCHAR2,
                       c_freight_term                   IN VARCHAR2,
                       c_ship_partial                   IN VARCHAR2,
                       c_ship_via                       IN VARCHAR2,
                       c_warehouse_id                   IN NUMBER,
                       c_payment_term_id                IN NUMBER ,
                       c_DATES_NEGATIVE_TOLERANCE       IN NUMBER,
                       c_DATES_POSITIVE_TOLERANCE       IN NUMBER,
                       c_DATE_TYPE_PREFERENCE           IN VARCHAR2,
                       c_OVER_SHIPMENT_TOLERANCE        IN NUMBER,
                       c_UNDER_SHIPMENT_TOLERANCE       IN NUMBER,
                       c_ITEM_CROSS_REF_PREF            IN VARCHAR2,
                       c_OVER_RETURN_TOLERANCE          IN NUMBER,
                       c_UNDER_RETURN_TOLERANCE         IN NUMBER,
                       c_SHIP_SETS_INCLUDE_LINES_FLAG   IN VARCHAR2,
                       c_ARRIVALSETS_INCL_LINES_FLAG    IN VARCHAR2,
                       c_SCHED_DATE_PUSH_FLAG           IN VARCHAR2,
                       c_INVOICE_QUANTITY_RULE          IN VARCHAR2,
                       t_party_id                       IN NUMBER ,
                       t_party_number               IN OUT NOCOPY VARCHAR2,
                       t_customer_key                   IN VARCHAR2,
                       t_Attribute_Category             IN VARCHAR2,
                       t_Attribute1                     IN VARCHAR2,
                       t_Attribute2                     IN VARCHAR2,
                       t_Attribute3                     IN VARCHAR2,
                       t_Attribute4                     IN VARCHAR2,
                       t_Attribute5                     IN VARCHAR2,
                       t_Attribute6                     IN VARCHAR2,
                       t_Attribute7                     IN VARCHAR2,
                       t_Attribute8                     IN VARCHAR2,
                       t_Attribute9                     IN VARCHAR2,
                       t_Attribute10                    IN VARCHAR2,
                       t_Attribute11                    IN VARCHAR2,
                       t_Attribute12                    IN VARCHAR2,
                       t_Attribute13                    IN VARCHAR2,
                       t_Attribute14                    IN VARCHAR2,
                       t_Attribute15                    IN VARCHAR2,
                       t_Attribute16                    IN VARCHAR2,
                       t_Attribute17                    IN VARCHAR2,
                       t_Attribute18                    IN VARCHAR2,
                       t_Attribute19                    IN VARCHAR2,
                       t_Attribute20                    IN VARCHAR2,
                       t_global_attribute_category      IN VARCHAR2,
                       t_global_attribute1              IN VARCHAR2,
                       t_global_attribute2              IN VARCHAR2,
                       t_global_attribute3              IN VARCHAR2,
                       t_global_attribute4              IN VARCHAR2,
                       t_global_attribute5              IN VARCHAR2,
                       t_global_attribute6              IN VARCHAR2,
                       t_global_attribute7              IN VARCHAR2,
                       t_global_attribute8              IN VARCHAR2,
                       t_global_attribute9              IN VARCHAR2,
                       t_global_attribute10             IN VARCHAR2,
                       t_global_attribute11             IN VARCHAR2,
                       t_global_attribute12             IN VARCHAR2,
                       t_global_attribute13             IN VARCHAR2,
                       t_global_attribute14             IN VARCHAR2,
                       t_global_attribute15             IN VARCHAR2,
                       t_global_attribute16             IN VARCHAR2,
                       t_global_attribute17             IN VARCHAR2,
                       t_global_attribute18             IN VARCHAR2,
                       t_global_attribute19             IN VARCHAR2,
                       t_global_attribute20             IN VARCHAR2,
                       o_pre_name_adjunct               IN VARCHAR2,
                       o_first_name                     IN VARCHAR2,
                       o_middle_name                    IN VARCHAR2,
                       o_last_name                      IN VARCHAR2,
                       o_name_suffix                    IN VARCHAR2,
                       o_tax_reference                  IN VARCHAR2,
                       o_taxpayer_id                    IN VARCHAR2,
                       o_party_name_phonetic            IN VARCHAR2,
                       p_cust_account_profile_id        IN NUMBER ,
                       p_cust_account_id                IN NUMBER ,
                       p_status                         IN VARCHAR2,
                       p_collector_id                   IN NUMBER ,
                       p_credit_analyst_id              IN NUMBER ,
                       p_credit_checking                IN VARCHAR2,
                       p_next_credit_review_date           DATE ,
                       p_tolerance                      IN NUMBER,
                       p_discount_terms                 IN VARCHAR2,
                       p_dunning_letters                IN VARCHAR2,
                       p_interest_charges               IN VARCHAR2,
                       p_send_statements                IN VARCHAR2,
                       p_credit_balance_statements      IN VARCHAR2,
                       p_credit_hold                    IN VARCHAR2,
                       p_profile_class_id               IN NUMBER ,
                       p_site_use_id                    IN NUMBER ,
                       p_credit_rating                  IN VARCHAR2,
                       p_risk_code                      IN VARCHAR2,
                       p_standard_terms                 IN NUMBER ,
                       p_override_terms                 IN VARCHAR2,
                       p_dunning_letter_set_id          IN NUMBER,
                       p_interest_period_days           IN NUMBER,
                       p_payment_grace_days             IN NUMBER,
                       p_discount_grace_days            IN NUMBER,
                       p_statement_cycle_id             IN NUMBER ,
                       p_account_status                 IN VARCHAR2,
                       p_percent_collectable            IN NUMBER ,
                       p_autocash_hierarchy_id          IN NUMBER,
                       p_Attribute_Category             IN VARCHAR2,
                       p_Attribute1                     IN VARCHAR2,
                       p_Attribute2                     IN VARCHAR2,
                       p_Attribute3                     IN VARCHAR2,
                       p_Attribute4                     IN VARCHAR2,
                       p_Attribute5                     IN VARCHAR2,
                       p_Attribute6                     IN VARCHAR2,
                       p_Attribute7                     IN VARCHAR2,
                       p_Attribute8                     IN VARCHAR2,
                       p_Attribute9                     IN VARCHAR2,
                       p_Attribute10                    IN VARCHAR2,
                       p_Attribute11                    IN VARCHAR2,
                       p_Attribute12                    IN VARCHAR2,
                       p_Attribute13                    IN VARCHAR2,
                       p_Attribute14                    IN VARCHAR2,
                       p_Attribute15                    IN VARCHAR2,
                       p_auto_rec_incl_disputed_flag    IN VARCHAR2,
                       p_tax_printing_option            IN VARCHAR2,
                       p_charge_on_fin_charge_flag      IN VARCHAR2,
                       p_grouping_rule_id               IN NUMBER ,
                       p_clearing_days                  IN NUMBER,
                       p_jgzz_attribute_category        IN VARCHAR2,
                       p_jgzz_attribute1                IN VARCHAR2,
                       p_jgzz_attribute2                IN VARCHAR2,
                       p_jgzz_attribute3                IN VARCHAR2,
                       p_jgzz_attribute4                IN VARCHAR2,
                       p_jgzz_attribute5                IN VARCHAR2,
                       p_jgzz_attribute6                IN VARCHAR2,
                       p_jgzz_attribute7                IN VARCHAR2,
                       p_jgzz_attribute8                IN VARCHAR2,
                       p_jgzz_attribute9                IN VARCHAR2,
                       p_jgzz_attribute10               IN VARCHAR2,
                       p_jgzz_attribute11               IN VARCHAR2,
                       p_jgzz_attribute12               IN VARCHAR2,
                       p_jgzz_attribute13               IN VARCHAR2,
                       p_jgzz_attribute14               IN VARCHAR2,
                       p_jgzz_attribute15               IN VARCHAR2,
                       p_global_attribute_category      IN VARCHAR2,
                       p_global_attribute1              IN VARCHAR2,
                       p_global_attribute2              IN VARCHAR2,
                       p_global_attribute3              IN VARCHAR2,
                       p_global_attribute4              IN VARCHAR2,
                       p_global_attribute5              IN VARCHAR2,
                       p_global_attribute6              IN VARCHAR2,
                       p_global_attribute7              IN VARCHAR2,
                       p_global_attribute8              IN VARCHAR2,
                       p_global_attribute9              IN VARCHAR2,
                       p_global_attribute10             IN VARCHAR2,
                       p_global_attribute11             IN VARCHAR2,
                       p_global_attribute12             IN VARCHAR2,
                       p_global_attribute13             IN VARCHAR2,
                       p_global_attribute14             IN VARCHAR2,
                       p_global_attribute15             IN VARCHAR2,
                       p_global_attribute16             IN VARCHAR2,
                       p_global_attribute17             IN VARCHAR2,
                       p_global_attribute18             IN VARCHAR2,
                       p_global_attribute19             IN VARCHAR2,
                       p_global_attribute20             IN VARCHAR2,
                       p_cons_inv_flag                  IN VARCHAR2,
                       p_cons_inv_type                  IN VARCHAR2,
                       p_autocash_hier_id_for_adr       IN NUMBER ,
                       p_lockbox_matching_option        IN VARCHAR2,
--{2310474
                       p_party_id                       IN NUMBER    DEFAULT NULL,
                       p_review_cycle                   IN VARCHAR2  DEFAULT NULL,
                       p_credit_classification          IN VARCHAR2  DEFAULT NULL,
                       p_last_credit_review_date        IN DATE      DEFAULT NULL,
-- }
                       o_person_profile_id              IN OUT NOCOPY number,
                       x_msg_count                      OUT NOCOPY NUMBER,
                       x_msg_data                       OUT NOCOPY varchar2,
                       x_return_status                  OUT NOCOPY VARCHAR2)
 IS

--  acct_rec        hz_customer_accounts_pub.account_rec_type;
--  party_rec       hz_party_pub.party_rec_type;
--  person_rec      hz_party_pub.person_rec_type;
--  prel_rec        hz_party_pub.party_rel_rec_type;
--  prof_rec        hz_customer_accounts_pub.cust_profile_rec_type;


  acct_rec   hz_cust_account_v2pub.cust_account_rec_type;
  party_rec  hz_party_v2pub.party_rec_type;
  person_rec hz_party_v2pub.person_rec_type;
  prel_rec   hz_relationship_v2pub.relationship_rec_type;
  prof_rec   hz_customer_profile_v2pub.customer_profile_rec_type;

  /*Bug 3013045 */
  person_rec_update hz_party_v2pub.person_rec_type;

  tmp_var                    VARCHAR2(2000);
  i                          NUMBER;
  tmp_var1                   VARCHAR2(2000);
  x_customer_id              NUMBER;
  x_cust_account_number      VARCHAR2(100);
  x_party_id                 NUMBER;
  x_party_number             VARCHAR2(100);
  i_internal_party_id        NUMBER;
  i_pr_party_relationship_id NUMBER;
  i_pr_party_id              NUMBER;
  i_pr_party_number          VARCHAR2(100);
-- create_internal_party      VARCHAR2(1) := 'Y';
  x_party_rel_id             NUMBER;
  l_party_rel_object_version NUMBER;
  l_party_object_version     NUMBER;

  x_party_last_update_date     date;
  X_PARTY_REL_LAST_UPDATE_DATE date;

  /*Bug 3013045*/
  l_flag BOOLEAN;
  l_party_rowid                 ROWID;
  l_party_last_update_date      DATE;
  l_dummy_id                    NUMBER;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

 /*Bug  3013045*/

 IF c_party_id is not null
 THEN
    l_flag := TRUE;
 END IF;

   acct_rec.cust_account_id        := C_Cust_account_Id;
--  acct_rec.party_id               := C_Party_Id;
   acct_rec.account_number         := C_account_Number;
   acct_rec.attribute_category     := C_Attribute_Category;
   acct_rec.attribute1             := C_Attribute1;
   acct_rec.attribute2             := C_Attribute2;
   acct_rec.attribute3             := C_Attribute3;
   acct_rec.attribute4             := C_Attribute4;
   acct_rec.attribute5             := C_Attribute5;
   acct_rec.attribute6             := C_Attribute6;
   acct_rec.attribute7             := C_Attribute7;
   acct_rec.attribute8             := C_Attribute8;
   acct_rec.attribute9             := C_Attribute9;
   acct_rec.attribute10            := C_Attribute10;
   acct_rec.attribute11            := C_Attribute11;
   acct_rec.attribute12            := C_Attribute12;
   acct_rec.attribute13            := C_Attribute13;
   acct_rec.attribute14            := C_Attribute14;
   acct_rec.attribute15            := C_Attribute15;
   acct_rec.attribute16            := C_Attribute16;
   acct_rec.attribute17            := C_Attribute17;
   acct_rec.attribute18            := C_Attribute18;
   acct_rec.attribute19            := C_Attribute19;
   acct_rec.attribute20            := C_Attribute20;
   acct_rec.global_attribute_category := C_Global_Attribute_Category;
   acct_rec.global_attribute1      := C_Global_Attribute1;
   acct_rec.global_attribute2      := C_Global_Attribute2;
   acct_rec.global_attribute3      := C_Global_Attribute3;
   acct_rec.global_attribute4      := C_Global_Attribute4;
   acct_rec.global_attribute5      := C_Global_Attribute5;
   acct_rec.global_attribute6      := C_Global_Attribute6;
   acct_rec.global_attribute7      := C_Global_Attribute7;
   acct_rec.global_attribute8      := C_Global_Attribute8;
   acct_rec.global_attribute9      := C_Global_Attribute9;
   acct_rec.global_attribute10     := C_Global_Attribute10;
   acct_rec.global_attribute11     := C_Global_Attribute11;
   acct_rec.global_attribute12     := C_Global_Attribute12;
   acct_rec.global_attribute13     := C_Global_Attribute13;
   acct_rec.global_attribute14     := C_Global_Attribute14;
   acct_rec.global_attribute15     := C_Global_Attribute15;
   acct_rec.global_attribute16     := C_Global_Attribute16;
   acct_rec.global_attribute17     := C_Global_Attribute17;
   acct_rec.global_attribute18     := C_Global_Attribute18;
   acct_rec.global_attribute19     := C_Global_Attribute19;
   acct_rec.global_attribute20     := C_Global_Attribute20;
   acct_rec.orig_system_reference  := C_Orig_System_Reference;
   acct_rec.status                 := C_Status;
   acct_rec.customer_type          := c_customer_type;
   acct_rec.customer_class_code    := C_Customer_Class_Code;
   acct_rec.primary_salesrep_id    := C_Primary_Salesrep_Id;
   acct_rec.sales_channel_code     := C_Sales_Channel_Code;
   acct_rec.order_type_id          := C_Order_Type_Id;
   acct_rec.price_list_id          := C_Price_List_Id;
 -- acct_rec.category_code          := C_Category_Code;
 -- acct_rec.reference_use_flag     := C_Reference_Use_Flag;
   acct_rec.tax_code               := C_Tax_Code;
 -- acct_rec.third_party_flag       := C_Third_Party_Flag;
 -- acct_rec.competitor_flag        := c_competitor_flag;
   acct_rec.fob_point              := C_Fob_Point;
   acct_rec.tax_header_level_flag  := C_Tax_Header_Level_Flag;
   acct_rec.tax_rounding_rule      := C_Tax_Rounding_Rule;
   acct_rec.primary_specialist_id  := NULL;
   acct_rec.secondary_specialist_id := NULL;
--   acct_rec.geo_code                := NULL;
   acct_rec.account_name            := c_account_name;
   acct_rec.freight_term            := C_Freight_Term;
   acct_rec.ship_partial            := C_Ship_Partial;
   acct_rec.ship_via                := C_Ship_Via;
   acct_rec.warehouse_id            := C_Warehouse_Id;
--   acct_rec.payment_term_id         := NULL;
   acct_rec.account_liable_flag     := null;
   acct_rec.DATES_NEGATIVE_TOLERANCE   := c_DATES_NEGATIVE_TOLERANCE;
   acct_rec.DATES_POSITIVE_TOLERANCE   := c_DATES_POSITIVE_TOLERANCE;
   acct_rec.DATE_TYPE_PREFERENCE       := c_DATE_TYPE_PREFERENCE;
   acct_rec.OVER_SHIPMENT_TOLERANCE    := c_OVER_SHIPMENT_TOLERANCE;
   acct_rec.UNDER_SHIPMENT_TOLERANCE   := c_UNDER_SHIPMENT_TOLERANCE;
   acct_rec.ITEM_CROSS_REF_PREF        := c_ITEM_CROSS_REF_PREF;
   acct_rec.SHIP_SETS_INCLUDE_LINES_FLAG := c_SHIP_SETS_INCLUDE_LINES_FLAG;
   acct_rec.ARRIVALSETS_INCLUDE_LINES_FLAG := c_ARRIVALSETS_INCL_LINES_FLAG;
   acct_rec.SCHED_DATE_PUSH_FLAG        := c_SCHED_DATE_PUSH_FLAG;
   acct_rec.INVOICE_QUANTITY_RULE       := c_INVOICE_QUANTITY_RULE;
   acct_rec.OVER_RETURN_TOLERANCE       := c_OVER_RETURN_TOLERANCE;
   acct_rec.UNDER_RETURN_TOLERANCE      := c_UNDER_RETURN_TOLERANCE;
   acct_rec.created_by_module           := 'TCA_FORM_WRAPPER';

   person_rec.party_rec.party_id               := c_party_id;
   person_rec.person_pre_name_adjunct                 := o_pre_name_adjunct;
   person_rec.person_first_name                       := o_first_name;
   person_rec.person_middle_name                      := o_middle_name;
   person_rec.person_last_name                        := o_last_name;
   person_rec.person_name_suffix                      := o_name_suffix;
   person_rec.jgzz_fiscal_code                 := o_taxpayer_id;
   person_rec.person_name_phonetic             := o_party_name_phonetic;
   person_rec.tax_reference                    := o_tax_reference;
   person_rec.party_rec.party_id               := t_party_id;
   person_rec.party_rec.party_number           := t_party_number;
   person_rec.party_rec.validated_flag         := NULL;
   person_rec.party_rec.orig_system_reference  := c_orig_system_reference;
--   person_rec.party_rec.customer_key           := t_customer_key;
   person_rec.party_rec.attribute_category     := t_Attribute_Category;
   person_rec.party_rec.attribute1             := t_Attribute1;
   person_rec.party_rec.attribute2             := t_Attribute2;
   person_rec.party_rec.attribute3             := t_Attribute3;
   person_rec.party_rec.attribute4             := t_Attribute4;
   person_rec.party_rec.attribute5             := t_Attribute5;
   person_rec.party_rec.attribute6             := t_Attribute6;
   person_rec.party_rec.attribute7             := t_Attribute7;
   person_rec.party_rec.attribute8             := t_attribute8;
   person_rec.party_rec.attribute9             := t_Attribute9;
   person_rec.party_rec.attribute10            := t_Attribute10;
   person_rec.party_rec.attribute11            := t_Attribute11;
   person_rec.party_rec.attribute12            := t_Attribute12;
   person_rec.party_rec.attribute13            := t_Attribute13;
   person_rec.party_rec.attribute14            := t_Attribute14;
   person_rec.party_rec.attribute15            := t_Attribute15;
   person_rec.party_rec.attribute16            := t_Attribute16;
   person_rec.party_rec.attribute17            := t_Attribute17;
   person_rec.party_rec.attribute18            := t_Attribute18;
   person_rec.party_rec.attribute19            := t_Attribute19;
   person_rec.party_rec.attribute20            := t_Attribute20;
   person_rec.party_rec.status                 := null;
   person_rec.party_rec.category_code          := C_Category_Code;

-- person_rec.party_rec.reference_use_flag     := C_Reference_Use_Flag;
-- person_rec.party_rec.third_party_flag       := C_Third_Party_Flag;
-- person_rec.party_rec.competitor_flag        := c_competitor_flag;
-- person_rec.party_rec.party_id     := c_party_id;
-- person_rec.pre_name_adjunct := o_pre_name_adjunct;
-- person_rec.first_name       := o_first_name;
-- person_rec.middle_name      := o_middle_name;
-- person_rec.last_name        := o_last_name;
-- person_rec.name_suffix      := o_name_suffix;
-- person_rec.jgzz_fiscal_code := o_taxpayer_id;
-- person_rec.person_name_phonetic     := o_party_name_phonetic;

   prof_rec.cust_account_profile_id       := p_cust_account_profile_id;
   prof_rec.cust_account_id               := p_cust_account_id;
   prof_rec.status                        := p_status;
   prof_rec.collector_id                  := p_collector_id;
   prof_rec.credit_analyst_id             := p_credit_analyst_id;
   prof_rec.credit_checking               := p_credit_checking;
   prof_rec.next_credit_review_date       := p_next_credit_review_date;
   prof_rec.tolerance                     := p_tolerance;
   prof_rec.discount_terms                := p_discount_terms;
   prof_rec.dunning_letters               := p_dunning_letters;
   prof_rec.interest_charges              := p_interest_charges;
   prof_rec.send_statements               := p_send_statements;
   prof_rec.credit_balance_statements     := p_credit_balance_statements;
   prof_rec.credit_hold                   := p_credit_hold;
   prof_rec.profile_class_id              := p_profile_class_id;
   prof_rec.site_use_id                   := NULL;
   prof_rec.credit_rating                 := p_credit_rating;
   prof_rec.risk_code                     := p_risk_code;
   prof_rec.standard_terms                := p_standard_terms;
   prof_rec.override_terms                := p_override_terms;
   prof_rec.dunning_letter_set_id         := p_dunning_letter_set_id;
   prof_rec.interest_period_days          := p_interest_period_days;
   prof_rec.payment_grace_days            := p_payment_grace_days;
   prof_rec.discount_grace_days           := p_discount_grace_days;
   prof_rec.statement_cycle_id            := p_statement_cycle_id;
   prof_rec.account_status                := p_account_status;
   prof_rec.percent_collectable           := p_percent_collectable;
   prof_rec.autocash_hierarchy_id         := p_autocash_hierarchy_id;
   prof_rec.attribute_category            := p_attribute_category;
   prof_rec.attribute1                    := p_attribute1;
   prof_rec.attribute2                    := p_attribute2;
   prof_rec.attribute3                    := p_attribute3;
   prof_rec.attribute4                    := p_attribute4;
   prof_rec.attribute5                    := p_attribute5;
   prof_rec.attribute6                    := p_attribute6;
   prof_rec.attribute7                    := p_attribute7;
   prof_rec.attribute8                    := p_attribute8;
   prof_rec.attribute9                    := p_attribute9;
   prof_rec.attribute10                   := p_attribute10;
   prof_rec.attribute11                   := p_attribute11;
   prof_rec.attribute12                   := p_attribute12;
   prof_rec.attribute13                   := p_attribute13;
   prof_rec.attribute14                   := p_attribute14;
   prof_rec.attribute15                   := p_attribute15;
   prof_rec.auto_rec_incl_disputed_flag   := p_auto_rec_incl_disputed_flag;
   prof_rec.tax_printing_option           := p_tax_printing_option;
   prof_rec.charge_on_finance_charge_flag := p_charge_on_fin_charge_flag;
   prof_rec.grouping_rule_id              := p_grouping_rule_id;
   prof_rec.clearing_days                 := p_clearing_days;
   prof_rec.jgzz_attribute_category       := p_jgzz_attribute_category;
   prof_rec.jgzz_attribute1               := p_jgzz_attribute1;
   prof_rec.jgzz_attribute2               := p_jgzz_attribute2;
   prof_rec.jgzz_attribute3               := p_jgzz_attribute3;
   prof_rec.jgzz_attribute4               := p_jgzz_attribute4;
   prof_rec.jgzz_attribute5               := p_jgzz_attribute5;
   prof_rec.jgzz_attribute6               := p_jgzz_attribute6;
   prof_rec.jgzz_attribute7               := p_jgzz_attribute7;
   prof_rec.jgzz_attribute8               := p_jgzz_attribute8;
   prof_rec.jgzz_attribute9               := p_jgzz_attribute9;
   prof_rec.jgzz_attribute10              := p_jgzz_attribute10;
   prof_rec.jgzz_attribute11              := p_jgzz_attribute11;
   prof_rec.jgzz_attribute12              := p_jgzz_attribute12;
   prof_rec.jgzz_attribute13              := p_jgzz_attribute13;
   prof_rec.jgzz_attribute14              := p_jgzz_attribute14;
   prof_rec.jgzz_attribute15              := p_jgzz_attribute15;
   prof_rec.global_attribute1             := p_global_attribute1;
   prof_rec.global_attribute2             := p_global_attribute2;
   prof_rec.global_attribute3             := p_global_attribute3;
   prof_rec.global_attribute4             := p_global_attribute4;
   prof_rec.global_attribute5             := p_global_attribute5;
   prof_rec.global_attribute6             := p_global_attribute6;
   prof_rec.global_attribute7             := p_global_attribute7;
   prof_rec.global_attribute8             := p_global_attribute8;
   prof_rec.global_attribute9             := p_global_attribute9;
   prof_rec.global_attribute10            := p_global_attribute10;
   prof_rec.global_attribute11            := p_global_attribute11;
   prof_rec.global_attribute12            := p_global_attribute12;
   prof_rec.global_attribute13            := p_global_attribute13;
   prof_rec.global_attribute14            := p_global_attribute14;
   prof_rec.global_attribute15            := p_global_attribute15;
   prof_rec.global_attribute16            := p_global_attribute16;
   prof_rec.global_attribute17            := p_global_attribute17;
   prof_rec.global_attribute18            := p_global_attribute18;
   prof_rec.global_attribute19            := p_global_attribute19;
   prof_rec.global_attribute20            := p_global_attribute20;
   prof_rec.global_attribute_category     := p_global_attribute_category;
   prof_rec.cons_inv_flag                 := p_cons_inv_flag;
   prof_rec.cons_inv_type                 := p_cons_inv_type;
   prof_rec.autocash_hierarchy_id_for_adr := p_autocash_hier_id_for_adr;
   prof_rec.lockbox_matching_option       := p_lockbox_matching_option ;
   prof_rec.created_by_module             := 'TCA_FORM_WRAPPER';
--{2310474
    prof_rec.party_id                      := p_party_id;
    prof_rec.review_cycle                  := p_review_cycle;
    prof_rec.credit_classification         := p_credit_classification;
    prof_rec.last_credit_review_date       := p_last_credit_review_date;
--}

  ----------------------------------
  -- {Create Person Customer Account
  ----------------------------------
   HZ_CUST_ACCOUNT_V2PUB.create_cust_account (
            p_cust_account_rec                  => acct_rec,
            p_person_rec                        => person_rec,
            p_customer_profile_rec              => prof_rec,
            p_create_profile_amt                => FND_API.G_FALSE,
            x_cust_account_id                   => x_customer_id,
            x_account_number                    => x_cust_account_number,
            x_party_id                          => x_party_id,
            x_party_number                      => x_party_number,
            x_profile_id                        => o_person_profile_id,
            x_return_status                     => x_return_status,
            x_msg_count                         => x_msg_count,
            x_msg_data                          => x_msg_data       );

    IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
    END IF;

    c_cust_account_id := x_customer_id;
    c_party_id        := x_party_id;
    t_party_number    := x_party_number;
    c_account_number  := x_cust_account_number;


    /*Bug 3013045*/
    IF l_flag
    THEN

         object_version_select (
                   p_table_name             => 'HZ_ORG_PERS',
                   p_col_id                 => C_Party_Id,
                   x_rowid                  => l_party_rowid,
                   x_object_version_number  => l_party_object_version,
                   x_last_update_date       => l_party_last_update_date,
                   x_id_value               => l_dummy_id,
                   x_return_status          => x_return_status,
                   x_msg_count              => x_msg_count,
                   x_msg_data               => x_msg_data
                   );
         IF x_msg_count > 1 THEN
            FOR i IN 1..x_msg_count  LOOP
                  tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                  tmp_var1 := tmp_var1 || ' '|| tmp_var;
            END LOOP;
            x_msg_data := tmp_var1;
          END IF;

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             return;
          END IF;
          person_rec_update.party_rec.party_id         := INIT_SWITCH(C_Party_Id);
          person_rec_update.party_rec.category_code    := INIT_SWITCH(C_Category_Code);
          person_rec_update.person_name_phonetic       := INIT_SWITCH(o_party_name_phonetic);
          person_rec_update.person_pre_name_adjunct    := INIT_SWITCH(o_pre_name_adjunct);
          person_rec_update.person_first_name          := INIT_SWITCH(o_first_name);
          person_rec_update.person_middle_name         := INIT_SWITCH(o_middle_name);
          person_rec_update.person_last_name           := INIT_SWITCH(o_last_name);
          person_rec_update.person_name_suffix         := INIT_SWITCH(o_name_suffix);
          person_rec_update.tax_reference              := INIT_SWITCH(o_tax_reference);
          person_rec_update.jgzz_fiscal_code           := INIT_SWITCH(o_taxpayer_id);
          person_rec_update.content_source_type        := NVL(person_rec_update.content_source_type,'USER_ENTERED');

          HZ_PARTY_V2PUB.update_person (
           p_person_rec                        => person_rec_update,
           p_party_object_version_number       => l_party_object_version,
           x_profile_id                        => o_person_profile_id,
           x_return_status                     => x_return_status,
           x_msg_count                         => x_msg_count,
           x_msg_data                          => x_msg_data
           );
           IF x_msg_count > 1 THEN
             FOR i IN 1..x_msg_count  LOOP
                tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                tmp_var1 := tmp_var1 || ' '|| tmp_var;
             END LOOP;
             x_msg_data := tmp_var1;
           END IF;

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            return;
          END IF;
    END IF;

    /*End bug fix 3013045*/


  -------------------
  --  Internal Party
  -------------------
  i_internal_party_id := fnd_profile.value('HZ_INTERNAL_PARTY');

  IF i_internal_party_id IS NOT NULL THEN
    Ref_Part_Comp
      ( c_party_id           => c_party_id,
        c_party_type         => 'PERSON',
        i_internal_party_id  => i_internal_party_id,
        C_Reference_Use_Flag => C_Reference_Use_Flag,
        C_Third_Party_Flag   => C_Third_Party_Flag,
        C_competitor_flag    => C_competitor_flag,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data ,
        x_end_date           => SYSDATE);

    IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
    END IF;

  END IF;

 END insert_person_row;


 PROCEDURE update_row(
                       c_cust_account_id                IN OUT NOCOPY NUMBER ,
                       c_party_id                       IN NUMBER,
                       c_account_number                 IN VARCHAR2,
                       c_Attribute_Category             IN VARCHAR2,
                       c_Attribute1                     IN VARCHAR2,
                       c_Attribute2                     IN VARCHAR2,
                       c_Attribute3                     IN VARCHAR2,
                       c_Attribute4                     IN VARCHAR2,
                       c_Attribute5                     IN VARCHAR2,
                       c_Attribute6                     IN VARCHAR2,
                       c_Attribute7                     IN VARCHAR2,
                       c_Attribute8                     IN VARCHAR2,
                       c_Attribute9                     IN VARCHAR2,
                       c_Attribute10                    IN VARCHAR2,
                       c_Attribute11                    IN VARCHAR2,
                       c_Attribute12                    IN VARCHAR2,
                       c_Attribute13                    IN VARCHAR2,
                       c_Attribute14                    IN VARCHAR2,
                       c_Attribute15                    IN VARCHAR2,
                       c_Attribute16                    IN VARCHAR2,
                       c_Attribute17                    IN VARCHAR2,
                       c_Attribute18                    IN VARCHAR2,
                       c_Attribute19                    IN VARCHAR2,
                       c_Attribute20                    IN VARCHAR2,
                       c_global_attribute_category      IN VARCHAR2,
                       c_global_attribute1              IN VARCHAR2,
                       c_global_attribute2              IN VARCHAR2,
                       c_global_attribute3              IN VARCHAR2,
                       c_global_attribute4              IN VARCHAR2,
                       c_global_attribute5              IN VARCHAR2,
                       c_global_attribute6              IN VARCHAR2,
                       c_global_attribute7              IN VARCHAR2,
                       c_global_attribute8              IN VARCHAR2,
                       c_global_attribute9              IN VARCHAR2,
                       c_global_attribute10             IN VARCHAR2,
                       c_global_attribute11             IN VARCHAR2,
                       c_global_attribute12             IN VARCHAR2,
                       c_global_attribute13             IN VARCHAR2,
                       c_global_attribute14             IN VARCHAR2,
                       c_global_attribute15             IN VARCHAR2,
                       c_global_attribute16             IN VARCHAR2,
                       c_global_attribute17             IN VARCHAR2,
                       c_global_attribute18             IN VARCHAR2,
                       c_global_attribute19             IN VARCHAR2,
                       c_global_attribute20             IN VARCHAR2,
                       c_orig_system_reference          IN VARCHAR2,
                       c_status                         IN VARCHAR2,
                       c_customer_type                  IN VARCHAR2,
                       c_customer_class_code            IN VARCHAR2,
                       c_primary_salesrep_id            IN NUMBER ,
                       c_sales_channel_code             IN VARCHAR2,
                       c_order_type_id                  IN NUMBER,
                       c_price_list_id                  IN NUMBER ,
                       c_category_code                  IN VARCHAR2,
                       c_reference_use_flag             IN VARCHAR2,
                       c_tax_code                       IN VARCHAR2,
                       c_third_party_flag               IN VARCHAR2,
                       c_competitor_flag                IN VARCHAR2,
                       c_fob_point                      IN VARCHAR2,
                       c_tax_header_level_flag          IN VARCHAR2,
                       c_tax_rounding_rule              IN VARCHAR2,
                       c_account_name                   IN VARCHAR2,
                       c_freight_term                   IN VARCHAR2,
                       c_ship_partial                   IN VARCHAR2,
                       c_ship_via                       IN VARCHAR2,
                       c_warehouse_id                   IN NUMBER,
                       c_payment_term_id                IN NUMBER ,
                       c_analysis_fy                    IN VARCHAR2,
                       c_fiscal_yearend_month           IN VARCHAR2,
                       c_employees_total                IN NUMBER,
                       c_cr_fy_potential_revenue        IN NUMBER,
                       c_next_fy_potential_revenue      IN NUMBER,
                       c_tax_reference                  IN VARCHAR2,
                       c_year_established               IN NUMBER,
                       c_gsa_indicator_flag             IN VARCHAR2,
                       c_jgzz_fiscal_code               IN VARCHAR2,
                       c_do_not_mail_flag               IN VARCHAR2,
                       c_mission_statement              IN VARCHAR2,
                       c_org_name_phonetic              IN VARCHAR2,
                       c_url                            IN VARCHAR2,
                       c_person_suffix                  IN VARCHAR2,
                       c_first_name                     IN VARCHAR2,
                       c_middle_name                    IN VARCHAR2,
                       c_last_name                      IN VARCHAR2,
                       c_person_prefix                  IN VARCHAR2,
                       c_sic_code                       IN VARCHAR2,
                       c_sic_code_type                  IN VARCHAR2,
                       c_duns_number                    IN NUMBER,
                       c_DATES_NEGATIVE_TOLERANCE       IN NUMBER,
                       c_DATES_POSITIVE_TOLERANCE       IN NUMBER,
                       c_DATE_TYPE_PREFERENCE           IN VARCHAR2,
                       c_OVER_SHIPMENT_TOLERANCE        IN NUMBER,
                       c_UNDER_SHIPMENT_TOLERANCE       IN NUMBER,
                       c_ITEM_CROSS_REF_PREF            IN VARCHAR2,
                       c_OVER_RETURN_TOLERANCE          IN NUMBER,
                       c_UNDER_RETURN_TOLERANCE         IN NUMBER,
                       c_SHIP_SETS_INCLUDE_LINES_FLAG   IN VARCHAR2,
                       c_ARRIVALSETS_INCL_LINES_FLAG    IN VARCHAR2,
                       c_SCHED_DATE_PUSH_FLAG           IN VARCHAR2,
                       c_INVOICE_QUANTITY_RULE          IN VARCHAR2,
                       c_account_alias                  IN VARCHAR2 DEFAULT NULL,
                       p_cust_account_profile_id        IN NUMBER ,
                       p_cust_account_id                IN NUMBER ,
                       p_status                         IN VARCHAR2,
                       p_collector_id                   IN NUMBER ,
                       p_credit_analyst_id              IN NUMBER ,
                       p_credit_checking                IN VARCHAR2,
                       p_next_credit_review_date           DATE ,
                       p_tolerance                      IN NUMBER,
                       p_discount_terms                 IN VARCHAR2,
                       p_dunning_letters                IN VARCHAR2,
                       p_interest_charges               IN VARCHAR2,
                       p_send_statements                IN VARCHAR2,
                       p_credit_balance_statements      IN VARCHAR2,
                       p_credit_hold                    IN VARCHAR2,
                       p_profile_class_id               IN NUMBER ,
                       p_site_use_id                    IN NUMBER ,
                       p_credit_rating                  IN VARCHAR2,
                       p_risk_code                      IN VARCHAR2,
                       p_standard_terms                 IN NUMBER ,
                       p_override_terms                 IN VARCHAR2,
                       p_dunning_letter_set_id          IN NUMBER,
                       p_interest_period_days           IN NUMBER,
                       p_payment_grace_days             IN NUMBER,
                       p_discount_grace_days            IN NUMBER,
                       p_statement_cycle_id             IN NUMBER ,
                       p_account_status                 IN VARCHAR2,
                       p_percent_collectable            IN NUMBER ,
                       p_autocash_hierarchy_id          IN NUMBER,
                       p_Attribute_Category             IN VARCHAR2,
                       p_Attribute1                     IN VARCHAR2,
                       p_Attribute2                     IN VARCHAR2,
                       p_Attribute3                     IN VARCHAR2,
                       p_Attribute4                     IN VARCHAR2,
                       p_Attribute5                     IN VARCHAR2,
                       p_Attribute6                     IN VARCHAR2,
                       p_Attribute7                     IN VARCHAR2,
                       p_Attribute8                     IN VARCHAR2,
                       p_Attribute9                     IN VARCHAR2,
                       p_Attribute10                    IN VARCHAR2,
                       p_Attribute11                    IN VARCHAR2,
                       p_Attribute12                    IN VARCHAR2,
                       p_Attribute13                    IN VARCHAR2,
                       p_Attribute14                    IN VARCHAR2,
                       p_Attribute15                    IN VARCHAR2,
                       p_auto_rec_incl_disputed_flag    IN VARCHAR2,
                       p_tax_printing_option            IN VARCHAR2,
                       p_charge_on_fin_charge_flag      IN VARCHAR2,
                       p_grouping_rule_id               IN NUMBER ,
                       p_clearing_days                  IN NUMBER,
                       p_jgzz_attribute_category        IN VARCHAR2,
                       p_jgzz_attribute1                IN VARCHAR2,
                       p_jgzz_attribute2                IN VARCHAR2,
                       p_jgzz_attribute3                IN VARCHAR2,
                       p_jgzz_attribute4                IN VARCHAR2,
                       p_jgzz_attribute5                IN VARCHAR2,
                       p_jgzz_attribute6                IN VARCHAR2,
                       p_jgzz_attribute7                IN VARCHAR2,
                       p_jgzz_attribute8                IN VARCHAR2,
                       p_jgzz_attribute9                IN VARCHAR2,
                       p_jgzz_attribute10               IN VARCHAR2,
                       p_jgzz_attribute11               IN VARCHAR2,
                       p_jgzz_attribute12               IN VARCHAR2,
                       p_jgzz_attribute13               IN VARCHAR2,
                       p_jgzz_attribute14               IN VARCHAR2,
                       p_jgzz_attribute15               IN VARCHAR2,
                       p_global_attribute_category      IN VARCHAR2,
                       p_global_attribute1              IN VARCHAR2,
                       p_global_attribute2              IN VARCHAR2,
                       p_global_attribute3              IN VARCHAR2,
                       p_global_attribute4              IN VARCHAR2,
                       p_global_attribute5              IN VARCHAR2,
                       p_global_attribute6              IN VARCHAR2,
                       p_global_attribute7              IN VARCHAR2,
                       p_global_attribute8              IN VARCHAR2,
                       p_global_attribute9              IN VARCHAR2,
                       p_global_attribute10             IN VARCHAR2,
                       p_global_attribute11             IN VARCHAR2,
                       p_global_attribute12             IN VARCHAR2,
                       p_global_attribute13             IN VARCHAR2,
                       p_global_attribute14             IN VARCHAR2,
                       p_global_attribute15             IN VARCHAR2,
                       p_global_attribute16             IN VARCHAR2,
                       p_global_attribute17             IN VARCHAR2,
                       p_global_attribute18             IN VARCHAR2,
                       p_global_attribute19             IN VARCHAR2,
                       p_global_attribute20             IN VARCHAR2,
                       p_cons_inv_flag                  IN VARCHAR2,
                       p_cons_inv_type                  IN VARCHAR2,
                       p_autocash_hier_id_for_adr       IN NUMBER ,
                       p_lockbox_matching_option        IN VARCHAR2,
--{2310474
                       p_party_id                       IN NUMBER   DEFAULT  NULL,
                       p_review_cycle                   IN VARCHAR2 DEFAULT  NULL,
                       p_credit_classification          IN VARCHAR2 DEFAULT  NULL,
                       p_last_credit_review_date        IN DATE     DEFAULT  NULL,
--}
                       a_last_update_date               IN OUT NOCOPY DATE,
                       a_object_version                 IN OUT NOCOPY NUMBER,
                       p_last_update_date               IN OUT NOCOPY DATE,
                       x_cr_last_update_date            IN OUT NOCOPY DATE,
                       x_pt_last_update_date            IN OUT NOCOPY DATE,
                       x_cp_last_update_date            IN OUT NOCOPY DATE,
                       x_op_last_update_date            IN OUT NOCOPY DATE,
                       x_pp_last_update_date            IN OUT NOCOPY DATE,
                       x_account_type                   IN VARCHAR,
                       o_organization_profile_id        in out NOCOPY number,
                       o_person_profile_id              in out NOCOPY number,
                       x_msg_count                      OUT NOCOPY NUMBER,
                       x_msg_data                       OUT NOCOPY varchar2,
                       x_return_status                  OUT NOCOPY VARCHAR2,
                       c_duns_number_c                  IN VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                       x_cust_acct_object_version       IN NUMBER   DEFAULT -1,
                       x_cust_prof_object_version       IN NUMBER   DEFAULT -1,
                       x_party_object_version           IN NUMBER   DEFAULT -1)
 IS

--   acct_rec        hz_customer_accounts_pub.account_rec_type;
--   prof_rec        hz_customer_accounts_pub.cust_profile_rec_type;
--   party_rec       hz_party_pub.party_rec_type;
--   prel_rec        hz_party_pub.party_rel_rec_type;
--   person_rec      hz_party_pub.person_rec_type;
--   org_rec         hz_party_pub.organization_rec_type;


   acct_rec   hz_cust_account_v2pub.cust_account_rec_type;
   prof_rec   hz_customer_profile_v2pub.customer_profile_rec_type;
   party_rec  hz_party_v2pub.party_rec_type;
   prel_rec   hz_relationship_v2pub.relationship_rec_type;
   person_rec hz_party_v2pub.person_rec_type;
   org_rec    hz_party_v2pub.organization_rec_type;

   tmp_var                          VARCHAR2(2000);
   i                                number;
   tmp_var1                         VARCHAR2(2000);
   x_customer_id                    number;
   x_cust_account_number            VARCHAR2(100);
   x_party_id                       number;
   x_party_number                   VARCHAR2(100);
   x_profile_id                     number;
   x_party_rel_id                   number;
   x_party_rel_last_update_date     DATE;
   x_party_last_update_date         DATE;
   x_end_date                       DATE;
   i_internal_party_id              number;

  cursor C_REFERENCE_FOR is
         select relationship_id
           from hz_relationships
          where subject_id = c_party_id
            and relationship_code = 'REFERENCE_FOR'
            and subject_table_name = 'HZ_PARTIES'
            and object_table_name = 'HZ_PARTIES'
            and directional_flag = 'F';

  cursor C_PARTNER_OF is
       select relationship_id
         from hz_relationships
        where subject_id = c_party_id
          and relationship_code = 'PARTNER_OF'
          and subject_table_name = 'HZ_PARTIES'
          and object_table_name = 'HZ_PARTIES'
          and directional_flag = 'F';

   cursor C_COMPETITOR_OF is
        select relationship_id
          from hz_relationships
         where subject_id = c_party_id
           and relationship_code = 'COMPETITOR_OF'
           and subject_table_name = 'HZ_PARTIES'
           and object_table_name = 'HZ_PARTIES'
           and directional_flag = 'F';

   i_pr_party_relationship_id NUMBER;
   i_pr_party_id              NUMBER;
   i_pr_party_number          VARCHAR2(100);

   CURSOR cu_cust_acct_version IS
   SELECT ROWID,
          OBJECT_VERSION_NUMBER,
          LAST_UPDATE_DATE
     FROM HZ_CUST_ACCOUNTS
    WHERE CUST_ACCOUNT_ID = c_cust_account_id;

   CURSOR cu_cust_prof_version IS
   SELECT ROWID,
          OBJECT_VERSION_NUMBER,
          LAST_UPDATE_DATE,
          CUST_ACCOUNT_ID
     FROM HZ_CUSTOMER_PROFILES
    WHERE CUST_ACCOUNT_PROFILE_ID = p_cust_account_profile_id;


   l_cust_acct_rowid             ROWID;
   l_cust_acct_object_version    NUMBER;
   l_cust_acct_last_update_date  DATE;
   l_dummy_id                    NUMBER;

   l_cust_prof_rowid             ROWID;
   l_cust_prof_object_version    NUMBER;
   l_cust_prof_last_update_date  DATE;
   l_cust_acct_id                NUMBER;

   l_party_rowid                 ROWID;
   l_party_object_version        NUMBER;
   l_party_last_update_date      DATE;
   l_party_id                    NUMBER;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ---------------------------
   --{ Update Customer Account
   ---------------------------

    IF (a_last_update_date IS NOT NULL ) THEN
    --
      l_cust_acct_object_version := x_cust_acct_object_version;
      IF l_cust_acct_object_version = -1 THEN
           object_version_select (
                   p_table_name             => 'HZ_CUST_ACCOUNTS',
                   p_col_id                 => c_cust_account_id,
                   x_rowid                  => l_cust_acct_rowid,
                   x_object_version_number  => l_cust_acct_object_version,
                   x_last_update_date       => l_cust_acct_last_update_date,
                   x_id_value               => l_dummy_id,
                   x_return_status          => x_return_status,
                   x_msg_count              => x_msg_count,
                   x_msg_data               => x_msg_data
            );
           IF x_msg_count > 1 THEN
              FOR i IN 1..x_msg_count  LOOP
                tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                tmp_var1 := tmp_var1 || ' '|| tmp_var;
              END LOOP;
             x_msg_data := tmp_var1;
           END IF;

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              return;
           END IF;

    END IF;
    --
    acct_rec.cust_account_id        := C_Cust_account_Id;
    --  acct_rec.party_id               := INIT_SWITCH(C_Party_Id);
    acct_rec.account_number         := INIT_SWITCH(C_account_Number);
    acct_rec.attribute_category     := INIT_SWITCH(C_Attribute_Category);
    acct_rec.attribute1             := INIT_SWITCH(C_Attribute1);
    acct_rec.attribute2             := INIT_SWITCH(C_Attribute2);
    acct_rec.attribute3             := INIT_SWITCH(C_Attribute3);
    acct_rec.attribute4             := INIT_SWITCH(C_Attribute4);
    acct_rec.attribute5             := INIT_SWITCH(C_Attribute5);
    acct_rec.attribute6             := INIT_SWITCH(C_Attribute6);
    acct_rec.attribute7             := INIT_SWITCH(C_Attribute7);
    acct_rec.attribute8             := INIT_SWITCH(C_Attribute8);
    acct_rec.attribute9             := INIT_SWITCH(C_Attribute9);
    acct_rec.attribute10            := INIT_SWITCH(C_Attribute10);
    acct_rec.attribute11            := INIT_SWITCH(C_Attribute11);
    acct_rec.attribute12            := INIT_SWITCH(C_Attribute12);
    acct_rec.attribute13            := INIT_SWITCH(C_Attribute13);
    acct_rec.attribute14            := INIT_SWITCH(C_Attribute14);
    acct_rec.attribute15            := INIT_SWITCH(C_Attribute15);
    acct_rec.attribute16            := INIT_SWITCH(C_Attribute16);
    acct_rec.attribute17            := INIT_SWITCH(C_Attribute17);
    acct_rec.attribute18            := INIT_SWITCH(C_Attribute18);
    acct_rec.attribute19            := INIT_SWITCH(C_Attribute19);
    acct_rec.attribute20            := INIT_SWITCH(C_Attribute20);
    acct_rec.global_attribute_category := INIT_SWITCH(C_Global_Attribute_Category);
    acct_rec.global_attribute1      := INIT_SWITCH(C_Global_Attribute1);
    acct_rec.global_attribute2      := INIT_SWITCH(C_Global_Attribute2);
    acct_rec.global_attribute3      := INIT_SWITCH(C_Global_Attribute3);
    acct_rec.global_attribute4      := INIT_SWITCH(C_Global_Attribute4);
    acct_rec.global_attribute5      := INIT_SWITCH(C_Global_Attribute5);
    acct_rec.global_attribute6      := INIT_SWITCH(C_Global_Attribute6);
    acct_rec.global_attribute7      := INIT_SWITCH(C_Global_Attribute7);
    acct_rec.global_attribute8      := INIT_SWITCH(C_Global_Attribute8);
    acct_rec.global_attribute9      := INIT_SWITCH(C_Global_Attribute9);
    acct_rec.global_attribute10     := INIT_SWITCH(C_Global_Attribute10);
    acct_rec.global_attribute11     := INIT_SWITCH(C_Global_Attribute11);
    acct_rec.global_attribute12     := INIT_SWITCH(C_Global_Attribute12);
    acct_rec.global_attribute13     := INIT_SWITCH(C_Global_Attribute13);
    acct_rec.global_attribute14     := INIT_SWITCH(C_Global_Attribute14);
    acct_rec.global_attribute15     := INIT_SWITCH(C_Global_Attribute15);
    acct_rec.global_attribute16     := INIT_SWITCH(C_Global_Attribute16);
    acct_rec.global_attribute17     := INIT_SWITCH(C_Global_Attribute17);
    acct_rec.global_attribute18     := INIT_SWITCH(C_Global_Attribute18);
    acct_rec.global_attribute19     := INIT_SWITCH(C_Global_Attribute19);
    acct_rec.global_attribute20     := INIT_SWITCH(C_Global_Attribute20);
 -- acct_rec.orig_system_reference  := INIT_SWITCH(C_Orig_System_Reference);
    acct_rec.status                 := INIT_SWITCH(C_Status);
    acct_rec.customer_type          := INIT_SWITCH(c_customer_type);
    acct_rec.customer_class_code    := INIT_SWITCH(C_Customer_Class_Code);
    acct_rec.primary_salesrep_id    := INIT_SWITCH(C_Primary_Salesrep_Id);
    acct_rec.sales_channel_code     := INIT_SWITCH(C_Sales_Channel_Code);
    acct_rec.order_type_id          := INIT_SWITCH(C_Order_Type_Id);
    acct_rec.price_list_id          := INIT_SWITCH(C_Price_List_Id);
--  acct_rec.category_code          := INIT_SWITCH(C_Category_Code);
--  acct_rec.reference_use_flag     := INIT_SWITCH(C_Reference_Use_Flag);
    acct_rec.tax_code               := INIT_SWITCH(C_Tax_Code);
--  acct_rec.third_party_flag       := INIT_SWITCH(C_Third_Party_Flag);
--  acct_rec.competitor_flag        := INIT_SWITCH(c_competitor_flag);
    acct_rec.fob_point              := INIT_SWITCH(C_Fob_Point);
    acct_rec.tax_header_level_flag  := INIT_SWITCH(C_Tax_Header_Level_Flag);
    acct_rec.tax_rounding_rule      := INIT_SWITCH(C_Tax_Rounding_Rule);
    acct_rec.primary_specialist_id  := NULL;
    acct_rec.secondary_specialist_id := NULL;
--    acct_rec.geo_code                := NULL;
    acct_rec.account_name            := INIT_SWITCH(c_account_alias); --c_account_name;
    acct_rec.freight_term            := INIT_SWITCH(C_Freight_Term);
    acct_rec.ship_partial            := INIT_SWITCH(C_Ship_Partial);
    acct_rec.ship_via                := INIT_SWITCH(C_Ship_Via);
    acct_rec.warehouse_id            := INIT_SWITCH(C_Warehouse_Id);
--    acct_rec.payment_term_id         := NULL;
    acct_rec.account_liable_flag     := null;
    acct_rec.DATES_NEGATIVE_TOLERANCE     := INIT_SWITCH(c_DATES_NEGATIVE_TOLERANCE);
    acct_rec.DATES_POSITIVE_TOLERANCE     := INIT_SWITCH(c_DATES_POSITIVE_TOLERANCE);
    acct_rec.DATE_TYPE_PREFERENCE         := INIT_SWITCH(c_DATE_TYPE_PREFERENCE);
    acct_rec.OVER_SHIPMENT_TOLERANCE      := INIT_SWITCH(c_OVER_SHIPMENT_TOLERANCE);
    acct_rec.UNDER_SHIPMENT_TOLERANCE     := INIT_SWITCH(c_UNDER_SHIPMENT_TOLERANCE);
    acct_rec.ITEM_CROSS_REF_PREF          := INIT_SWITCH(c_ITEM_CROSS_REF_PREF);
    acct_rec.SHIP_SETS_INCLUDE_LINES_FLAG := INIT_SWITCH(c_SHIP_SETS_INCLUDE_LINES_FLAG);
    acct_rec.ARRIVALSETS_INCLUDE_LINES_FLAG := INIT_SWITCH(c_ARRIVALSETS_INCL_LINES_FLAG);
    acct_rec.SCHED_DATE_PUSH_FLAG         := INIT_SWITCH(c_SCHED_DATE_PUSH_FLAG);
    acct_rec.INVOICE_QUANTITY_RULE        := INIT_SWITCH(c_INVOICE_QUANTITY_RULE);
    acct_rec.OVER_RETURN_TOLERANCE        := INIT_SWITCH(c_OVER_RETURN_TOLERANCE);
    acct_rec.UNDER_RETURN_TOLERANCE       := INIT_SWITCH(c_UNDER_RETURN_TOLERANCE);

    HZ_CUST_ACCOUNT_V2PUB.update_cust_account (
            p_cust_account_rec                  => acct_rec,
            p_object_version_number             => l_cust_acct_object_version,
            x_return_status                     => x_return_status,
            x_msg_count                         => x_msg_count,
            x_msg_data                          => x_msg_data
    );

    IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
    END IF;

    SELECT last_update_date,
           object_version_number
      INTO a_last_update_date,
           a_object_version
      FROM hz_cust_accounts
     WHERE cust_account_id = c_cust_account_id;
  END IF;


  ---------------------------
  --{ Update Customer Profile
  ---------------------------
  IF (p_last_update_date is not null) THEN

    l_cust_prof_object_version := x_cust_prof_object_version;
    IF l_cust_prof_object_version  = -1 THEN
       object_version_select(
            p_table_name             => 'HZ_CUSTOMER_PROFILES',
            p_col_id                 => p_cust_account_profile_id,
            x_rowid                  => l_cust_prof_rowid,
            x_object_version_number  => l_cust_prof_object_version,
            x_last_update_date       => l_cust_prof_last_update_date,
            x_id_value               => l_cust_acct_id,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data );

            IF x_msg_count > 1 THEN
               FOR i IN 1..x_msg_count  LOOP
                 tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                 tmp_var1 := tmp_var1 || ' '|| tmp_var;
               END LOOP;
               x_msg_data := tmp_var1;
            END IF;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               return;
            END IF;

    END IF;

    prof_rec.cust_account_profile_id       := INIT_SWITCH(p_cust_account_profile_id);
    prof_rec.cust_account_id               := INIT_SWITCH(p_cust_account_id);
    prof_rec.status                        := INIT_SWITCH(p_status);
    prof_rec.collector_id                  := INIT_SWITCH(p_collector_id);
    prof_rec.credit_analyst_id             := INIT_SWITCH(p_credit_analyst_id);
    prof_rec.credit_checking               := INIT_SWITCH(p_credit_checking);
    prof_rec.next_credit_review_date       := INIT_SWITCH(p_next_credit_review_date);
    prof_rec.tolerance                     := INIT_SWITCH(p_tolerance);
    prof_rec.discount_terms                := INIT_SWITCH(p_discount_terms);
    prof_rec.dunning_letters               := INIT_SWITCH(p_dunning_letters);
    prof_rec.interest_charges              := INIT_SWITCH(p_interest_charges);
    prof_rec.send_statements               := INIT_SWITCH(p_send_statements);
    prof_rec.credit_balance_statements     := INIT_SWITCH(p_credit_balance_statements);
    prof_rec.credit_hold                   := INIT_SWITCH(p_credit_hold);
    prof_rec.profile_class_id              := INIT_SWITCH(p_profile_class_id);
    prof_rec.site_use_id                   := INIT_SWITCH(p_site_use_id);
    prof_rec.credit_rating                 := INIT_SWITCH(p_credit_rating);
    prof_rec.risk_code                     := INIT_SWITCH(p_risk_code);
    prof_rec.standard_terms                := INIT_SWITCH(p_standard_terms);
    prof_rec.override_terms                := INIT_SWITCH(p_override_terms);
    prof_rec.dunning_letter_set_id         := INIT_SWITCH(p_dunning_letter_set_id);
    prof_rec.interest_period_days          := INIT_SWITCH(p_interest_period_days);
    prof_rec.payment_grace_days            := INIT_SWITCH(p_payment_grace_days);
    prof_rec.discount_grace_days           := INIT_SWITCH(p_discount_grace_days);
    prof_rec.statement_cycle_id            := INIT_SWITCH(p_statement_cycle_id);
    prof_rec.account_status                := INIT_SWITCH(p_account_status);
    prof_rec.percent_collectable           := INIT_SWITCH(p_percent_collectable);
    prof_rec.autocash_hierarchy_id         := INIT_SWITCH(p_autocash_hierarchy_id);
    prof_rec.attribute_category            := INIT_SWITCH(p_attribute_category);
    prof_rec.attribute1                    := INIT_SWITCH(p_attribute1);
    prof_rec.attribute2                    := INIT_SWITCH(p_attribute2);
    prof_rec.attribute3                    := INIT_SWITCH(p_attribute3);
    prof_rec.attribute4                    := INIT_SWITCH(p_attribute4);
    prof_rec.attribute5                    := INIT_SWITCH(p_attribute5);
    prof_rec.attribute6                    := INIT_SWITCH(p_attribute6);
    prof_rec.attribute7                    := INIT_SWITCH(p_attribute7);
    prof_rec.attribute8                    := INIT_SWITCH(p_attribute8);
    prof_rec.attribute9                    := INIT_SWITCH(p_attribute9);
    prof_rec.attribute10                   := INIT_SWITCH(p_attribute10);
    prof_rec.attribute11                   := INIT_SWITCH(p_attribute11);
    prof_rec.attribute12                   := INIT_SWITCH(p_attribute12);
    prof_rec.attribute13                   := INIT_SWITCH(p_attribute13);
    prof_rec.attribute14                   := INIT_SWITCH(p_attribute14);
    prof_rec.attribute15                   := INIT_SWITCH(p_attribute15);
    prof_rec.auto_rec_incl_disputed_flag   := INIT_SWITCH(p_auto_rec_incl_disputed_flag);
    prof_rec.tax_printing_option           := INIT_SWITCH(p_tax_printing_option);
    prof_rec.charge_on_finance_charge_flag := INIT_SWITCH(p_charge_on_fin_charge_flag);
    prof_rec.grouping_rule_id              := INIT_SWITCH(p_grouping_rule_id);
    prof_rec.clearing_days                 := INIT_SWITCH(p_clearing_days);
    prof_rec.jgzz_attribute_category       := INIT_SWITCH(p_jgzz_attribute_category);
    prof_rec.jgzz_attribute1               := INIT_SWITCH(p_jgzz_attribute1);
    prof_rec.jgzz_attribute2               := INIT_SWITCH(p_jgzz_attribute2);
    prof_rec.jgzz_attribute3               := INIT_SWITCH(p_jgzz_attribute3);
    prof_rec.jgzz_attribute4               := INIT_SWITCH(p_jgzz_attribute4);
    prof_rec.jgzz_attribute5               := INIT_SWITCH(p_jgzz_attribute5);
    prof_rec.jgzz_attribute6               := INIT_SWITCH(p_jgzz_attribute6);
    prof_rec.jgzz_attribute7               := INIT_SWITCH(p_jgzz_attribute7);
    prof_rec.jgzz_attribute8               := INIT_SWITCH(p_jgzz_attribute8);
    prof_rec.jgzz_attribute9               := INIT_SWITCH(p_jgzz_attribute9);
    prof_rec.jgzz_attribute10              := INIT_SWITCH(p_jgzz_attribute10);
    prof_rec.jgzz_attribute11              := INIT_SWITCH(p_jgzz_attribute11);
    prof_rec.jgzz_attribute12              := INIT_SWITCH(p_jgzz_attribute12);
    prof_rec.jgzz_attribute13              := INIT_SWITCH(p_jgzz_attribute13);
    prof_rec.jgzz_attribute14              := INIT_SWITCH(p_jgzz_attribute14);
    prof_rec.jgzz_attribute15              := INIT_SWITCH(p_jgzz_attribute15);
    prof_rec.global_attribute1             := INIT_SWITCH(p_global_attribute1);
    prof_rec.global_attribute2             := INIT_SWITCH(p_global_attribute2);
    prof_rec.global_attribute3             := INIT_SWITCH(p_global_attribute3);
    prof_rec.global_attribute4             := INIT_SWITCH(p_global_attribute4);
    prof_rec.global_attribute5             := INIT_SWITCH(p_global_attribute5);
    prof_rec.global_attribute6             := INIT_SWITCH(p_global_attribute6);
    prof_rec.global_attribute7             := INIT_SWITCH(p_global_attribute7);
    prof_rec.global_attribute8             := INIT_SWITCH(p_global_attribute8);
    prof_rec.global_attribute9             := INIT_SWITCH(p_global_attribute9);
    prof_rec.global_attribute10            := INIT_SWITCH(p_global_attribute10);
    prof_rec.global_attribute11            := INIT_SWITCH(p_global_attribute11);
    prof_rec.global_attribute12            := INIT_SWITCH(p_global_attribute12);
    prof_rec.global_attribute13            := INIT_SWITCH(p_global_attribute13);
    prof_rec.global_attribute14            := INIT_SWITCH(p_global_attribute14);
    prof_rec.global_attribute15            := INIT_SWITCH(p_global_attribute15);
    prof_rec.global_attribute16            := INIT_SWITCH(p_global_attribute16);
    prof_rec.global_attribute17            := INIT_SWITCH(p_global_attribute17);
    prof_rec.global_attribute18            := INIT_SWITCH(p_global_attribute18);
    prof_rec.global_attribute19            := INIT_SWITCH(p_global_attribute19);
    prof_rec.global_attribute20            := INIT_SWITCH(p_global_attribute20);
    prof_rec.global_attribute_category     := INIT_SWITCH(p_global_attribute_category);
    prof_rec.cons_inv_flag                 := INIT_SWITCH(p_cons_inv_flag);
    prof_rec.cons_inv_type                 := INIT_SWITCH(p_cons_inv_type);
    prof_rec.autocash_hierarchy_id_for_adr := INIT_SWITCH(p_autocash_hier_id_for_adr);
    prof_rec.lockbox_matching_option       := INIT_SWITCH(p_lockbox_matching_option);
--{2310474
    prof_rec.party_id                      := p_party_id;
    prof_rec.review_cycle                  := INIT_SWITCH(p_review_cycle);
    prof_rec.credit_classification         := INIT_SWITCH(p_credit_classification);
    prof_rec.last_credit_review_date       := INIT_SWITCH(p_last_credit_review_date);
--}

    -- call V2 API.
    HZ_CUSTOMER_PROFILE_V2PUB.update_customer_profile (
                  p_customer_profile_rec              => prof_rec,
                  p_object_version_number             => l_cust_prof_object_version,
                  x_return_status                     => x_return_status,
                  x_msg_count                         => x_msg_count,
                  x_msg_data                          => x_msg_data
      );

    IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
    END IF;

    SELECT last_update_date INTO p_last_update_date
      FROM hz_customer_profiles
     WHERE cust_account_profile_id = p_cust_account_profile_id;
  END IF;

  ----------------------------
  --{ Update Party ORG or PERS
  ----------------------------
  l_party_object_version := x_party_object_version;
  IF l_party_object_version = -1 THEN

           object_version_select (
                   p_table_name             => 'HZ_ORG_PERS',
                   p_col_id                 => C_Party_Id,
                   x_rowid                  => l_party_rowid,
                   x_object_version_number  => l_party_object_version,
                   x_last_update_date       => l_party_last_update_date,
                   x_id_value               => l_dummy_id,
                   x_return_status          => x_return_status,
                   x_msg_count              => x_msg_count,
                   x_msg_data               => x_msg_data
            );
           IF x_msg_count > 1 THEN
              FOR i IN 1..x_msg_count  LOOP
                 tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                 tmp_var1 := tmp_var1 || ' '|| tmp_var;
              END LOOP;
              x_msg_data := tmp_var1;
           END IF;

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             return;
           END IF;

  END IF;

  IF (x_account_type = 'ORGANIZATION') THEN

       org_rec.party_rec.category_code       := INIT_SWITCH(C_Category_Code);
    -- org_rec.party_rec.reference_use_flag  := INIT_SWITCH(C_Reference_Use_Flag);
    -- org_rec.party_rec.third_party_flag    := INIT_SWITCH(C_Third_Party_Flag);
    -- org_rec.party_rec.competitor_flag     := INIT_SWITCH(c_competitor_flag);
       org_rec.party_rec.party_id            := INIT_SWITCH(C_Party_Id);
       org_rec.organization_name             := INIT_SWITCH(c_account_name);
       org_rec.sic_code                      := INIT_SWITCH(c_sic_code);
       org_rec.sic_code_type                 := INIT_SWITCH(c_sic_code_type);
       org_rec.analysis_fy                   := INIT_SWITCH(c_analysis_fy);
       org_rec.fiscal_yearend_month          := INIT_SWITCH(c_fiscal_yearend_month);
       org_rec.employees_total               := INIT_SWITCH(c_employees_total);
       org_rec.curr_fy_potential_revenue     := INIT_SWITCH(c_cr_fy_potential_revenue);
       org_rec.next_fy_potential_revenue     := INIT_SWITCH(c_next_fy_potential_revenue);
       org_rec.year_established              := INIT_SWITCH(c_year_established);
       org_rec.gsa_indicator_flag            := INIT_SWITCH(c_gsa_indicator_flag);
       org_rec.jgzz_fiscal_code              := INIT_SWITCH(c_jgzz_fiscal_code);
       org_rec.mission_statement             := INIT_SWITCH(c_mission_statement);
       org_rec.organization_name_phonetic    := INIT_SWITCH(c_org_name_phonetic);
  --   org_rec.duns_number                   := INIT_SWITCH(c_duns_number);
       org_rec.duns_number_c                 := INIT_SWITCH(c_duns_number_c);
       org_rec.tax_reference                 := INIT_SWITCH(c_tax_reference);
       org_rec.content_source_type           := NVL(org_rec.content_source_type,'USER_ENTERED');

       HZ_PARTY_V2PUB.update_organization (
          p_organization_rec                  => org_rec,
          p_party_object_version_number       => l_party_object_version,
          x_profile_id                        => o_organization_profile_id,
          x_return_status                     => x_return_status,
          x_msg_count                         => x_msg_count,
          x_msg_data                          => x_msg_data
       );

    IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
    END IF;


      SELECT last_update_date INTO x_op_last_update_date
        FROM hz_organization_profiles
      WHERE party_id = c_party_id
         AND content_source_type = 'USER_ENTERED'
         AND organization_profile_id = o_organization_profile_id;

      SELECT last_update_date INTO x_pt_last_update_date
        FROM hz_parties
       WHERE party_id = c_party_id;

  ELSIF  (x_account_type = 'PERSON') THEN

      person_rec.party_rec.party_id         := INIT_SWITCH(C_Party_Id);
      person_rec.party_rec.category_code    := INIT_SWITCH(C_Category_Code);
--Bug Fix 1713617
      person_rec.person_name_phonetic       := INIT_SWITCH(c_org_name_phonetic);
-- person_rec.party_rec.reference_use_flag:= INIT_SWITCH(C_Reference_Use_Flag);
-- person_rec.party_rec.third_party_flag  := INIT_SWITCH(C_Third_Party_Flag);
-- person_rec.party_rec.competitor_flag   := INIT_SWITCH(c_competitor_flag);
      person_rec.person_pre_name_adjunct    := INIT_SWITCH(c_person_prefix);
      person_rec.person_first_name          := INIT_SWITCH(c_first_name);
      person_rec.person_middle_name         := INIT_SWITCH(c_middle_name);
      person_rec.person_last_name           := INIT_SWITCH(c_last_name);
      person_rec.person_name_suffix         := INIT_SWITCH(c_person_suffix);
      person_rec.tax_reference              := INIT_SWITCH(c_tax_reference);
      person_rec.jgzz_fiscal_code           := INIT_SWITCH(c_jgzz_fiscal_code);
      person_rec.content_source_type        := NVL(person_rec.content_source_type,'USER_ENTERED');

      HZ_PARTY_V2PUB.update_person (
        p_person_rec                        => person_rec,
        p_party_object_version_number       => l_party_object_version,
        x_profile_id                        => o_person_profile_id,
        x_return_status                     => x_return_status,
        x_msg_count                         => x_msg_count,
        x_msg_data                          => x_msg_data
       );

    IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
    END IF;


      SELECT last_update_date
        INTO x_pp_last_update_date
        FROM hz_person_profiles
       WHERE party_id = c_party_id
         AND content_source_type = 'USER_ENTERED'
         AND person_profile_id = o_person_profile_id;

      SELECT last_update_date
        INTO x_pt_last_update_date
        FROM hz_parties
       WHERE party_id = c_party_id;

  END IF;

  i_internal_party_id := fnd_profile.value('HZ_INTERNAL_PARTY');
  IF i_internal_party_id IS NOT NULL THEN
     x_party_last_update_date    := x_pt_last_update_date;
     x_end_date                  := sysdate;

     Ref_Part_Comp (
           c_party_id           => c_party_id,
           c_party_type         => x_account_type,
           i_internal_party_id  => i_internal_party_id,
           C_Reference_Use_Flag => C_Reference_Use_Flag,
           C_Third_Party_Flag   => C_Third_Party_Flag,
           C_competitor_flag    => C_competitor_flag,
           x_return_status      => x_return_status,
           x_msg_count          => x_msg_count,
           x_msg_data           => x_msg_data,
           x_end_date           => x_end_date );

    IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
    END IF;

  END IF;

 END update_row;

--
-- Overload method for the usage of Object_version_number of V2 uptake project and the bug #1736839
--
 PROCEDURE update_row(
                       c_cust_account_id                IN OUT NOCOPY NUMBER ,
                       c_party_id                       IN NUMBER,
                       c_account_number                 IN VARCHAR2,
                       c_Attribute_Category             IN VARCHAR2,
                       c_Attribute1                     IN VARCHAR2,
                       c_Attribute2                     IN VARCHAR2,
                       c_Attribute3                     IN VARCHAR2,
                       c_Attribute4                     IN VARCHAR2,
                       c_Attribute5                     IN VARCHAR2,
                       c_Attribute6                     IN VARCHAR2,
                       c_Attribute7                     IN VARCHAR2,
                       c_Attribute8                     IN VARCHAR2,
                       c_Attribute9                     IN VARCHAR2,
                       c_Attribute10                    IN VARCHAR2,
                       c_Attribute11                    IN VARCHAR2,
                       c_Attribute12                    IN VARCHAR2,
                       c_Attribute13                    IN VARCHAR2,
                       c_Attribute14                    IN VARCHAR2,
                       c_Attribute15                    IN VARCHAR2,
                       c_Attribute16                    IN VARCHAR2,
                       c_Attribute17                    IN VARCHAR2,
                       c_Attribute18                    IN VARCHAR2,
                       c_Attribute19                    IN VARCHAR2,
                       c_Attribute20                    IN VARCHAR2,
                       c_global_attribute_category      IN VARCHAR2,
                       c_global_attribute1              IN VARCHAR2,
                       c_global_attribute2              IN VARCHAR2,
                       c_global_attribute3              IN VARCHAR2,
                       c_global_attribute4              IN VARCHAR2,
                       c_global_attribute5              IN VARCHAR2,
                       c_global_attribute6              IN VARCHAR2,
                       c_global_attribute7              IN VARCHAR2,
                       c_global_attribute8              IN VARCHAR2,
                       c_global_attribute9              IN VARCHAR2,
                       c_global_attribute10             IN VARCHAR2,
                       c_global_attribute11             IN VARCHAR2,
                       c_global_attribute12             IN VARCHAR2,
                       c_global_attribute13             IN VARCHAR2,
                       c_global_attribute14             IN VARCHAR2,
                       c_global_attribute15             IN VARCHAR2,
                       c_global_attribute16             IN VARCHAR2,
                       c_global_attribute17             IN VARCHAR2,
                       c_global_attribute18             IN VARCHAR2,
                       c_global_attribute19             IN VARCHAR2,
                       c_global_attribute20             IN VARCHAR2,
                       c_orig_system_reference          IN VARCHAR2,
                       c_status                         IN VARCHAR2,
                       c_customer_type                  IN VARCHAR2,
                       c_customer_class_code            IN VARCHAR2,
                       c_primary_salesrep_id            IN NUMBER ,
                       c_sales_channel_code             IN VARCHAR2,
                       c_order_type_id                  IN NUMBER,
                       c_price_list_id                  IN NUMBER ,
                       c_category_code                  IN VARCHAR2,
                       c_reference_use_flag             IN VARCHAR2,
                       c_tax_code                       IN VARCHAR2,
                       c_third_party_flag               IN VARCHAR2,
                       c_competitor_flag                IN VARCHAR2,
                       c_fob_point                      IN VARCHAR2,
                       c_tax_header_level_flag          IN VARCHAR2,
                       c_tax_rounding_rule              IN VARCHAR2,
                       c_account_name                   IN VARCHAR2,
                       c_freight_term                   IN VARCHAR2,
                       c_ship_partial                   IN VARCHAR2,
                       c_ship_via                       IN VARCHAR2,
                       c_warehouse_id                   IN NUMBER,
                       c_payment_term_id                IN NUMBER ,
                       c_analysis_fy                    IN VARCHAR2,
                       c_fiscal_yearend_month           IN VARCHAR2,
                       c_employees_total                IN NUMBER,
                       c_cr_fy_potential_revenue        IN NUMBER,
                       c_next_fy_potential_revenue      IN NUMBER,
                       c_tax_reference                  IN VARCHAR2,
                       c_year_established               IN NUMBER,
                       c_gsa_indicator_flag             IN VARCHAR2,
                       c_jgzz_fiscal_code               IN VARCHAR2,
                       c_do_not_mail_flag               IN VARCHAR2,
                       c_mission_statement              IN VARCHAR2,
                       c_org_name_phonetic              IN VARCHAR2,
                       c_url                            IN VARCHAR2,
                       c_person_suffix                  IN VARCHAR2,
                       c_first_name                     IN VARCHAR2,
                       c_middle_name                    IN VARCHAR2,
                       c_last_name                      IN VARCHAR2,
                       c_person_prefix                  IN VARCHAR2,
                       c_sic_code                       IN VARCHAR2,
                       c_sic_code_type                  IN VARCHAR2,
                       c_duns_number                    IN NUMBER,
                       c_DATES_NEGATIVE_TOLERANCE       IN NUMBER,
                       c_DATES_POSITIVE_TOLERANCE       IN NUMBER,
                       c_DATE_TYPE_PREFERENCE           IN VARCHAR2,
                       c_OVER_SHIPMENT_TOLERANCE        IN NUMBER,
                       c_UNDER_SHIPMENT_TOLERANCE       IN NUMBER,
                       c_ITEM_CROSS_REF_PREF            IN VARCHAR2,
                       c_OVER_RETURN_TOLERANCE          IN NUMBER,
                       c_UNDER_RETURN_TOLERANCE         IN NUMBER,
                       c_SHIP_SETS_INCLUDE_LINES_FLAG   IN VARCHAR2,
                       c_ARRIVALSETS_INCL_LINES_FLAG    IN VARCHAR2,
                       c_SCHED_DATE_PUSH_FLAG           IN VARCHAR2,
                       c_INVOICE_QUANTITY_RULE          IN VARCHAR2,
                       c_account_alias                  IN VARCHAR2 DEFAULT NULL,
                       p_cust_account_profile_id        IN NUMBER ,
                       p_cust_account_id                IN NUMBER ,
                       p_status                         IN VARCHAR2,
                       p_collector_id                   IN NUMBER ,
                       p_credit_analyst_id              IN NUMBER ,
                       p_credit_checking                IN VARCHAR2,
                       p_next_credit_review_date           DATE ,
                       p_tolerance                      IN NUMBER,
                       p_discount_terms                 IN VARCHAR2,
                       p_dunning_letters                IN VARCHAR2,
                       p_interest_charges               IN VARCHAR2,
                       p_send_statements                IN VARCHAR2,
                       p_credit_balance_statements      IN VARCHAR2,
                       p_credit_hold                    IN VARCHAR2,
                       p_profile_class_id               IN NUMBER ,
                       p_site_use_id                    IN NUMBER ,
                       p_credit_rating                  IN VARCHAR2,
                       p_risk_code                      IN VARCHAR2,
                       p_standard_terms                 IN NUMBER ,
                       p_override_terms                 IN VARCHAR2,
                       p_dunning_letter_set_id          IN NUMBER,
                       p_interest_period_days           IN NUMBER,
                       p_payment_grace_days             IN NUMBER,
                       p_discount_grace_days            IN NUMBER,
                       p_statement_cycle_id             IN NUMBER ,
                       p_account_status                 IN VARCHAR2,
                       p_percent_collectable            IN NUMBER ,
                       p_autocash_hierarchy_id          IN NUMBER,
                       p_Attribute_Category             IN VARCHAR2,
                       p_Attribute1                     IN VARCHAR2,
                       p_Attribute2                     IN VARCHAR2,
                       p_Attribute3                     IN VARCHAR2,
                       p_Attribute4                     IN VARCHAR2,
                       p_Attribute5                     IN VARCHAR2,
                       p_Attribute6                     IN VARCHAR2,
                       p_Attribute7                     IN VARCHAR2,
                       p_Attribute8                     IN VARCHAR2,
                       p_Attribute9                     IN VARCHAR2,
                       p_Attribute10                    IN VARCHAR2,
                       p_Attribute11                    IN VARCHAR2,
                       p_Attribute12                    IN VARCHAR2,
                       p_Attribute13                    IN VARCHAR2,
                       p_Attribute14                    IN VARCHAR2,
                       p_Attribute15                    IN VARCHAR2,
                       p_auto_rec_incl_disputed_flag    IN VARCHAR2,
                       p_tax_printing_option            IN VARCHAR2,
                       p_charge_on_fin_charge_flag      IN VARCHAR2,
                       p_grouping_rule_id               IN NUMBER ,
                       p_clearing_days                  IN NUMBER,
                       p_jgzz_attribute_category        IN VARCHAR2,
                       p_jgzz_attribute1                IN VARCHAR2,
                       p_jgzz_attribute2                IN VARCHAR2,
                       p_jgzz_attribute3                IN VARCHAR2,
                       p_jgzz_attribute4                IN VARCHAR2,
                       p_jgzz_attribute5                IN VARCHAR2,
                       p_jgzz_attribute6                IN VARCHAR2,
                       p_jgzz_attribute7                IN VARCHAR2,
                       p_jgzz_attribute8                IN VARCHAR2,
                       p_jgzz_attribute9                IN VARCHAR2,
                       p_jgzz_attribute10               IN VARCHAR2,
                       p_jgzz_attribute11               IN VARCHAR2,
                       p_jgzz_attribute12               IN VARCHAR2,
                       p_jgzz_attribute13               IN VARCHAR2,
                       p_jgzz_attribute14               IN VARCHAR2,
                       p_jgzz_attribute15               IN VARCHAR2,
                       p_global_attribute_category      IN VARCHAR2,
                       p_global_attribute1              IN VARCHAR2,
                       p_global_attribute2              IN VARCHAR2,
                       p_global_attribute3              IN VARCHAR2,
                       p_global_attribute4              IN VARCHAR2,
                       p_global_attribute5              IN VARCHAR2,
                       p_global_attribute6              IN VARCHAR2,
                       p_global_attribute7              IN VARCHAR2,
                       p_global_attribute8              IN VARCHAR2,
                       p_global_attribute9              IN VARCHAR2,
                       p_global_attribute10             IN VARCHAR2,
                       p_global_attribute11             IN VARCHAR2,
                       p_global_attribute12             IN VARCHAR2,
                       p_global_attribute13             IN VARCHAR2,
                       p_global_attribute14             IN VARCHAR2,
                       p_global_attribute15             IN VARCHAR2,
                       p_global_attribute16             IN VARCHAR2,
                       p_global_attribute17             IN VARCHAR2,
                       p_global_attribute18             IN VARCHAR2,
                       p_global_attribute19             IN VARCHAR2,
                       p_global_attribute20             IN VARCHAR2,
                       p_cons_inv_flag                  IN VARCHAR2,
                       p_cons_inv_type                  IN VARCHAR2,
                       p_autocash_hier_id_for_adr       IN NUMBER ,
                       p_lockbox_matching_option        IN VARCHAR2,
--{2310474
                       p_party_id                       IN NUMBER   DEFAULT NULL,
                       p_review_cycle                   IN VARCHAR2 DEFAULT NULL,
                       p_credit_classification          IN VARCHAR2 DEFAULT NULL,
                       p_last_credit_review_date        IN DATE     DEFAULT NULL,
--}
                       a_last_update_date               IN OUT NOCOPY DATE,
                       p_last_update_date               IN OUT NOCOPY DATE,
                       x_cr_last_update_date            IN OUT NOCOPY DATE,
                       x_pt_last_update_date            IN OUT NOCOPY DATE,
                       x_cp_last_update_date            IN OUT NOCOPY DATE,
                       x_op_last_update_date            IN OUT NOCOPY DATE,
                       x_pp_last_update_date            IN OUT NOCOPY DATE,
                       x_account_type                   IN VARCHAR,
                       o_organization_profile_id        in out NOCOPY number,
                       o_person_profile_id              in out NOCOPY number,
                       x_msg_count                      OUT NOCOPY NUMBER,
                       x_msg_data                       OUT NOCOPY varchar2,
                       x_return_status                  OUT NOCOPY VARCHAR2,
                       c_duns_number_c                  IN VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                       x_cust_acct_object_version       IN NUMBER   DEFAULT -1,
                       x_cust_prof_object_version       IN NUMBER   DEFAULT -1,
                       x_party_object_version           IN NUMBER   DEFAULT -1)
  IS
    l_object_version  number;
  begin
     update_row(
                       c_cust_account_id    ,
                       c_party_id           ,
                       c_account_number     ,
                       c_Attribute_Category ,
                       c_Attribute1         ,
                       c_Attribute2         ,
                       c_Attribute3         ,
                       c_Attribute4         ,
                       c_Attribute5         ,
                       c_Attribute6         ,
                       c_Attribute7         ,
                       c_Attribute8         ,
                       c_Attribute9         ,
                       c_Attribute10        ,
                       c_Attribute11        ,
                       c_Attribute12        ,
                       c_Attribute13        ,
                       c_Attribute14        ,
                       c_Attribute15        ,
                       c_Attribute16        ,
                       c_Attribute17        ,
                       c_Attribute18        ,
                       c_Attribute19        ,
                       c_Attribute20        ,
                       c_global_attribute_category,
                       c_global_attribute1  ,
                       c_global_attribute2  ,
                       c_global_attribute3  ,
                       c_global_attribute4  ,
                       c_global_attribute5  ,
                       c_global_attribute6  ,
                       c_global_attribute7  ,
                       c_global_attribute8  ,
                       c_global_attribute9  ,
                       c_global_attribute10 ,
                       c_global_attribute11 ,
                       c_global_attribute12 ,
                       c_global_attribute13 ,
                       c_global_attribute14 ,
                       c_global_attribute15 ,
                       c_global_attribute16 ,
                       c_global_attribute17 ,
                       c_global_attribute18 ,
                       c_global_attribute19 ,
                       c_global_attribute20 ,
                       c_orig_system_reference ,
                       c_status             ,
                       c_customer_type      ,
                       c_customer_class_code,
                       c_primary_salesrep_id,
                       c_sales_channel_code ,
                       c_order_type_id      ,
                       c_price_list_id      ,
                       c_category_code      ,
                       c_reference_use_flag ,
                       c_tax_code           ,
                       c_third_party_flag   ,
                       c_competitor_flag    ,
                       c_fob_point          ,
                       c_tax_header_level_flag,
                       c_tax_rounding_rule  ,
                       c_account_name       ,
                       c_freight_term       ,
                       c_ship_partial       ,
                       c_ship_via           ,
                       c_warehouse_id       ,
                       c_payment_term_id    ,
                       c_analysis_fy        ,
                       c_fiscal_yearend_month,
                       c_employees_total    ,
                       c_cr_fy_potential_revenue,
                       c_next_fy_potential_revenue,
                       c_tax_reference      ,
                       c_year_established   ,
                       c_gsa_indicator_flag ,
                       c_jgzz_fiscal_code   ,
                       c_do_not_mail_flag   ,
                       c_mission_statement  ,
                       c_org_name_phonetic  ,
                       c_url                ,
                       c_person_suffix      ,
                       c_first_name         ,
                       c_middle_name        ,
                       c_last_name          ,
                       c_person_prefix      ,
                       c_sic_code           ,
                       c_sic_code_type      ,
                       c_duns_number        ,
                       c_DATES_NEGATIVE_TOLERANCE,
                       c_DATES_POSITIVE_TOLERANCE,
                       c_DATE_TYPE_PREFERENCE,
                       c_OVER_SHIPMENT_TOLERANCE,
                       c_UNDER_SHIPMENT_TOLERANCE,
                       c_ITEM_CROSS_REF_PREF,
                       c_OVER_RETURN_TOLERANCE,
                       c_UNDER_RETURN_TOLERANCE,
                       c_SHIP_SETS_INCLUDE_LINES_FLAG,
                       c_ARRIVALSETS_INCL_LINES_FLAG,
                       c_SCHED_DATE_PUSH_FLAG,
                       c_INVOICE_QUANTITY_RULE,
                       c_account_alias       ,
                       p_cust_account_profile_id,
                       p_cust_account_id     ,
                       p_status              ,
                       p_collector_id        ,
                       p_credit_analyst_id   ,
                       p_credit_checking     ,
                       p_next_credit_review_date,
                       p_tolerance           ,
                       p_discount_terms      ,
                       p_dunning_letters     ,
                       p_interest_charges    ,
                       p_send_statements     ,
                       p_credit_balance_statements,
                       p_credit_hold         ,
                       p_profile_class_id    ,
                       p_site_use_id         ,
                       p_credit_rating       ,
                       p_risk_code           ,
                       p_standard_terms      ,
                       p_override_terms      ,
                       p_dunning_letter_set_id,
                       p_interest_period_days,
                       p_payment_grace_days  ,
                       p_discount_grace_days ,
                       p_statement_cycle_id  ,
                       p_account_status      ,
                       p_percent_collectable ,
                       p_autocash_hierarchy_id,
                       p_Attribute_Category  ,
                       p_Attribute1          ,
                       p_Attribute2          ,
                       p_Attribute3          ,
                       p_Attribute4          ,
                       p_Attribute5          ,
                       p_Attribute6          ,
                       p_Attribute7          ,
                       p_Attribute8          ,
                       p_Attribute9          ,
                       p_Attribute10         ,
                       p_Attribute11         ,
                       p_Attribute12         ,
                       p_Attribute13         ,
                       p_Attribute14         ,
                       p_Attribute15         ,
                       p_auto_rec_incl_disputed_flag,
                       p_tax_printing_option ,
                       p_charge_on_fin_charge_flag,
                       p_grouping_rule_id    ,
                       p_clearing_days       ,
                       p_jgzz_attribute_category,
                       p_jgzz_attribute1     ,
                       p_jgzz_attribute2     ,
                       p_jgzz_attribute3     ,
                       p_jgzz_attribute4     ,
                       p_jgzz_attribute5     ,
                       p_jgzz_attribute6     ,
                       p_jgzz_attribute7     ,
                       p_jgzz_attribute8     ,
                       p_jgzz_attribute9     ,
                       p_jgzz_attribute10    ,
                       p_jgzz_attribute11    ,
                       p_jgzz_attribute12    ,
                       p_jgzz_attribute13    ,
                       p_jgzz_attribute14    ,
                       p_jgzz_attribute15    ,
                       p_global_attribute_category,
                       p_global_attribute1   ,
                       p_global_attribute2   ,
                       p_global_attribute3   ,
                       p_global_attribute4   ,
                       p_global_attribute5   ,
                       p_global_attribute6   ,
                       p_global_attribute7   ,
                       p_global_attribute8   ,
                       p_global_attribute9   ,
                       p_global_attribute10  ,
                       p_global_attribute11  ,
                       p_global_attribute12  ,
                       p_global_attribute13  ,
                       p_global_attribute14  ,
                       p_global_attribute15  ,
                       p_global_attribute16  ,
                       p_global_attribute17  ,
                       p_global_attribute18  ,
                       p_global_attribute19  ,
                       p_global_attribute20  ,
                       p_cons_inv_flag       ,
                       p_cons_inv_type       ,
                       p_autocash_hier_id_for_adr,
                       p_lockbox_matching_option ,
--{2310474
                       p_party_id,
                       p_review_cycle,
                       p_credit_classification,
                       p_last_credit_review_date,
--}
                       a_last_update_date    ,
                       l_object_version      ,
                       p_last_update_date    ,
                       x_cr_last_update_date ,
                       x_pt_last_update_date ,
                       x_cp_last_update_date ,
                       x_op_last_update_date ,
                       x_pp_last_update_date ,
                       x_account_type        ,
                       o_organization_profile_id,
                       o_person_profile_id   ,
                       x_msg_count           ,
                       x_msg_data            ,
                       x_return_status       ,
                       c_duns_number_c       ,
                       x_cust_acct_object_version,
                       x_cust_prof_object_version,
                       x_party_object_version    );

   END;


--
-- PROCEDURE
--     check_unique_party_number
--
-- DESCRIPTION
--    RRaise error if party number is duplicate
--
-- SCOPE - PUBLIC
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:
--                      - p_rowid - rowid of row
--                      - p_party_number
--
--              OUT:
--
--   RETURNS  null
--
--  NOTES
--
--
procedure check_unique_party_number(p_rowid in varchar2,
                                       p_party_number in varchar2
                                      ) is
dummy number;
begin

        select 1
        into   dummy
        from   dual
        where  not exists ( select 1
                           from   hz_parties
                           where  party_number = p_party_number
                           and    ( ( p_rowid is null ) or (rowid <> p_rowid))
                          );

exception
        when NO_DATA_FOUND then
                fnd_message.set_name ('AR','AR_PARTY_NUMBER_EXISTS');
                app_exception.raise_exception;
end check_unique_party_number;
--
--


END hz_acct_create_pkg;

/
