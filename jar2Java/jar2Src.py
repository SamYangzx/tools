import os
import zipfile
import subprocess
import re

def extract_class_files(jar_path, output_dir):
    """ 解压 JAR 文件，提取 .class 文件 """
    with zipfile.ZipFile(jar_path, 'r') as jar:
        for file in jar.namelist():
            if file.endswith('.class'):
                jar.extract(file, output_dir)
    return output_dir

def decompile_classes(class_dir, output_dir, cfr_jar):
    """ 使用 CFR 反编译所有 class 文件 """
    for root, _, files in os.walk(class_dir):
        for file in files:
            if file.endswith('.class'):
                class_file = os.path.join(root, file)
                command = ["java", "-jar", cfr_jar, class_file, "--outputdir", output_dir]
                subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

def convert_java_to_aidl(java_dir, aidl_output_dir):
    """ 解析反编译的 Java 代码并转换为 AIDL """
    os.makedirs(aidl_output_dir, exist_ok=True)
    for root, _, files in os.walk(java_dir):
        for file in files:
            if file.endswith(".java"):
                java_file_path = os.path.join(root, file)
                with open(java_file_path, "r", encoding="utf-8") as f:
                    java_code = f.read()
                
                # 解析 IInterface 接口并去除 Default、Stub 相关类
                if "extends IInterface" in java_code:
                    # if re.search(r'\bStub\b|\bDefault\b', java_code):
                        # continue  # 直接跳过 Stub 和 Default 相关类
                    aidl_content = convert_to_aidl(java_code)
                    aidl_filename = file.replace(".java", ".aidl")
                    aidl_path = os.path.join(aidl_output_dir, aidl_filename)
                    with open(aidl_path, "w", encoding="utf-8") as aidl_file:
                        aidl_file.write(aidl_content)

def remove_inner_classes(java_code):
    """ 删除 Java 代码中的所有内部类，包括 Stub、Default 及其他 """
    pattern = re.compile(r'class\s+\w+\s*\{(?:[^{}]*|\{(?:[^{}]*|\{[^{}]*\})*\})*\}', re.DOTALL)
    while pattern.search(java_code):
        java_code = pattern.sub('', java_code)
    return java_code

def convert_to_aidl(java_code):
    """ 将 Java 接口转换为 AIDL 文件格式，并移除所有内部类 """
    java_code = remove_inner_classes(java_code)
    # 移除 package 语句
    aidl_code = re.sub(r'package\s+.*?;', '', java_code)
    # 只保留接口定义，去掉继承信息
    aidl_code = re.sub(r'public abstract interface (\w+) extends IInterface', r'interface \1', aidl_code)
    # 移除 RemoteException
    aidl_code = re.sub(r'public ([\w<>]+) (\w+)\((.*?)\) throws RemoteException;', r'\1 \2(\3);', aidl_code)
    # aidl_code = re.sub(r'\bclass Default\b.*?\{.*?\}', '', aidl_code, flags=re.DOTALL)
    return aidl_code

def main(jar_path, cfr_jar, output_dir="decompiled_sources", aidl_output_dir="aidl_sources"):
    class_dir = "temp_classes"
    os.makedirs(output_dir, exist_ok=True)
    os.makedirs(class_dir, exist_ok=True)
    
    extract_class_files(jar_path, class_dir)
    decompile_classes(class_dir, output_dir, cfr_jar)
    convert_java_to_aidl(output_dir, aidl_output_dir)
    
    print(f"Decompiled Java source files are saved in: {output_dir}")
    print(f"Extracted AIDL files are saved in: {aidl_output_dir}")
    
    # 清理临时 class 文件
    import shutil
    shutil.rmtree(class_dir)

if __name__ == "__main__":
    jar_path = "yourJar.jar"  # 替换为你的 JAR 文件路径
    cfr_jar = "cfr-0.152.jar"  # 替换为 CFR 反编译器的路径
    main(jar_path, cfr_jar)

