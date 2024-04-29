--------------------------------------------------------
--  DDL for Package Body OKE_STANDARD_NOTES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_STANDARD_NOTES_PUB" AS
/* $Header: OKEPNOTB.pls 115.11 2002/11/20 20:46:10 who ship $ */
    g_api_type		CONSTANT VARCHAR2(4) := '_PUB';

  PROCEDURE create_standard_note(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_note_rec		IN  oke_note_pvt.note_rec_type,
    x_note_rec		OUT NOCOPY  oke_note_pvt.note_rec_type) IS


    l_note_rec		oke_note_pvt.note_rec_type;

    l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_STANDARD_NOTE';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_line_number       VARCHAR2(120);

  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    l_note_rec := p_note_rec;

    -- call procedure in complex API

	OKE_NOTE_PVT.Insert_Row(
	    p_api_version	=> p_api_version,
	    p_init_msg_list	=> p_init_msg_list,
            x_return_status 	=> x_return_status,
            x_msg_count     	=> x_msg_count,
            x_msg_data      	=> x_msg_data,
            p_note_rec		=> l_note_rec,
            x_note_rec		=> x_note_rec);


    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END create_standard_note;



  PROCEDURE create_standard_note(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_note_tbl		IN  oke_note_pvt.note_tbl_type,
    x_note_tbl		OUT NOCOPY  oke_note_pvt.note_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_STANDARD_NOTE';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    i			NUMBER;
    l_note_tbl           oke_note_pvt.note_tbl_type;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    OKE_NOTE_PVT.Insert_Row(
      p_api_version	=> p_api_version,
      p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_note_tbl		=> p_note_tbl,
      x_note_tbl		=> x_note_tbl);


    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END create_standard_note;

  PROCEDURE update_standard_note(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_note_rec		IN oke_note_pvt.note_rec_type,
    x_note_rec		OUT NOCOPY oke_note_pvt.note_rec_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_STANDARD_NOTE';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    -- call complex api

    OKE_NOTE_PVT.Update_Row(
      p_api_version		=> p_api_version,
      p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_note_rec			=> p_note_rec,
      x_note_rec			=> x_note_rec);


    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);

  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END update_standard_note;


 PROCEDURE update_standard_note(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_note_tbl			   IN  oke_note_pvt.note_tbl_type,
    x_note_tbl			   OUT NOCOPY  oke_note_pvt.note_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_STANDARD_NOTE';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;

    End If;

    OKE_NOTE_PVT.Update_Row(
	 p_api_version			=> p_api_version,
	 p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_note_tbl			=> p_note_tbl,
      x_note_tbl			=> x_note_tbl);



    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);

  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END update_standard_note;



  PROCEDURE validate_standard_note(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_note_rec			   IN oke_note_pvt.note_rec_type) IS

    l_note_rec		oke_note_pvt.note_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'VALIDATE_STANDARD_NOTE';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;

  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    -- call BEFORE user hook
    l_note_rec := p_note_rec;

    -- call complex API

    OKE_NOTE_PVT.Validate_Row(
	p_api_version		=> p_api_version,
	p_init_msg_list	=> p_init_msg_list,
     	x_return_status 	=> x_return_status,
      	x_msg_count     	=> x_msg_count,
      	x_msg_data      	=> x_msg_data,
      	p_note_rec		=> p_note_rec);


    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    -- end activity
    OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END validate_standard_note;

  PROCEDURE validate_standard_note(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_note_tbl			   IN oke_note_pvt.note_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'VALIDATE_STANDARD_NOTE';

    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    i			NUMBER;
    l_note_tbl       oke_note_pvt.note_tbl_type := p_note_tbl;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;


    OKE_NOTE_PVT.Validate_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_note_tbl		=> p_note_tbl);


    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    -- end activity
    OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END validate_standard_note;




  PROCEDURE delete_standard_note(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_note_rec			   IN oke_note_pvt.note_rec_type) IS

    l_note_rec		oke_note_pvt.note_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_STANDARD_NOTE';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    l_note_rec := p_note_rec;

    -- call complex api

    	OKE_NOTE_PVT.delete_row(
	 	p_api_version		=> p_api_version,
	 	p_init_msg_list	=> p_init_msg_list,
      		x_return_status 	=> x_return_status,
      		x_msg_count     	=> x_msg_count,
      		x_msg_data      	=> x_msg_data,
      		p_note_rec		=> p_note_rec);


    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;


    OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END delete_standard_note;

  PROCEDURE delete_standard_note(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_note_tbl			   IN  oke_note_pvt.note_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_STANDARD_NOTE';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;


    OKE_NOTE_PVT.Delete_Row(
      p_api_version	=> p_api_version,
      p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_note_tbl		=> p_note_tbl);



    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END delete_standard_note;

  PROCEDURE delete_standard_note(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_note_id			   IN NUMBER) IS

    l_note_rec		oke_note_pvt.note_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_STANDARD_NOTE';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_check_num1	NUMBER;
    l_check_num2	NUMBER;

  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    	SELECT COUNT(*) INTO l_check_num1 FROM OKE_K_STANDARD_NOTES_B
	WHERE STANDARD_NOTES_ID = p_note_id;

	SELECT COUNT(*) INTO l_check_num2 FROM OKE_K_STANDARD_NOTES_TL
	WHERE STANDARD_NOTES_ID = p_note_id;

    If(l_check_num1<1)OR(l_check_num2<1) then
    	raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    l_note_rec.STANDARD_NOTES_ID := p_note_id;

    -- call complex api

    	OKE_NOTE_PVT.delete_row(
	 	p_api_version		=> p_api_version,
	 	p_init_msg_list		=> p_init_msg_list,
      		x_return_status 	=> x_return_status,
      		x_msg_count     	=> x_msg_count,
      		x_msg_data      	=> x_msg_data,
      		p_note_rec		=> l_note_rec);


    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;


    OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END delete_standard_note;



  PROCEDURE delete_standard_note(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hdr_id		IN NUMBER,
    p_cle_id		IN NUMBER,
    p_del_id		IN NUMBER ) IS

    l_note_rec		oke_note_pvt.note_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_STANDARD_NOTE';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_check_num1	NUMBER;
    l_check_num2	NUMBER;

  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

	If (p_del_id IS NOT NULL) Then
		OKE_NOTE_PVT.delete_row(
	 	p_api_version		=> p_api_version,
	 	p_init_msg_list		=> p_init_msg_list,
      		x_return_status 	=> x_return_status,
      		x_msg_count     	=> x_msg_count,
      		x_msg_data      	=> x_msg_data,
      		p_del_id		=> p_del_id);


	ElsIf (p_cle_id IS NOT NULL) Then
		OKE_NOTE_PVT.delete_row(
	 	p_api_version		=> p_api_version,
	 	p_init_msg_list		=> p_init_msg_list,
      		x_return_status 	=> x_return_status,
      		x_msg_count     	=> x_msg_count,
      		x_msg_data      	=> x_msg_data,
      		p_cle_id		=> p_cle_id);


	ElsIf (p_hdr_id IS NOT NULL) Then
		OKE_NOTE_PVT.delete_row(
	 	p_api_version		=> p_api_version,
	 	p_init_msg_list		=> p_init_msg_list,
      		x_return_status 	=> x_return_status,
      		x_msg_count     	=> x_msg_count,
      		x_msg_data      	=> x_msg_data,
      		p_hdr_id		=> p_hdr_id);

	Else
		raise OKE_API.G_EXCEPTION_ERROR;
	End If;



    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END delete_standard_note;


  PROCEDURE copy_standard_note(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_from_hdr_id		IN NUMBER,
    p_to_hdr_id		IN NUMBER,
    p_from_cle_id		IN NUMBER,
    p_to_cle_id		IN NUMBER,
    p_from_del_id		IN NUMBER,
    p_to_del_id		IN NUMBER,
    default_flag	IN VARCHAR2
	) IS

    l_note_tbl		oke_note_pvt.note_tbl_type;
    l_note_rec		oke_note_pvt.note_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'COPY_STANDARD_NOTE';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_rec_num		NUMBER:=0;

    x_note_tbl		oke_note_pvt.note_tbl_type;


   CURSOR note_del_csr (p_id  IN NUMBER) IS
    SELECT unique
		b.STANDARD_NOTES_ID		,
		b.CREATION_DATE			,
		b.CREATED_BY			,
		b.LAST_UPDATE_DATE		,
		b.LAST_UPDATED_BY			,
		b.LAST_UPDATE_LOGIN		,
		b.HEADER_ID			,

		b.LINE_ID			,

		b.DELIVERABLE_ID			,
		b.TYPE_CODE			,
		b.ATTRIBUTE_CATEGORY		,
		b.ATTRIBUTE1			,
		b.ATTRIBUTE2			,
		b.ATTRIBUTE3			,
		b.ATTRIBUTE4			,
		b.ATTRIBUTE5			,
		b.ATTRIBUTE6			,
		b.ATTRIBUTE7			,
		b.ATTRIBUTE8			,
		b.ATTRIBUTE9			,
		b.ATTRIBUTE10			,
		b.ATTRIBUTE11			,
		b.ATTRIBUTE12			,
		b.ATTRIBUTE13			,
		b.ATTRIBUTE14			,
		b.ATTRIBUTE15			,
		b.SFWT_FLAG			,
		b.DESCRIPTION			,
		b.NAME				,
		b.TEXT				,
		b.default_flag
    FROM OKE_K_STANDARD_NOTES_VL b
    WHERE b.DELIVERABLE_ID = p_id
	AND b.LINE_ID IS NULL;

    CURSOR note_cle_csr (p_id  IN NUMBER) IS
    SELECT 	unique
		b.STANDARD_NOTES_ID		,
		b.CREATION_DATE			,
		b.CREATED_BY			,
		b.LAST_UPDATE_DATE		,
		b.LAST_UPDATED_BY			,
		b.LAST_UPDATE_LOGIN		,
		b.HEADER_ID			,
		b.LINE_ID			,
		b.DELIVERABLE_ID			,
		b.TYPE_CODE			,
		b.ATTRIBUTE_CATEGORY		,
		b.ATTRIBUTE1			,
		b.ATTRIBUTE2			,
		b.ATTRIBUTE3			,
		b.ATTRIBUTE4			,
		b.ATTRIBUTE5			,
		b.ATTRIBUTE6			,
		b.ATTRIBUTE7			,
		b.ATTRIBUTE8			,
		b.ATTRIBUTE9			,
		b.ATTRIBUTE10			,
		b.ATTRIBUTE11			,
		b.ATTRIBUTE12			,
		b.ATTRIBUTE13			,
		b.ATTRIBUTE14			,
		b.ATTRIBUTE15			,
		b.SFWT_FLAG			,
		b.DESCRIPTION			,
		b.NAME				,
		b.TEXT				,
		b.default_flag
    FROM OKE_K_STANDARD_NOTES_VL B
    WHERE b.LINE_ID = p_id
	AND b.DELIVERABLE_ID IS NULL;

    CURSOR note_hdr_csr (p_id  IN NUMBER) IS
    SELECT 	unique
		b.STANDARD_NOTES_ID		,
		b.CREATION_DATE			,
		b.CREATED_BY			,
		b.LAST_UPDATE_DATE		,
		b.LAST_UPDATED_BY			,
		b.LAST_UPDATE_LOGIN		,
		b.HEADER_ID			,
		b.LINE_ID			,
		b.DELIVERABLE_ID			,
		b.TYPE_CODE			,
		b.ATTRIBUTE_CATEGORY		,
		b.ATTRIBUTE1			,
		b.ATTRIBUTE2			,
		b.ATTRIBUTE3			,
		b.ATTRIBUTE4			,
		b.ATTRIBUTE5			,
		b.ATTRIBUTE6			,
		b.ATTRIBUTE7			,
		b.ATTRIBUTE8			,
		b.ATTRIBUTE9			,
		b.ATTRIBUTE10			,
		b.ATTRIBUTE11			,
		b.ATTRIBUTE12			,
		b.ATTRIBUTE13			,
		b.ATTRIBUTE14			,
		b.ATTRIBUTE15			,
		b.SFWT_FLAG			,
		b.DESCRIPTION			,
		b.NAME				,
		b.TEXT				,
		b.default_flag
    FROM OKE_K_STANDARD_NOTES_VL B
    WHERE b.HEADER_ID = p_id
	AND b.DELIVERABLE_ID IS NULL AND b.LINE_ID IS NULL;

  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    IF(
    (p_from_hdr_id   	IS NOT NULL)AND
    (p_from_cle_id	IS NULL)AND
    (p_from_del_id	IS NULL) ) THEN


	OPEN note_hdr_csr (p_from_hdr_id);
	LOOP
	FETCH note_hdr_csr INTO
		l_note_rec.STANDARD_NOTES_ID		,
		l_note_rec.CREATION_DATE		,
		l_note_rec.CREATED_BY			,
		l_note_rec.LAST_UPDATE_DATE		,
		l_note_rec.LAST_UPDATED_BY		,
		l_note_rec.LAST_UPDATE_LOGIN		,
		l_note_rec.K_HEADER_ID			,
		l_note_rec.K_LINE_ID			,
		l_note_rec.DELIVERABLE_ID		,
		l_note_rec.TYPE_CODE			,
		l_note_rec.ATTRIBUTE_CATEGORY		,
		l_note_rec.ATTRIBUTE1			,
		l_note_rec.ATTRIBUTE2			,
		l_note_rec.ATTRIBUTE3			,
		l_note_rec.ATTRIBUTE4			,
		l_note_rec.ATTRIBUTE5			,
		l_note_rec.ATTRIBUTE6			,
		l_note_rec.ATTRIBUTE7			,
		l_note_rec.ATTRIBUTE8			,
		l_note_rec.ATTRIBUTE9			,
		l_note_rec.ATTRIBUTE10			,
		l_note_rec.ATTRIBUTE11			,
		l_note_rec.ATTRIBUTE12			,
		l_note_rec.ATTRIBUTE13			,
		l_note_rec.ATTRIBUTE14			,
		l_note_rec.ATTRIBUTE15			,
		l_note_rec.SFWT_FLAG			,
		l_note_rec.DESCRIPTION			,
		l_note_rec.NAME				,
		l_note_rec.TEXT				,
		l_note_rec.default_flag			;
	EXIT WHEN note_hdr_csr%NOTFOUND;


	IF (default_flag='N')OR((default_flag='Y')AND(l_note_rec.default_flag='Y')) THEN

		l_rec_num := l_rec_num+1;
		l_note_tbl(l_rec_num) := l_note_rec;

 -- add a bit of logic to figure destination (10/11/2000)

		IF p_to_hdr_id IS NOT NULL THEN
			l_note_tbl(l_rec_num).K_HEADER_ID := p_to_hdr_id;
		END IF;

		IF p_to_cle_id IS NOT NULL THEN
			l_note_tbl(l_rec_num).K_LINE_ID := p_to_cle_id;
		END IF;

		IF p_to_del_id IS NOT NULL THEN
			l_note_tbl(l_rec_num).DELIVERABLE_ID := p_to_del_id;
		END IF;

	END IF;

	END LOOP;

	CLOSE note_hdr_csr;


    	OKE_NOTE_PVT.Insert_Row(
      		p_api_version	=> p_api_version,
      		p_init_msg_list	=> p_init_msg_list,
      		x_return_status 	=> x_return_status,
      		x_msg_count     	=> x_msg_count,
      		x_msg_data      	=> x_msg_data,
      		p_note_tbl		=> l_note_tbl,
      		x_note_tbl		=> x_note_tbl);

    	If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    	End If;


    ELSIF(
----    (p_from_hdr_id   	IS NULL)AND
    (p_from_cle_id	IS NOT NULL)AND
    (p_from_del_id	IS NULL) ) THEN


	OPEN note_cle_csr (p_from_cle_id);
	LOOP
	FETCH note_cle_csr INTO
		l_note_rec.STANDARD_NOTES_ID		,
		l_note_rec.CREATION_DATE		,
		l_note_rec.CREATED_BY			,
		l_note_rec.LAST_UPDATE_DATE		,
		l_note_rec.LAST_UPDATED_BY		,
		l_note_rec.LAST_UPDATE_LOGIN		,
		l_note_rec.K_HEADER_ID			,
		l_note_rec.K_LINE_ID			,
		l_note_rec.DELIVERABLE_ID		,
		l_note_rec.TYPE_CODE			,
		l_note_rec.ATTRIBUTE_CATEGORY		,
		l_note_rec.ATTRIBUTE1			,
		l_note_rec.ATTRIBUTE2			,
		l_note_rec.ATTRIBUTE3			,
		l_note_rec.ATTRIBUTE4			,
		l_note_rec.ATTRIBUTE5			,
		l_note_rec.ATTRIBUTE6			,
		l_note_rec.ATTRIBUTE7			,
		l_note_rec.ATTRIBUTE8			,
		l_note_rec.ATTRIBUTE9			,
		l_note_rec.ATTRIBUTE10			,
		l_note_rec.ATTRIBUTE11			,
		l_note_rec.ATTRIBUTE12			,
		l_note_rec.ATTRIBUTE13			,
		l_note_rec.ATTRIBUTE14			,
		l_note_rec.ATTRIBUTE15			,
		l_note_rec.SFWT_FLAG			,
		l_note_rec.DESCRIPTION			,
		l_note_rec.NAME				,
		l_note_rec.TEXT				,
		l_note_rec.default_flag			;
	EXIT WHEN note_cle_csr%NOTFOUND;


	IF (default_flag='N')OR((default_flag='Y')AND(l_note_rec.default_flag='Y')) THEN

		l_rec_num := l_rec_num+1;
		l_note_tbl(l_rec_num) := l_note_rec;


 -- add a bit of logic to figure destination (10/11/2000)

		IF p_to_hdr_id IS NOT NULL THEN
			l_note_tbl(l_rec_num).K_HEADER_ID := p_to_hdr_id;
		END IF;

		IF p_to_cle_id IS NOT NULL THEN
			l_note_tbl(l_rec_num).K_LINE_ID := p_to_cle_id;
		END IF;

		IF p_to_del_id IS NOT NULL THEN
			l_note_tbl(l_rec_num).DELIVERABLE_ID := p_to_del_id;
		END IF;

	END IF;

	END LOOP;
	CLOSE note_cle_csr;


    	OKE_NOTE_PVT.Insert_Row(
      		p_api_version	=> p_api_version,
      		p_init_msg_list	=> p_init_msg_list,
      		x_return_status 	=> x_return_status,
      		x_msg_count     	=> x_msg_count,
      		x_msg_data      	=> x_msg_data,
      		p_note_tbl		=> l_note_tbl,
      		x_note_tbl		=> x_note_tbl);

    	If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    	End If;


    ELSIF(
----    (p_from_hdr_id   	= NULL)AND
    (p_from_cle_id	IS NULL)AND
    (p_from_del_id	IS NOT NULL) ) THEN



	OPEN note_del_csr (p_from_del_id);
	LOOP
	FETCH note_del_csr INTO
		l_note_rec.STANDARD_NOTES_ID		,
		l_note_rec.CREATION_DATE		,
		l_note_rec.CREATED_BY			,
		l_note_rec.LAST_UPDATE_DATE		,
		l_note_rec.LAST_UPDATED_BY		,
		l_note_rec.LAST_UPDATE_LOGIN		,
		l_note_rec.K_HEADER_ID			,
		l_note_rec.K_LINE_ID			,
		l_note_rec.DELIVERABLE_ID		,
		l_note_rec.TYPE_CODE			,
		l_note_rec.ATTRIBUTE_CATEGORY		,
		l_note_rec.ATTRIBUTE1			,
		l_note_rec.ATTRIBUTE2			,
		l_note_rec.ATTRIBUTE3			,
		l_note_rec.ATTRIBUTE4			,
		l_note_rec.ATTRIBUTE5			,
		l_note_rec.ATTRIBUTE6			,
		l_note_rec.ATTRIBUTE7			,
		l_note_rec.ATTRIBUTE8			,
		l_note_rec.ATTRIBUTE9			,
		l_note_rec.ATTRIBUTE10			,
		l_note_rec.ATTRIBUTE11			,
		l_note_rec.ATTRIBUTE12			,
		l_note_rec.ATTRIBUTE13			,
		l_note_rec.ATTRIBUTE14			,
		l_note_rec.ATTRIBUTE15			,
		l_note_rec.SFWT_FLAG			,
		l_note_rec.DESCRIPTION			,
		l_note_rec.NAME				,
		l_note_rec.TEXT				,
		l_note_rec.default_flag			;
	EXIT WHEN note_del_csr%NOTFOUND;


	IF (default_flag='N')OR((default_flag='Y')AND(l_note_rec.default_flag='Y')) THEN

		l_rec_num := l_rec_num+1;
		l_note_tbl(l_rec_num) := l_note_rec;

 -- add a bit of logic to figure destination (10/11/2000)

		IF p_to_hdr_id IS NOT NULL THEN
			l_note_tbl(l_rec_num).K_HEADER_ID := p_to_hdr_id;
		END IF;

		IF p_to_cle_id IS NOT NULL THEN
			l_note_tbl(l_rec_num).K_LINE_ID := p_to_cle_id;
		END IF;

		IF p_to_del_id IS NOT NULL THEN
			l_note_tbl(l_rec_num).DELIVERABLE_ID := p_to_del_id;
		END IF;

	END IF;

	END LOOP;
	CLOSE note_del_csr;

    	OKE_NOTE_PVT.Insert_Row(
      		p_api_version	=> p_api_version,
      		p_init_msg_list	=> p_init_msg_list,
      		x_return_status 	=> x_return_status,
      		x_msg_count     	=> x_msg_count,
      		x_msg_data      	=> x_msg_data,
      		p_note_tbl		=> l_note_tbl,
      		x_note_tbl		=> x_note_tbl);


    	If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    	End If;

  ELSE
	raise OKE_API.G_EXCEPTION_ERROR;
  END IF;

    OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END copy_standard_note;


  PROCEDURE lock_standard_note(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_note_rec           IN OKE_NOTE_PVT.note_rec_type) IS


    l_del_rec		oke_deliverable_pvt.del_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'LOCK_STANDARD_NOTE';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)	  := OKE_API.G_RET_STS_SUCCESS;

  BEGIN
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    OKE_NOTE_PVT.Lock_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_note_rec		=> p_note_rec);

    -- check return status
    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END lock_standard_note;

  PROCEDURE lock_standard_note(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_note_tbl                     IN oke_note_pvt.note_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'LOCK_STANDARD_NOTE';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    If (p_note_tbl.COUNT > 0) Then
	   i := p_note_tbl.FIRST;
	   LOOP
		-- call procedure in complex API
		OKE_NOTE_PVT.lock_row(
			p_api_version		=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_note_rec		=> p_note_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
        EXIT WHEN (i = p_note_tbl.LAST);
		i := p_note_tbl.NEXT(i);
	   END LOOP;
	   -- return overall status
	   x_return_status := l_overall_status;
    End If;

    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    -- end activity
    OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END lock_standard_note;

END OKE_STANDARD_NOTES_PUB;


/
