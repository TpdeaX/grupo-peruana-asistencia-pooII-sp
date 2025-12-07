package com.grupoperuana.sistema.services;

import com.grupoperuana.sistema.beans.Asistencia;


import com.lowagie.text.Document;
import com.lowagie.text.Element;
import com.lowagie.text.FontFactory;
import com.lowagie.text.PageSize;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;


import org.apache.poi.ss.usermodel.Cell;      
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.FillPatternType;
import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.ss.usermodel.Row;      
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import org.springframework.stereotype.Service;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.List;

@Service
public class ReporteService {

   
    public ByteArrayInputStream generarExcel(List<Asistencia> lista) throws IOException {
        String[] columnas = {"ID", "Empleado", "DNI", "Fecha", "Entrada", "Salida", "Modo", "Observación"};

        try (Workbook workbook = new XSSFWorkbook(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Sheet sheet = workbook.createSheet("Asistencias");

            CellStyle headerStyle = workbook.createCellStyle();
       
            org.apache.poi.ss.usermodel.Font headerFont = workbook.createFont(); 
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);
            
            headerStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

  
            Row headerRow = sheet.createRow(0); // <--- Ahora Java sabe que es Row de Excel
            for (int col = 0; col < columnas.length; col++) {
                Cell cell = headerRow.createCell(col); // <--- Ahora Java sabe que es Cell de Excel
                cell.setCellValue(columnas[col]);
                cell.setCellStyle(headerStyle);
            }

       
            int rowIdx = 1;
            for (Asistencia a : lista) {
                Row row = sheet.createRow(rowIdx++);

                row.createCell(0).setCellValue(a.getId());

                if (a.getEmpleado() != null) {
                    row.createCell(1).setCellValue(a.getEmpleado().getNombres() + " " + a.getEmpleado().getApellidos());
                    row.createCell(2).setCellValue(a.getEmpleado().getDni());
                } else {
                    row.createCell(1).setCellValue("Desconocido");
                    row.createCell(2).setCellValue("-");
                }
                
                row.createCell(3).setCellValue(a.getFecha() != null ? a.getFecha().toString() : "");
                row.createCell(4).setCellValue(a.getHoraEntrada() != null ? a.getHoraEntrada().toString() : "");
                row.createCell(5).setCellValue(a.getHoraSalida() != null ? a.getHoraSalida().toString() : "--");
                row.createCell(6).setCellValue(a.getModo());
                row.createCell(7).setCellValue(a.getObservacion() != null ? a.getObservacion() : "");
            }
      
            for(int i=0; i<columnas.length; i++) {
                sheet.autoSizeColumn(i);
            }

            workbook.write(out);
            return new ByteArrayInputStream(out.toByteArray());
        }
    }

//pdf
    public ByteArrayInputStream generarPDF(List<Asistencia> lista) {
        Document document = new Document(PageSize.A4.rotate());
        ByteArrayOutputStream out = new ByteArrayOutputStream();

        try {
            PdfWriter.getInstance(document, out);
            document.open();

           
            com.lowagie.text.Font fontTitulo = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18);
            
            Paragraph titulo = new Paragraph("Reporte de Asistencias", fontTitulo);
            titulo.setAlignment(Element.ALIGN_CENTER);
            document.add(titulo);
            document.add(new Paragraph(" "));

            
            PdfPTable table = new PdfPTable(7);
            table.setWidthPercentage(100);
            table.setWidths(new float[] {1, 3, 2, 2, 2, 2, 3});

            com.lowagie.text.Font fontHeader = FontFactory.getFont(FontFactory.HELVETICA_BOLD);
            
            String[] headers = {"ID", "Empleado", "Fecha", "Entrada", "Salida", "Método", "Obs"};
            for (String header : headers) {
                PdfPCell cell = new PdfPCell(new Phrase(header, fontHeader));
                cell.setBackgroundColor(java.awt.Color.LIGHT_GRAY);
                cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                cell.setPadding(5);
                table.addCell(cell);
            }

     
            for (Asistencia a : lista) {
                table.addCell(String.valueOf(a.getId()));
                
                if (a.getEmpleado() != null) {
                    table.addCell(a.getEmpleado().getNombres() + " " + a.getEmpleado().getApellidos());
                } else {
                    table.addCell("Desconocido");
                }
                
                table.addCell(a.getFecha() != null ? a.getFecha().toString() : "");
                table.addCell(a.getHoraEntrada() != null ? a.getHoraEntrada().toString() : "");
                table.addCell(a.getHoraSalida() != null ? a.getHoraSalida().toString() : "--");
                table.addCell(a.getModo());
                table.addCell(a.getObservacion() != null ? a.getObservacion() : "");
            }

            document.add(table);
            document.close();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return new ByteArrayInputStream(out.toByteArray());
    }
}