--------------------------------------------------------
--  DDL for Package Body IGW_SUBJECT_INFORMATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_SUBJECT_INFORMATION_PVT" AS
--$Header: igwvsuib.pls 115.5 2002/11/15 00:50:28 ashkumar ship $


PROCEDURE CREATE_SUBJECT_INFORMATION
(p_init_msg_list                  IN VARCHAR2   := FND_API.G_TRUE
 , p_commit                       IN VARCHAR2   := FND_API.G_FALSE
 , p_validate_only                IN VARCHAR2   := FND_API.G_TRUE
 , p_study_title_id               IN NUMBER
 , p_subject_type_code            IN VARCHAR2
 , p_subject_race_code            IN VARCHAR2
 , p_subject_ethnicity_code       IN VARCHAR2
 , p_no_of_subjects               IN NUMBER
 , x_rowid                        OUT NOCOPY ROWID
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2)  IS


  l_study_title_id           NUMBER;
  l_return_status            VARCHAR2(1);
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(250);
  l_data                     VARCHAR2(250);
  l_msg_index_out            NUMBER;

  BEGIN
   IF p_commit = FND_API.G_TRUE THEN
      SAVEPOINT create_subject_information;
   END IF;

    if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
     end if;


      IGW_SUBJECT_INFORMATION_TBH.INSERT_ROW (
       X_ROWID => x_rowid,
       X_STUDY_TITLE_ID => p_study_title_id,
       X_SUBJECT_TYPE_CODE => p_subject_type_code,
       X_SUBJECT_RACE_CODE => p_subject_race_code,
       X_SUBJECT_ETHNICITY_CODE => p_subject_ethnicity_code,
       X_NO_OF_SUBJECTS => p_no_of_subjects,
       X_RETURN_STATUS => l_return_status);

      x_return_status := l_return_status;

    l_msg_count := FND_MSG_PUB.count_msg;

    If l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      If l_msg_count = 1 THEN
        fnd_msg_pub.get
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );
          x_msg_data := l_data;
      End if;
      RAISE  FND_API.G_EXC_ERROR;
    End if;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION

    when fnd_api.g_exc_unexpected_error  then
      if p_commit = fnd_api.g_true then
         rollback to create_subject_information;
      end if;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      Fnd_Msg_Pub.Count_And_Get
         ( p_count   => x_msg_count,
            p_data    => x_msg_data);


  when fnd_api.g_exc_error then
    IF p_commit = fnd_api.g_true then
       rollback TO create_subject_information;
    end if;
    x_return_status := 'E';
      Fnd_Msg_Pub.Count_And_Get
         ( p_count   => x_msg_count,
            p_data    => x_msg_data);

  when others then
    if p_commit = fnd_api.g_true then
       rollback to create_subject_information;
    end if;
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'IGW_SUBJECT_INFORMATION_PVT',
                            p_procedure_name => 'CREATE_SUBJECT_INFORMATION');

      Fnd_Msg_Pub.Count_And_Get
         ( p_count   => x_msg_count,
            p_data    => x_msg_data);

  END CREATE_SUBJECT_INFORMATION;

------------------------------------------------------------------------------------------------

PROCEDURE UPDATE_SUBJECT_INFORMATION
(p_init_msg_list                  IN VARCHAR2   := FND_API.G_TRUE
 , p_commit                       IN VARCHAR2   := FND_API.G_FALSE
 , p_validate_only                IN VARCHAR2   := FND_API.G_TRUE
 , p_study_title_id               IN NUMBER
 , p_subject_type_code            IN VARCHAR2
 , p_subject_race_code            IN VARCHAR2
 , p_subject_ethnicity_code       IN VARCHAR2
 , p_no_of_subjects               IN NUMBER
 , p_rowid                        IN ROWID
 , p_record_version_number        IN NUMBER
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2) IS

    l_msg_data                 VARCHAR2(250);
    l_msg_count                NUMBER;
    l_data                     VARCHAR2(250);
    l_msg_index_out            NUMBER;
    l_return_status            VARCHAR2(1);
    l_proposal_id              NUMBER;


BEGIN

   IF p_commit = FND_API.G_TRUE THEN
      SAVEPOINT update_study_title;
   END IF;

    if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
     end if;

    if (NOT FND_API.TO_BOOLEAN (p_validate_only)) then

      CHECK_LOCK(p_rowid
                ,p_record_version_number
                ,x_return_status );

      l_msg_count := FND_MSG_PUB.count_msg;
      If l_msg_count > 0 THEN
        x_msg_count := l_msg_count;
        If l_msg_count = 1 THEN
          fnd_msg_pub.get
           (p_encoded        => FND_API.G_TRUE ,
            p_msg_index      => 1,
            p_data           => l_data,
            p_msg_index_out  => l_msg_index_out );

            x_msg_data := l_data;
        End if;
        RAISE  FND_API.G_EXC_ERROR;
      End if;

      IGW_SUBJECT_INFORMATION_TBH.UPDATE_ROW (
       X_ROWID => p_rowid,
       X_STUDY_TITLE_ID => p_study_title_id,
       X_SUBJECT_TYPE_CODE => p_subject_type_code,
       X_SUBJECT_RACE_CODE => p_subject_race_code,
       X_SUBJECT_ETHNICITY_CODE => p_subject_ethnicity_code,
       X_NO_OF_SUBJECTS => p_no_of_subjects,
       X_RECORD_VERSION_NUMBER => p_record_version_number,
       X_RETURN_STATUS => l_return_status);

       x_return_status := l_return_status;

    end if;


    l_msg_count := FND_MSG_PUB.count_msg;
    If l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      If l_msg_count = 1 THEN
        fnd_msg_pub.get
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );

          x_msg_data := l_data;
      End if;
      RAISE  FND_API.G_EXC_ERROR;
    End if;

 -- standard check of p_commit
  if fnd_api.to_boolean(p_commit) then
      commit work;
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO update_study_title;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get
         ( p_count   => x_msg_count,
            p_data    => x_msg_data);

  WHEN FND_API.G_EXC_ERROR THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO update_study_title;
    END IF;
    x_return_status := 'E';
      Fnd_Msg_Pub.Count_And_Get
         ( p_count   => x_msg_count,
            p_data    => x_msg_data);

  WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO update_study_title;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'IGW_SUBJECT_INFORMATION_PVT',
                            p_procedure_name => 'UPDATE_SUBJECT_INFORMATION');
      Fnd_Msg_Pub.Count_And_Get
         ( p_count   => x_msg_count,
            p_data    => x_msg_data);

  END UPDATE_SUBJECT_INFORMATION;
-------------------------------------------------------------------------------------------
PROCEDURE DELETE_SUBJECT_INFORMATION (
  p_init_msg_list                IN             VARCHAR2   := FND_API.G_FALSE
 ,p_commit                       IN             VARCHAR2   := FND_API.G_FALSE
 ,p_validate_only                IN             VARCHAR2   := FND_API.G_FALSE
 ,x_rowid                        IN             VARCHAR2
 ,p_study_title_id               IN             NUMBER
 ,p_record_version_number        IN             NUMBER
 ,x_return_status                OUT NOCOPY            VARCHAR2
 ,x_msg_count                    OUT NOCOPY            NUMBER
 ,x_msg_data                     OUT NOCOPY            VARCHAR2)  is

l_msg_count NUMBER;
l_msg_data VARCHAR2(250);
l_data                     VARCHAR2(250);
l_msg_index_out            NUMBER;


BEGIN
-- create savepoint
   IF p_commit = FND_API.G_TRUE THEN
       SAVEPOINT delete_study_title;
   END IF;

-- initialize message list if p_init_msg_list is set to true
   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
   end if;

 CHECK_LOCK (x_rowid  => x_rowid
            ,p_record_version_number => p_record_version_number
            ,x_return_status => x_return_status) ;

 l_msg_count := FND_MSG_PUB.count_msg;
    If l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      If l_msg_count = 1 THEN
        fnd_msg_pub.get
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );

          x_msg_data := l_data;
      End if;
      RAISE  FND_API.G_EXC_ERROR;
    End if;

 if (NOT FND_API.TO_BOOLEAN (p_validate_only)) then

     IGW_SUBJECT_INFORMATION_TBH.DELETE_ROW(
             x_rowid                    =>      x_rowid,
             x_record_version_number    =>      p_record_version_number,
             x_return_status            =>      x_return_status);

  end if;

  l_msg_count := FND_MSG_PUB.count_msg;
    If l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      If l_msg_count = 1 THEN
        fnd_msg_pub.get
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );

          x_msg_data := l_data;
      End if;
      RAISE  FND_API.G_EXC_ERROR;
    End if;


  -- standard check of p_commit
  if fnd_api.to_boolean(p_commit) then
      commit work;
  end if;

 x_return_status := FND_API.G_RET_STS_SUCCESS;

 EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO delete_study_title;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get
         ( p_count   => x_msg_count,
            p_data    => x_msg_data);

  WHEN FND_API.G_EXC_ERROR THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO update_study_title;
    END IF;
    x_return_status := 'E';
      Fnd_Msg_Pub.Count_And_Get
         ( p_count   => x_msg_count,
            p_data    => x_msg_data);

  WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO update_study_title;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'IGW_SUBJECT_INFORMATION_PVT',
                            p_procedure_name => 'DELETE_SUBJECT_INFORMATION');
      Fnd_Msg_Pub.Count_And_Get
         ( p_count   => x_msg_count,
            p_data    => x_msg_data);
END;


-------------------------------------------------------------------------------------------
PROCEDURE CHECK_LOCK
                (x_rowid                        IN      VARCHAR2
                ,p_record_version_number        IN      NUMBER
                ,x_return_status                OUT NOCOPY     VARCHAR2) is
 l_dummy integer;
 BEGIN
   select 1
   into l_dummy
   from igw_subject_information
   where rowid = x_rowid
   and record_version_number = p_record_version_number;

 EXCEPTION
    WHEN NO_DATA_FOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('IGW','IGW_SS_RECORD_CHANGED');
          FND_MSG_PUB.Add;
          raise fnd_api.g_exc_error;

    WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          fnd_msg_pub.add_exc_msg(p_pkg_name       => 'IGW_SUBJECT_INFORMATION_PVT',
                                  p_procedure_name => 'CHECK_LOCK');
          raise fnd_api.g_exc_unexpected_error;


END CHECK_LOCK;

END IGW_SUBJECT_INFORMATION_PVT;

/
