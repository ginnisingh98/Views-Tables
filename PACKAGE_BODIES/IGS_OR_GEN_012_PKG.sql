--------------------------------------------------------
--  DDL for Package Body IGS_OR_GEN_012_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_OR_GEN_012_PKG" AS
/* $Header: IGSOR12B.pls 120.3 2006/02/06 23:40:08 pkpatel ship $ */

  PROCEDURE create_organization (
      p_institution_cd                    IN  VARCHAR2,
      p_name                              IN  VARCHAR2,
      p_status                            IN  VARCHAR2,
      p_attribute_category                IN  VARCHAR2,
      p_attribute1                        IN  VARCHAR2,
      p_attribute2                        IN  VARCHAR2,
      p_attribute3                        IN  VARCHAR2,
      p_attribute4                        IN  VARCHAR2,
      p_attribute5                        IN  VARCHAR2,
      p_attribute6                        IN  VARCHAR2,
      p_attribute7                        IN  VARCHAR2,
      p_attribute8                        IN  VARCHAR2,
      p_attribute9                        IN  VARCHAR2,
      p_attribute10                       IN  VARCHAR2,
      p_attribute11                       IN  VARCHAR2,
      p_attribute12                       IN  VARCHAR2,
      p_attribute13                       IN  VARCHAR2,
      p_attribute14                       IN  VARCHAR2,
      p_attribute15                       IN  VARCHAR2,
      p_attribute16                       IN  VARCHAR2,
      p_attribute17                       IN  VARCHAR2,
      p_attribute18                       IN  VARCHAR2,
      p_attribute19                       IN  VARCHAR2,
      p_attribute20                       IN  VARCHAR2,
      p_return_status                     OUT NOCOPY VARCHAR2,
      p_msg_data                          OUT NOCOPY VARCHAR2,
      p_party_id                          OUT NOCOPY NUMBER,
      p_object_version_number             IN OUT NOCOPY NUMBER,
      p_attribute21                       IN  VARCHAR2,
      p_attribute22                       IN  VARCHAR2,
      p_attribute23                       IN  VARCHAR2,
      p_attribute24                       IN  VARCHAR2
  ) AS
  /*
  ||  Created By : Sameer.Manglm@oracle.com
  ||  Created On : 28-AUG-2000
  ||  Purpose : To make the call to hz_party_pub_create_organization
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    v_msg_count           NUMBER;
    v_party_number        hz_parties.party_number%TYPE;
    v_profile_id          NUMBER;

  -- record type variable
    v_organization_rec_type    hz_party_v2pub.organization_rec_type;
    v_party_rec                hz_party_v2pub.party_rec_type;

    tmp_var1          VARCHAR2(2000);
    tmp_var           VARCHAR2(2000);
  BEGIN
  -- initialising the record type variables
    v_party_rec.party_number := p_institution_cd;
    v_organization_rec_type.created_by_module    := 'IGS';
    v_organization_rec_type.content_source_type  := 'USER_ENTERED';
    v_party_rec.attribute_category:= p_attribute_category;
    v_party_rec.attribute1  := p_attribute1;
    v_party_rec.attribute2  := p_attribute2;
    v_party_rec.attribute3  := p_attribute3;
    v_party_rec.attribute4  := p_attribute4;
    v_party_rec.attribute5  := p_attribute5;
    v_party_rec.attribute6  := p_attribute6;
    v_party_rec.attribute7  := p_attribute7;
    v_party_rec.attribute8  := p_attribute8;
    v_party_rec.attribute9  := p_attribute9;
    v_party_rec.attribute10 := p_attribute10;
    v_party_rec.attribute11 := p_attribute11;
    v_party_rec.attribute12 := p_attribute12;
    v_party_rec.attribute13 := p_attribute13;
    v_party_rec.attribute14 := p_attribute14;
    v_party_rec.attribute15 := p_attribute15;
    v_party_rec.attribute16 := p_attribute16;
    v_party_rec.attribute17 := p_attribute17;
    v_party_rec.attribute18 := p_attribute18;
    v_party_rec.attribute19 := p_attribute19;
    v_party_rec.attribute20 := p_attribute20;
    v_party_rec.attribute21 := p_attribute21;
    v_party_rec.attribute22 := p_attribute22;
    v_party_rec.attribute23 := p_attribute23;
    v_party_rec.attribute24 := p_attribute24;
    v_party_rec.status      := p_status;

    v_organization_rec_type.organization_name := p_name;
    v_organization_rec_type.party_rec := v_party_rec;


-- call to create organization
-- masehgal    made call to hz_party_V2pub to create organisation
    hz_party_v2pub.create_organization (
       p_init_msg_list            => FND_API.G_TRUE,
       p_organization_rec         => v_organization_rec_type,
       x_return_status            => p_return_status,
       x_msg_count                => v_msg_count,
       x_msg_data                 => p_msg_data,
       x_party_id                 => p_party_id,
       x_party_number             => v_party_number,
       x_profile_id               => v_profile_id
       ) ;

    IF p_return_status <> 'S' THEN
    -- bug 2338473 logic to display more than one error modified.
       IF v_msg_count > 1 THEN
          FOR i IN 1..v_msg_count  LOOP
              tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
              tmp_var1 := tmp_var1 || ' '|| tmp_var;
          END LOOP;
          p_msg_data := tmp_var1;
       END IF;
       -- if creation was UN successful then OVN should be 0
       p_object_version_number    :=0;
       RETURN;
    END IF;
    -- if creation was successful then OVN should be 1
    p_object_version_number    :=1;
  END create_organization;

  PROCEDURE update_organization (
      p_party_id                          IN  NUMBER,
      p_institution_cd                    IN  VARCHAR2,
      p_name                              IN  VARCHAR2,
      p_status                            IN  VARCHAR2,
      p_last_update                       IN  OUT NOCOPY DATE,
      p_attribute_category                IN  VARCHAR2,
      p_attribute1                        IN  VARCHAR2,
      p_attribute2                        IN  VARCHAR2,
      p_attribute3                        IN  VARCHAR2,
      p_attribute4                        IN  VARCHAR2,
      p_attribute5                        IN  VARCHAR2,
      p_attribute6                        IN  VARCHAR2,
      p_attribute7                        IN  VARCHAR2,
      p_attribute8                        IN  VARCHAR2,
      p_attribute9                        IN  VARCHAR2,
      p_attribute10                       IN  VARCHAR2,
      p_attribute11                       IN  VARCHAR2,
      p_attribute12                       IN  VARCHAR2,
      p_attribute13                       IN  VARCHAR2,
      p_attribute14                       IN  VARCHAR2,
      p_attribute15                       IN  VARCHAR2,
      p_attribute16                       IN  VARCHAR2,
      p_attribute17                       IN  VARCHAR2,
      p_attribute18                       IN  VARCHAR2,
      p_attribute19                       IN  VARCHAR2,
      p_attribute20                       IN  VARCHAR2,
      p_return_status                     OUT NOCOPY VARCHAR2,
      p_msg_data                          OUT NOCOPY VARCHAR2,
      p_object_version_number             IN OUT NOCOPY NUMBER,
      p_attribute21                       IN  VARCHAR2,
      p_attribute22                       IN  VARCHAR2,
      p_attribute23                       IN  VARCHAR2,
      p_attribute24                       IN  VARCHAR2
  ) AS
  /*
  ||  Created By : Sameer.Manglm@oracle.com
  ||  Created On : 28-AUG-2000
  ||  Purpose : To call the API hz_part_pub.update_organization
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    v_msg_count      NUMBER;
    v_profile_id     NUMBER;
    tmp_var1         VARCHAR2(2000);
    tmp_var          VARCHAR2(2000);
    -- record type variable
    v_organization_rec_type    hz_party_v2pub.organization_rec_type;
    v_party_rec                hz_party_v2pub.party_rec_type;

   BEGIN
  -- initialising the record type variables
  -- masehgal   changed nullable attributes to NVL(parameter,FND_API.G_MISS_XXXX)
    v_party_rec.party_id := p_party_id;
    v_party_rec.status := p_status;
    v_party_rec.party_number := p_institution_cd;
    v_party_rec.attribute_category:= NVL(p_attribute_category,FND_API.G_MISS_CHAR);
    v_party_rec.attribute1  := NVL(p_attribute1,FND_API.G_MISS_CHAR);
    v_party_rec.attribute2  := NVL(p_attribute2,FND_API.G_MISS_CHAR);
    v_party_rec.attribute3  := NVL(p_attribute3,FND_API.G_MISS_CHAR);
    v_party_rec.attribute4  := NVL(p_attribute4,FND_API.G_MISS_CHAR);
    v_party_rec.attribute5  := NVL(p_attribute5,FND_API.G_MISS_CHAR);
    v_party_rec.attribute6  := NVL(p_attribute6,FND_API.G_MISS_CHAR);
    v_party_rec.attribute7  := NVL(p_attribute7,FND_API.G_MISS_CHAR);
    v_party_rec.attribute8  := NVL(p_attribute8,FND_API.G_MISS_CHAR);
    v_party_rec.attribute9  := NVL(p_attribute9,FND_API.G_MISS_CHAR);
    v_party_rec.attribute10 := NVL(p_attribute10,FND_API.G_MISS_CHAR);
    v_party_rec.attribute11 := NVL(p_attribute11,FND_API.G_MISS_CHAR);
    v_party_rec.attribute12 := NVL(p_attribute12,FND_API.G_MISS_CHAR);
    v_party_rec.attribute13 := NVL(p_attribute13,FND_API.G_MISS_CHAR);
    v_party_rec.attribute14 := NVL(p_attribute14,FND_API.G_MISS_CHAR);
    v_party_rec.attribute15 := NVL(p_attribute15,FND_API.G_MISS_CHAR);
    v_party_rec.attribute16 := NVL(p_attribute16,FND_API.G_MISS_CHAR);
    v_party_rec.attribute17 := NVL(p_attribute17,FND_API.G_MISS_CHAR);
    v_party_rec.attribute18 := NVL(p_attribute18,FND_API.G_MISS_CHAR);
    v_party_rec.attribute19 := NVL(p_attribute19,FND_API.G_MISS_CHAR);
    v_party_rec.attribute20 := NVL(p_attribute20,FND_API.G_MISS_CHAR);
    v_party_rec.attribute21 := NVL(p_attribute21,FND_API.G_MISS_CHAR);
    v_party_rec.attribute22 := NVL(p_attribute22,FND_API.G_MISS_CHAR);
    v_party_rec.attribute23 := NVL(p_attribute23,FND_API.G_MISS_CHAR);
    v_party_rec.attribute24 := NVL(p_attribute24,FND_API.G_MISS_CHAR);

    v_organization_rec_type.organization_name := p_name;
    v_organization_rec_type.party_rec := v_party_rec;


    -- Update by  : brajendr
    -- Fix In Bug : In the Bug # 1882329
    -- Fix Does   : Creation of the Oraganization records need Last_Update_Date as a Mandatory Column.
    --              If the Institutions record is getting created and without re-quering the same record
    --              if we try to add he Govt. Institution Code, it pops-up an error that "Last Update Date"
    --              not found. so if the column is NULL, we are explicitly fetching the data.


-- call to update organization
-- masehgal  V2PUB  call to hz_party
    hz_party_v2pub.update_organization (
       p_init_msg_list                 =>  	FND_API.G_TRUE,
       p_organization_rec              =>    v_organization_rec_type,
       p_party_object_version_number   =>    p_object_version_number,
       x_profile_id                    =>    v_profile_id,
       x_return_status                 =>    p_return_status,
       x_msg_count                     =>    v_msg_count,
       x_msg_data                      =>    p_msg_data
    ) ;

     IF p_return_status <> 'S' THEN
    -- bug 2338473 logic to display more than one error modified.

      IF v_msg_count > 1 THEN
        FOR i IN 1..v_msg_count  LOOP
          tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
          tmp_var1 := tmp_var1 || ' '|| tmp_var;
        END LOOP;
        p_msg_data := tmp_var1;
      END IF;
      RETURN;

    END IF;
  END update_organization;

  PROCEDURE get_where_clause(
      p_function_name                     IN fnd_lookup_values.lookup_code%TYPE,
      p_where_clause                      OUT NOCOPY VARCHAR2
    )AS
  /*
  ||  Created By : Prabhat.Patel@oracle.com
  ||  Created On : 28-AUG-2000
  ||  Purpose : Generic API for finding the filter clause
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  vrathi          9-JUN-2003      Bug No:2940810
  ||                                  PKM Bind variable issue (Instead of passing the hard-coded values passed the select clause)
  ||  (reverse chronological order - newest change first)
  */
  CURSOR get_attr_type_cur IS
	  SELECT distinct attr_type
	  FROM   igs_or_func_fltr
	  WHERE  func_code = p_function_name;

  CURSOR get_attr_val_cur IS
     SELECT attr_val
     FROM   igs_or_func_fltr
     WHERE  func_code = p_function_name;

   l_where_clause  VARCHAR2(450);
   get_attr_type_rec  get_attr_type_cur%ROWTYPE;
   get_attr_val_rec  get_attr_val_cur%ROWTYPE;

   BEGIN
     -- If function name is NULL then return NULL
     IF p_function_name IS NULL THEN
        l_where_clause := NULL;
     ELSE
        -- Find the attribute type for which the setup is done. If no setup is done then return NULL
         OPEN get_attr_type_cur;
         FETCH get_attr_type_cur INTO get_attr_type_rec;
	      IF get_attr_type_cur%NOTFOUND THEN
	         CLOSE get_attr_type_cur;
	         p_where_clause := NULL;
	         RETURN;
	      END IF;
	      CLOSE get_attr_type_cur;

		l_where_clause := get_attr_type_rec.attr_type ||' IN (SELECT attr_val FROM igs_or_func_fltr  WHERE  func_code = '''|| p_function_name ||''')';

     END IF;

	  p_where_clause := l_where_clause;

  EXCEPTION
     WHEN OTHERS THEN
    	 p_where_clause :=	NULL;
    	 FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
         FND_MESSAGE.SET_TOKEN('NAME','igs_or_gen_012_pkg.get_where_clause'||'-'||SQLERRM);
         APP_EXCEPTION.RAISE_EXCEPTION;
  END get_where_clause;



  PROCEDURE get_where_clause_form(
      p_function_name                     IN fnd_lookup_values.lookup_code%TYPE,
      p_where_clause                      OUT NOCOPY VARCHAR2
    )AS
  /*
  ||  Created By : Prabhat.Patel@oracle.com
  ||  Created On : 28-AUG-2000
  ||  Purpose : Generic API for finding the filter clause
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  skpandey        3-FEB-2006      Bug No:4937960
  ||                                  Description:Added procedure get_where_clause_form as a part of Literal
  ||  (reverse chronological order - newest change first)
  */
  CURSOR get_attr_type_cur(cp_function_name VARCHAR2) IS
	  SELECT distinct attr_type
	  FROM   igs_or_func_fltr
	  WHERE  func_code = p_function_name;

   l_where_clause  VARCHAR2(450);
   get_attr_type_rec  get_attr_type_cur%ROWTYPE;

   BEGIN

     -- If function name is NULL then return NULL
     IF p_function_name IS NULL THEN
        l_where_clause := NULL;
     ELSE
        -- Find the attribute type for which the setup is done. If no setup is done then return NULL
         OPEN get_attr_type_cur(p_function_name);
         FETCH get_attr_type_cur INTO get_attr_type_rec;
	      IF get_attr_type_cur%NOTFOUND THEN
	         CLOSE get_attr_type_cur;
	         p_where_clause := NULL;
	         RETURN;
	      END IF;
	      CLOSE get_attr_type_cur;

		l_where_clause := get_attr_type_rec.attr_type ||' IN (SELECT attr_val FROM igs_or_func_fltr  WHERE  func_code = :PARAMETER.P_FORM_NAME)';
     END IF;

	  p_where_clause := l_where_clause;

  EXCEPTION
     WHEN OTHERS THEN
    	 p_where_clause :=	NULL;
    	 FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
         FND_MESSAGE.SET_TOKEN('NAME','igs_or_gen_012_pkg.get_where_clause_form'||'-'||SQLERRM);
         APP_EXCEPTION.RAISE_EXCEPTION;
  END get_where_clause_form;



  PROCEDURE get_where_clause_api(
      p_function_name                     IN fnd_lookup_values.lookup_code%TYPE,
      p_where_clause                      OUT NOCOPY VARCHAR2
    )AS
  /*
  ||  Created By : Prabhat.Patel@oracle.com
  ||  Created On : 28-AUG-2000
  ||  Purpose : Generic API for finding the filter clause
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  skpandey        3-FEB-2006      Bug No:4937960
  ||                                  Description:Added procedure get_where_clause_form as a part of Literal
  ||  (reverse chronological order - newest change first)
  */
  CURSOR get_attr_type_cur(cp_function_name VARCHAR2) IS
	  SELECT distinct attr_type
	  FROM   igs_or_func_fltr
	  WHERE  func_code = cp_function_name;

   l_where_clause  VARCHAR2(450);
   get_attr_type_rec  get_attr_type_cur%ROWTYPE;

   BEGIN
     -- If function name is NULL then return NULL
     IF p_function_name IS NULL THEN
        l_where_clause := NULL;
     ELSE
        -- Find the attribute type for which the setup is done. If no setup is done then return NULL
         OPEN get_attr_type_cur(p_function_name);
         FETCH get_attr_type_cur INTO get_attr_type_rec;
	      IF get_attr_type_cur%NOTFOUND THEN
	         CLOSE get_attr_type_cur;
	         p_where_clause := NULL;
	         RETURN;
	      END IF;
	      CLOSE get_attr_type_cur;

		l_where_clause := get_attr_type_rec.attr_type ||' IN (SELECT attr_val FROM igs_or_func_fltr  WHERE  func_code = :p_function_name )';

     END IF;

	  p_where_clause := l_where_clause;

  EXCEPTION
     WHEN OTHERS THEN
    	 p_where_clause :=	NULL;
    	 FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
         FND_MESSAGE.SET_TOKEN('NAME','igs_or_gen_012_pkg.get_where_clause_api'||'-'||SQLERRM);
         APP_EXCEPTION.RAISE_EXCEPTION;
  END get_where_clause_api;

  PROCEDURE get_where_clause_form1(
      p_function_name                     IN fnd_lookup_values.lookup_code%TYPE,
      p_where_clause                      OUT NOCOPY VARCHAR2
    )AS
  /*
  ||  Created By : Prabhat.Patel@oracle.com
  ||  Created On : 28-AUG-2000
  ||  Purpose : Generic API for finding the filter clause
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  CURSOR get_attr_type_cur(cp_function_name VARCHAR2) IS
	  SELECT distinct attr_type, inst_org_val
	  FROM   igs_or_func_fltr
	  WHERE  func_code = cp_function_name;

   l_where_clause  VARCHAR2(450);
   get_attr_type_rec  get_attr_type_cur%ROWTYPE;
   l_inst_org_prefix VARCHAR2(5);

   BEGIN

     -- If function name is NULL then return NULL
     IF p_function_name IS NULL THEN
        l_where_clause := NULL;
     ELSE
        -- Find the attribute type for which the setup is done. If no setup is done then return NULL
         OPEN get_attr_type_cur(p_function_name);
         FETCH get_attr_type_cur INTO get_attr_type_rec;
	      IF get_attr_type_cur%NOTFOUND THEN
	         CLOSE get_attr_type_cur;
	         p_where_clause := NULL;
	         RETURN;
	      END IF;
	      CLOSE get_attr_type_cur;

              IF get_attr_type_rec.inst_org_val = 'O' THEN
	        l_inst_org_prefix := 'OU_';
	      ELSIF get_attr_type_rec.inst_org_val = 'I' THEN
	        l_inst_org_prefix := 'OI_';
	      END IF;

		l_where_clause := l_inst_org_prefix||get_attr_type_rec.attr_type ||' IN (SELECT attr_val FROM igs_or_func_fltr  WHERE  func_code = :PARAMETER.P_FORM_NAME)';
     END IF;

	  p_where_clause := l_where_clause;

  EXCEPTION
     WHEN OTHERS THEN
    	 p_where_clause :=	NULL;
    	 FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
         FND_MESSAGE.SET_TOKEN('NAME','igs_or_gen_012_pkg.get_where_clause_form1'||'-'||SQLERRM);
         APP_EXCEPTION.RAISE_EXCEPTION;
  END get_where_clause_form1;



  PROCEDURE get_where_clause_api1(
      p_function_name                     IN fnd_lookup_values.lookup_code%TYPE,
      p_where_clause                      OUT NOCOPY VARCHAR2
    )AS
  /*
  ||  Created By : Prabhat.Patel@oracle.com
  ||  Created On : 28-AUG-2000
  ||  Purpose : Generic API for finding the filter clause
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  CURSOR get_attr_type_cur(cp_function_name VARCHAR2) IS
	  SELECT distinct attr_type, inst_org_val
	  FROM   igs_or_func_fltr
	  WHERE  func_code = cp_function_name;

   l_where_clause  VARCHAR2(450);
   get_attr_type_rec  get_attr_type_cur%ROWTYPE;
   l_inst_org_prefix VARCHAR2(5);
   BEGIN
     -- If function name is NULL then return NULL
     IF p_function_name IS NULL THEN
        l_where_clause := NULL;
     ELSE
        -- Find the attribute type for which the setup is done. If no setup is done then return NULL
         OPEN get_attr_type_cur(p_function_name);
         FETCH get_attr_type_cur INTO get_attr_type_rec;
	      IF get_attr_type_cur%NOTFOUND THEN
	         CLOSE get_attr_type_cur;
	         p_where_clause := NULL;
	         RETURN;
	      END IF;
	      CLOSE get_attr_type_cur;

              IF get_attr_type_rec.inst_org_val = 'O' THEN
	        l_inst_org_prefix := 'OU_';
	      ELSIF get_attr_type_rec.inst_org_val = 'I' THEN
	        l_inst_org_prefix := 'OI_';
	      END IF;

		l_where_clause := l_inst_org_prefix||get_attr_type_rec.attr_type ||' IN (SELECT attr_val FROM igs_or_func_fltr  WHERE  func_code = :p_function_name )';

     END IF;

	  p_where_clause := l_where_clause;

  EXCEPTION
     WHEN OTHERS THEN
    	 p_where_clause :=	NULL;
    	 FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
         FND_MESSAGE.SET_TOKEN('NAME','igs_or_gen_012_pkg.get_where_clause_api1'||'-'||SQLERRM);
         APP_EXCEPTION.RAISE_EXCEPTION;
  END get_where_clause_api1;

END igs_or_gen_012_pkg;

/
