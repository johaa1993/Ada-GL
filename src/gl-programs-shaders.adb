with GL.C;
with GL.C.Complete;

with Interfaces;
with Interfaces.C;
with Interfaces.C.Strings;

package body GL.Programs.Shaders is

   function Create_Empty (Kind : Shader_Type) return Shader is
      S : Shader;
   begin
      S := Shader (glCreateShader (Kind'Enum_Rep));
      return S;
   end;

   function Validate (Item : Shader) return Boolean is
      use type GLboolean;
      B : GLboolean;
   begin
      B := glIsShader (GLuint (Item));
      return B = GL_TRUE;
   end;

   procedure Delete (Item : Shader) is
   begin
      --glDeleteShader (GLuint (S));
      null;
   end;







   procedure Get_Info (Item : Shader; P : Shader_Info; R : access GLint) is
   begin
      glGetShaderiv (GLuint (Item), P'Enum_Rep, R);
   end;

   function Compile_Succeess (Item : Shader) return Boolean is
      use type GLint;
      R : aliased GLint;
   begin
      Get_Info (Item, Compile_Info, R'Access);
      return R = GL_TRUE;
   end;

   function Get_Type (Item : Shader) return Shader_Type is
      use type GLint;
      Result : aliased GLint;
   begin
      Get_Info (Item, Type_Info, Result'Access);
      return Shader_Type'Enum_Val (Result);
   end;

   function Get_Source_Length (Item : Shader) return Natural is
      use type GLint;
      Result : aliased GLint;
   begin
      Get_Info (Item, Source_Length_Info, Result'Access);
      --Ada.Text_IO.Put_Line ("L: " & Result'Img);
      return Natural (Result);
   end;


   procedure Get_Compile_Log (Item : Shader; Message : out Compile_Log; Count : out Natural) is
      use Interfaces.C;
      Length : aliased GLsizei := 0;
      Text : aliased GLstring (1 .. Message'Length);
   begin
      glGetShaderInfoLog (GLuint (Item), Message'Length, Length'Access, Text'Address);
      To_Ada (Text, String (Message), Count);
   end;

   function Get_Compile_Log (Item : Shader; Count : Natural := 512) return Compile_Log is
      Text : Compile_Log (1 .. Count);
      Length : Natural := 0;
   begin
      Get_Compile_Log (Item, Text, Length);
      return Text (1 .. Length);
   end;




   procedure Set_Source (Item : Shader; Source : Shading_Language) is
      use Interfaces.C;
      use Interfaces.C.Strings;
      C_Content : aliased char_array := To_C (String (Source));
      C_Content_Array : GLstringv (1 .. 1);
      C_Length_Array : GLintv (1 .. 1);
   begin
      -- Array of pointers to strings containing the source code to be loaded into the shader.
      C_Content_Array (1) := To_Chars_Ptr (C_Content'Unrestricted_Access);
      -- The null character is not counted as part of the string length.
      C_Length_Array (1) := Source'Length;
      glShaderSource (GLuint (Item), 1, C_Content_Array, C_Length_Array);
   end;


   procedure Compile (Item : Shader) is
   begin
      glCompileShader (GLuint (Item));
   end;

   procedure Attach (Item : Program; S : Shader) is
   begin
      glAttachShader (GLuint (Item), GLuint (S));
   end;

end;
