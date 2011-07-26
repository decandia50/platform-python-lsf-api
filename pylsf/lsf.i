/*
 * 
 * Copyright (C) 2010-2011 Platform Computing
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
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301 USA
 * 
 */


/* File: lsf.i */
%module lsf
%include "cpointer.i"

%{
#define SWIG_FILE_WITH_INIT
#include "/opt/platform/lsf/8.0/include/lsf/lsf.h"
#include "/opt/platform/lsf/8.0/include/lsf/lsbatch.h"
%}

%pointer_functions(int, intp)

// howto handle char **
%typemap(in) char ** {
    int size = PyList_Size($input);
    int i = 0;
    $1 = (char **) malloc((size+1)*sizeof(char *));
    for (i = 0; i < size; i++) {
      PyObject *o = PyList_GetItem($input,i);
      $1[i] = PyBytes_AsString(PyUnicode_AsUTF8String(PyList_GetItem($input,i)));
    }
    $1[i] = 0;
}

// cleanup of char **
%typemap(freearg) char ** {
  free((char *) $1);
}

// handle int arrays
%typemap(in) int [ANY] (int temp[$1_dim0]) {
  int i;
  for (i = 0; i < $1_dim0; i++) {
    PyObject *o = PySequence_GetItem($input,i);
      temp[i] = (int) PyInt_AsLong(o);
  }
  $1 = temp;
}

// allow to set members of int array
%typemap(memberin) int [ANY] {
  int i;
  for (i = 0; i < $1_dim0; i++) {
      $1[i] = $input[i];
  }
}

// access int arrays
%typemap(out) int [ANY] {
  int i;
  $result = PyList_New($1_dim0);
  for (i = 0; i < $1_dim0; i++) {
    PyObject *o = PyLong_FromDouble((int) $1[i]);
    PyList_SetItem($result,i,o);
  }
}

// typemap for time_t
%typemap(in) time_t {
    $1 = (time_t) PyLong_AsLong($input);
}

%typemap(out) time_t {
    $result = PyLong_FromLong((long)$1);
}

%typemap(freearg) time_t {
    free((time_t *) $1);
}

/* 
 The following routines are not wrapped because SWIG has issues generating 
 proper code for them 
 */

// Following are ignored from lsf.h

%ignore getBEtime;
%ignore ls_gethostrespriority;
%ignore ls_loadoftype;
%ignore ls_lostconnection;
%ignore ls_nioclose;
%ignore ls_nioctl;
%ignore ls_niodump;
%ignore ls_nioinit;
%ignore ls_niokill;
%ignore ls_nionewtask;
%ignore ls_nioread;
%ignore ls_nioremovetask;
%ignore ls_nioselect;
%ignore ls_niosetdebug;
%ignore ls_niostatus;
%ignore ls_niotasks;
%ignore ls_niowrite;
%ignore ls_placeoftype;
%ignore ls_readrexlog;
%ignore ls_verrlog;

// Following are ignored from lsbatch.h

%ignore lsb_readstatusline;

// Now include the rest...

%include "/opt/platform/lsf/8.0/include/lsf/lsf.h"
%include "/opt/platform/lsf/8.0/include/lsf/lsbatch.h"

%inline %{
PyObject * get_host_names() {
    struct hostInfo *hostinfo; 
    char   *resreq; 
    int    numhosts = 0; 
    int    options = 0; 
    
    resreq="";

    hostinfo = ls_gethostinfo(resreq, &numhosts, NULL, 0, options);      
    
    PyObject *result = PyList_New(numhosts);
    int i;
    for (i = 0; i < numhosts; i++) { 
        PyObject *o = PyString_FromString(hostinfo[i].hostName);
        PyList_SetItem(result,i,o);
    }
    
    return result;
}

PyObject * get_host_info() {
    struct hostInfo *hostinfo; 
    char   *resreq; 
    int    numhosts = 0; 
    int    options = 0; 
    
    resreq = "";

    hostinfo = ls_gethostinfo(resreq, &numhosts, NULL, 0, options);     
         
    PyObject *result = PyList_New(numhosts);
    int i;
    for (i = 0; i < numhosts; i++) {
        PyObject *o = SWIG_NewPointerObj(SWIG_as_voidptr(&hostinfo[i]), SWIGTYPE_p_hostInfo, 0 |  0 );
        PyList_SetItem(result,i,o);
    }
    
    return result;
}    

PyObject * get_host_load() {
    struct hostLoad *hostload; 
    char   *resreq; 
    int    numhosts = 0; 
    int    options = 0; 
    
    resreq = "";

    hostload = ls_loadofhosts(resreq, &numhosts, 0, NULL, NULL, 0);
         
    PyObject *result = PyList_New(numhosts);
    int i;
    for (i = 0; i < numhosts; i++) {
        PyObject *o = SWIG_NewPointerObj(SWIG_as_voidptr(&hostload[i]), SWIGTYPE_p_hostLoad, 0 |  0 );
        PyList_SetItem(result,i,o);
    }
    
    return result;
}     
%}
