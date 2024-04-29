--------------------------------------------------------
--  DDL for Package Body OKE_CONTRACT_PRINTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_CONTRACT_PRINTING_PKG" AS
/* $Header: OKEKCPPB.pls 120.1 2007/12/20 06:29:50 neerakum ship $ */

FUNCTION  get_article_subject_name(p_sbt_code IN VARCHAR2)RETURN VARCHAR2
   IS
       l_not_found BOOLEAN;
       l_meaning VARCHAR2(80);

       Cursor c Is
         SELECT MEANING
         FROM FND_LOOKUPS
         WHERE LOOKUP_TYPE ='OKC_SUBJECT'
         AND LOOKUP_CODE = p_sbt_code;

    BEGIN
         open c;
         fetch c into l_meaning;
         l_not_found := c%NOTFOUND;
         close c;

/*
         If (l_not_found) Then
             raise NO_DATA_FOUND;
         End If;
*/
       RETURN l_meaning;

   END get_article_subject_name;

FUNCTION get_full_path_linenum(vk_line_id NUMBER,vVersion NUMBER) RETURN VARCHAR2
  IS
    l_parent_id NUMBER;
    l_linenum varchar2(300);
    isTop_line varchar2(1) :='?';

    cursor c_isTop_line is
     select 'x'
    FROM OKE_K_LINES_FULL_HV
    WHERE k_line_id= vk_line_id
    AND parent_line_id is NULL
    AND MAJOR_VERSION=vVersion;

  BEGIN
    SELECT line_number
    INTO l_linenum
    FROM OKE_K_LINES_FULL_HV
    WHERE k_line_id =vk_line_id
    AND MAJOR_VERSION=vVersion;

    OPEN c_isTop_line;
    FETCH c_isTop_line INTO isTop_line;
    CLOSE c_isTop_line;

    IF isTop_line = 'x'  THEN
       RETURN l_linenum;
    ELSE
       SELECT parent_line_id
       INTO l_parent_id
       FROM OKE_K_LINES_FULL_HV
       WHERE k_line_id=vk_line_id
       AND MAJOR_VERSION=vVersion;
       RETURN (get_full_path_linenum(l_parent_id,vVersion)||'-->'||l_linenum);

    END IF;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
       NULL;
       WHEN OTHERS THEN
       NULL;

 END get_full_path_linenum;

FUNCTION get_full_path_linenum(vk_line_id NUMBER) RETURN VARCHAR2
  IS
    l_parent_id NUMBER;
    l_linenum varchar2(300);
    isTop_line varchar2(1) :='?';

    cursor c_isTop_line is
     select 'x'
    FROM OKE_K_LINES_FULL_V
    WHERE k_line_id= vk_line_id
    AND parent_line_id is NULL;

  BEGIN
    SELECT line_number
    INTO l_linenum
    FROM OKE_K_LINES_FULL_V
    WHERE k_line_id =vk_line_id;

    OPEN c_isTop_line;
    FETCH c_isTop_line INTO isTop_line;
    CLOSE c_isTop_line;

    IF isTop_line = 'x'  THEN
       RETURN l_linenum;
    ELSE
       SELECT parent_line_id
       INTO l_parent_id
       FROM OKE_K_LINES_FULL_V
       WHERE k_line_id=vk_line_id;
       RETURN (get_full_path_linenum(l_parent_id)||'-->'||l_linenum);

    END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        NULL;
        WHEN OTHERS THEN
        NULL;

 END get_full_path_linenum;

 PROCEDURE get_item_master_org(p_header_id      IN          NUMBER
                                ,x_org_name     OUT NOCOPY  VARCHAR2)
   IS

     l_org_name  VARCHAR2(240);
     --l_own_org_id NUMBER := name_in('K_HEADER.OWNING_ORGANIZATION_ID');
     --l_own_org_name VARCHAR2(60);

    CURSOR c(p_id number) is
      select org.name
      from hr_all_organization_units org
      ,    okc_k_headers_b ch
      where org.organization_id = ch.inv_organization_id
      and   ch.id =p_id ;


    BEGIN
      OPEN C(p_header_id);
      FETCH C INTO l_org_name;

      IF(C%NOTFOUND) THEN
         CLOSE C;
         RAISE NO_DATA_FOUND;
      END IF;

      CLOSE C;

--dbms_output.put_line('l org' ||l_org_name);
      x_org_name :=l_org_name;

    END get_item_master_org;



   PROCEDURE get_partyOrContact_name(p_jtot_object1_code    IN           VARCHAR2
                                    ,p_object1_id1          IN           VARCHAR2
                                    ,p_object1_id2          IN           VARCHAR2
                                    ,p_name                 OUT   NOCOPY VARCHAR2
                                    )
   IS
     l_name  VARCHAR2(4000) ;

   BEGIN

     l_name :=OKC_UTIL.get_name_from_jtfv(p_jtot_object1_code,p_object1_id1,p_object1_id2);

--     DBMS_OUTPUT.PUT_LINE(l_name);
/*
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       NULL;
       WHEN OTHERS THEN
       NULL;
*/
     p_name :=l_name;
   END get_partyOrContact_name;

   PROCEDURE get_article_info(p_cat_type      IN          VARCHAR2
                             ,p_sav_sae_id    IN          NUMBER
                             ,p_sbt_code      IN          VARCHAR2
                             ,p_article_name  IN          VARCHAR2
                             ,x_sbt_code      OUT NOCOPY  VARCHAR2
                             ,x_article_name  OUT NOCOPY  VARCHAR2
                             ,x_subject_name  OUT NOCOPY  VARCHAR2)
   IS

      CURSOR C (p_id number)IS
         SELECT NAME,SBT_CODE
         FROM OKC_STD_ARTICLES_V
         WHERE ID = p_id;

      l_name VARCHAR2(150);
      l_sbt_code VARCHAR2(30);
      l_not_found BOOLEAN;

   BEGIN
      IF p_cat_type = 'STA' THEN
          If (p_sav_sae_id is not null) Then

             OPEN C(p_sav_sae_id);
             FETCH C into l_name,l_sbt_code;

             IF (C%NOTFOUND) THEN
               CLOSE C;
               RAISE NO_DATA_FOUND;
             End If;

             CLOSE C;

             x_article_name := l_name;
             x_sbt_code :=l_sbt_code;
             x_subject_name := get_article_subject_name(x_sbt_code);

          END IF;

      ELSE
          x_article_name :=p_article_name;
          x_sbt_code :=p_sbt_code;
          x_subject_name := get_article_subject_name(p_sbt_code);

      END IF;
   END get_article_info;

   PROCEDURE get_article_application(p_id                     IN               NUMBER
                                    ,p_version                IN               NUMBER
                                    ,p_cat_type               IN               VARCHAR2
                                    ,p_sav_sae_id             IN               NUMBER
                                    ,p_sav_sav_release        IN               VARCHAR2
                                    ,x_comments               OUT    NOCOPY    VARCHAR2
                                    ,x_lines_applied          OUT    NOCOPY    VARCHAR2
                                    ,x_text                   OUT    NOCOPY    CLOB)
   IS

      l_line_number        VARCHAR2(150);
      l_lines_applied      VARCHAR2(2000) := '';
      l_text               CLOB;
      l_comments           VARCHAR2(1995);
      l_latest_version     NUMBER; -- The latest version number of the contract

      cursor c_version is
        select max(major_version)
        from oke_k_headers_hv
        where k_header_id =p_id;

      cursor c_line_number_h(p_line_id NUMBER) is
        select line_number
        from oke_k_lines_hv
        where header_id = p_id
        and k_line_id = p_line_id
        and major_version = p_version;

      cursor c_line_number(p_line_id NUMBER) is
        select line_number
        from oke_k_lines_v
        where header_id = p_id
        and k_line_id = p_line_id;

      cursor c_line_ids_h is
        select cle_id,comments,text
        from okc_k_articles_hv
        where dnz_chr_id = p_id
        and cat_type=p_cat_type
        and sav_sae_id=p_sav_sae_id
        and sav_sav_release = p_sav_sav_release
        and major_version = p_version;

      cursor c_line_ids is
        select cle_id,comments,text
        from okc_k_articles_v
        where dnz_chr_id = p_id
        and cat_type=p_cat_type
        and sav_sae_id=p_sav_sae_id
        and sav_sav_release = p_sav_sav_release;

   BEGIN

       OPEN c_version;
       FETCH c_version INTO l_latest_version;
       CLOSE c_version;


       IF p_version<=l_latest_version THEN

            for c_line_id in c_line_ids_h loop

               if c_line_id.cle_id is null then
                  l_line_number :='';
               else
               		open c_line_number_h(c_line_id.cle_id);
               		fetch c_line_number_h into l_line_number;
               		close c_line_number_h;

               		if l_lines_applied is null then
                  		l_lines_applied := l_line_number;
               		else
                  	        l_lines_applied := l_lines_applied ||','||l_line_number;
               		end if;
               end if;

               l_text  :=c_line_id.text;
               l_comments :=c_line_id.comments;

            end loop;

       ELSE

            for c_line_id in c_line_ids loop

               if c_line_id.cle_id is null then
                  l_line_number :='';
               else
               		open c_line_number(c_line_id.cle_id);
               		fetch c_line_number into l_line_number;
               		close c_line_number;

               		if l_lines_applied is null then
                  		l_lines_applied := l_line_number;
               		else
                  	        l_lines_applied := l_lines_applied ||','||l_line_number;
               		end if;
               end if;

               l_text  :=c_line_id.text;
               l_comments :=c_line_id.comments;

            end loop;
       END IF;


       x_lines_applied := l_lines_applied;


       x_text := l_text;
       x_comments :=l_comments;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
        NULL;
        WHEN OTHERS THEN
        NULL;


   END get_article_application;

   PROCEDURE convert_date(p_date      IN             DATE
                          ,x_date     OUT  NOCOPY    VARCHAR2)
   IS

   BEGIN

     IF p_date IS NOT NULL THEN
        x_date := to_char(p_date, 'DD-MM-YYYY');
     ELSE
        x_date :='';
     END IF;

   END convert_date;

   PROCEDURE get_line_number(p_id            IN           NUMBER
                            ,p_version       IN           NUMBER
                            ,p_line_id       IN           NUMBER
                            ,x_line_number   OUT  NOCOPY  VARCHAR2)
   IS
     l_latest_version     NUMBER; -- The latest version number of the contract
     l_line_number        VARCHAR2(150) := '';

     cursor c_version is
        select max(major_version)
        from oke_k_headers_hv
        where k_header_id =p_id;

     cursor c_line_number_h is
        select line_number
        from oke_k_lines_hv
        where header_id = p_id
        and k_line_id = p_line_id
        and major_version = p_version;

      cursor c_line_number is
        select line_number
        from oke_k_lines_v
        where header_id = p_id
        and k_line_id = p_line_id;

   BEGIN
      OPEN c_version;
      FETCH c_version INTO l_latest_version;
      CLOSE c_version;

      IF p_line_id IS NOT NULL THEN
      		IF p_version<=l_latest_version THEN
         		open c_line_number_h;
         		fetch c_line_number_h into l_line_number;
         		close c_line_number_h;
      		ELSE
         		open c_line_number;
         		fetch c_line_number into l_line_number;
         		close c_line_number;
      		END IF;

                x_line_number :=l_line_number;
      ELSE
                l_line_number :='';
      END IF;



     EXCEPTION
        WHEN NO_DATA_FOUND THEN
        NULL;
        WHEN OTHERS THEN
        NULL;
   END get_line_number;



END OKE_CONTRACT_PRINTING_PKG;


/
