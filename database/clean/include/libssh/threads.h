/*
 * This file is part of the SSH Library
 *
 * Copyright (c) 2010 by Aris Adamantiadis
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

#ifndef THREADS_H_
#define THREADS_H_ 

#include <libssh/libssh.h>
#include <libssh/callbacks.h>

#if HAVE_PTHREAD

#include <pthread.h>
#define SSH_MUTEX pthread_mutex_t

#if defined(PTHREAD_ERRORCHECK_MUTEX_INITIALIZER_NP)
#define SSH_MUTEX_STATIC_INIT PTHREAD_ERRORCHECK_MUTEX_INITIALIZER_NP
#else
#define SSH_MUTEX_STATIC_INIT PTHREAD_MUTEX_INITIALIZER
#endif

